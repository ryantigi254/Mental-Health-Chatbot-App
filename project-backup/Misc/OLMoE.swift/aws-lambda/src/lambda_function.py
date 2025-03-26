"""
Lambda function for handling requests to the OLMoE API.
"""
import os
from http import HTTPStatus
import json
from datetime import datetime
import boto3  # type: ignore

from attestation import verify_attest, generate_challenge
from entities.trace import Trace
from entities.routes import LambdaRouter, Route
from entities.response import ApiResponse
from constants.response_messages import ResponseMessages
from constants.deployment_environment import DeploymentEnvironment

# Initialize S3 client
s3 = boto3.client("s3")

# Configure these variables
BUCKET_NAME = os.environ['BUCKET_NAME']
S3_LOG_PREFIX = os.environ['S3_LOG_PREFIX']
S3_SHARE_PREFIX = os.environ['S3_SHARE_PREFIX']
MAX_REQUEST_SIZE_BYTES = os.environ.get(
    'MAX_REQUEST_SIZE_BYTES', 51200)  # default to 50KB

DEPLOYMENT_ENV = DeploymentEnvironment.from_env()

with open("chat_template.html", "r", encoding="utf-8") as f:
    CHAT_TEMPLATE = f.read()


def lambda_handler(event, context):
    """
    Handle the incoming request, and route it to the appropriate handler.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (LambdaContext): The context object containing runtime information.

    Returns:
        ApiResponse: The response object containing the result of the operation.
    """
    try:
        # Validate request body size
        body_size = len(str(event).encode('utf-8'))
        if body_size > int(MAX_REQUEST_SIZE_BYTES):
            return ApiResponse.error(ResponseMessages.INVALID_REQUEST_BODY.value, HTTPStatus.REQUEST_ENTITY_TOO_LARGE)

        match LambdaRouter.get_route(event):
            case Route.ISSUE_CHALLENGE:
                return handle_issue_challenge(event)
            case Route.WRITE_TRACE_TO_S3:
                return handle_write_to_s3(event)
            case _:
                return ApiResponse.error(ResponseMessages.INVALID_REQUEST_BODY.value, HTTPStatus.BAD_REQUEST)
    except Exception as e:
        return ApiResponse.error(f"{type(e).__name__}: {e}")


def handle_issue_challenge(event):
    """
    Respond to a request for a challenge.

    Args:
        event (dict): The event data containing the key_id.

    Returns:
        ApiResponse: The response object containing the generated challenge or an error message.
    """
    key_id = event.get('key_id')
    if not key_id or not isinstance(key_id, str):
        return ApiResponse.error(ResponseMessages.INVALID_KEY_ID.value, HTTPStatus.BAD_REQUEST)

    try:
        challenge_base64 = generate_challenge(key_id)

        return ApiResponse.success({"challenge": challenge_base64})
    except Exception:
        return ApiResponse.error(ResponseMessages.FAILED_TO_GENERATE_CHALLENGE.value)


def handle_write_to_s3(event):
    """
    Respond to a request to write a trace to S3, and return a URL to the trace.

    Args:
        event (dict): The event data containing the trace information and attestation object.

    Returns:
        ApiResponse: The response object containing the URL of the uploaded trace or an error message.
    """
    key_id = event.get('key_id')
    attestation_object = event.get('attestation_object')

    if DEPLOYMENT_ENV != DeploymentEnvironment.TEST and not verify_attest(key_id, attestation_object):
        return ApiResponse.error(ResponseMessages.ATTESTATION_VERIFICATION_FAILED.value)

    body = {k: v for k, v in event.items() if k not in [
        'key_id', 'attestation_object']}

    # Extract logs from the event
    log = Trace.from_dict(body)

    # Get the date from the log timestamp
    date_prefix = datetime.fromtimestamp(log.created).date().strftime("%Y%m%d")
    data_key = f"{S3_LOG_PREFIX}/{log.system_fingerprint}/{date_prefix}/{log.id}.json"
    # Convert batch to JSON string
    s3.put_object(Bucket=BUCKET_NAME, Key=data_key, Body=json.dumps(
        log.to_dict()), ContentType="application/json")

    # Render HTML
    html = CHAT_TEMPLATE.replace(
        "[[ADD_JSON_HERE]]", json.dumps(log.to_dict()))
    html_key = f"{S3_SHARE_PREFIX}/{log.system_fingerprint}/{date_prefix}/{log.id}.html"
    s3.put_object(Bucket=BUCKET_NAME, Key=html_key,
                  Body=html, ContentType="text/html")

    return ApiResponse.success({"url": f"https://{BUCKET_NAME}.s3.amazonaws.com/{html_key}"})
