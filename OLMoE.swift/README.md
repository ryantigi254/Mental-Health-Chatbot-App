# Ai2 OLMoE

<p align="center">
  <img src="./doc_assets/App_Main.png" alt="App Main" width="250"/>
</p>

Ai2 OLMoE is an AI chatbot powered by the [OLMoE](https://huggingface.co/collections/allenai/olmoe-66cf678c047657a30c8cd3da) model. Unlike cloud-based AI assistants, **OLMoE runs entirely on your device**, ensuring complete **privacy** and **offline accessibility**—even in **Flight Mode**.


## Getting started with OLMoE app

1. **Open the app** – Launch OLMoE app on your device.  
2. **Download the model** – The app may prompt you to download the required model files. Just follow the instructions and wait for the download to complete.  
3. **Ask questions** – Once the model is ready, type in your question, and the app will generate a response.  

We **don’t** store any of your queries or data—everything runs on your device. You can even use the app in **Flight Mode** with no internet connection.  

Enjoy a fully open, private, and offline capable AI experience with OLMoE.

## OLMoE.swift

Clone the repository in your respective directory by
```bash
git clone https://github.com/allenai/OLMoE.swift.git
```

- The project uses `.xcconfig` files for build configurations.
Open Xcode and select OLMoE project, navigate to Info → Configurations Ensure that both Debug and Release use `build.xcconfig`.

- Open **Signing & Capabilities** in Xcode. Check ✅ **Automatically manage signing** and select your Apple Developer Team. Update the **Bundle Identifier** to something like `com.domain.app`.  

- Change the Bundle Identifier to match your app’s domain. If you see a signing error, enable development signing:  
  
- Before running the app, select a device or simulator. Click on the device dropdown at the top. Choose an available simulator or a connected physical device. 

- Check that the correct **Team** and **Bundle Identifier** are set under **Signing & Capabilities**.  

- Select the device or simulator and run the app.

See [OLMoE.swift/README.md](OLMoE.swift/README.md) for more information.

## Running OLMoE with Hugging Face

Install `transformers` (version 4.45.0 or greater) & `torch` and run:

```python
from transformers import OlmoeForCausalLM, AutoTokenizer
import torch

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# Load different ckpts via passing e.g. `revision=step10000-tokens41B`
model = OlmoeForCausalLM.from_pretrained("allenai/OLMoE-1B-7B-0125").to(DEVICE)
tokenizer = AutoTokenizer.from_pretrained("allenai/OLMoE-1B-7B-0125")
inputs = tokenizer("Bitcoin is", return_tensors="pt")
inputs = {k: v.to(DEVICE) for k, v in inputs.items()}
out = model.generate(**inputs, max_length=64)
print(tokenizer.decode(out[0]))
# > # Bitcoin is a digital currency that is created and held electronically. No one controls it. Bitcoins aren’t printed, like dollars or euros – they’re produced by people and businesses running computers all around the world, using software that solves mathematical
```

## aws-lambda

This is a lambda function used for the "sharing" feature of the OLMoE app. See [aws-lambda/README.md](aws-lambda/README.md) for more information.

## License

This project is open source. See [LICENSE](LICENSE) for more information.

## Open Source Dependencies

This project relies on the following open-source libraries, each licensed under the **MIT License**:  

### [LlamaCPP](https://github.com/ggerganov/llama.cpp)  
- **Author(s):** The ggml authors (2023-2024)  
- **License:** MIT  
- **Repository:** [LlamaCPP](https://github.com/ggerganov/llama.cpp)  

### [ggml](https://github.com/ggerganov/ggml)  
- **Author(s):** The ggml authors (2023-2024)  
- **License:** MIT  
- **Repository:** [ggml](https://github.com/ggerganov/ggml)  

### [MarkdownUI](https://github.com/gonzalezreal/swift-markdown-ui)  
- **Author(s):** Guillermo Gonzalez (2020)  
- **License:** MIT  
- **Repository:** [MarkdownUI](https://github.com/gonzalezreal/swift-markdown-ui)  

For more details on each license, visit the respective repositories linked above.