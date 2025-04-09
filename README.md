# Mental Health Chatbot App (Based on OLMoE.swift)

**Note:** This project started as an extension of my coursework. I initially planned to develop an object‐oriented app, but my team preferred a web app approach due to its simplicity. Ultimately, I chose a work on the side to build a design that enables a completely local model for enhanced privacy and offline functionality.

## Overview

The Mental Health Chatbot App leverages a completely local AI model—ensuring all processing happens on-device, with no data sent to the cloud. This project draws heavily from [OLMoE.swift](https://github.com/allenai/OLMoE.swift?tab=readme-ov-file), an open-source on-device AI framework provided by [AllenAI](https://allenai.org/on-device). Our modifications focus on mental health–related interactions, privacy, and user experience.

## Starting Point & Related Work

This project builds upon earlier work in the [AI-Mental-Health-Chatbot](https://github.com/ryantigi254/AI-Mental-Health-Chatbot.git) repository. We integrated OLMoE’s local model approach to create an app that runs entirely on the device. Our objective is to ensure full user privacy and offline capabilities, making it suitable for sensitive contexts like mental health support.

## Project Motivation

- **Local Model:** The app runs entirely on the device, ensuring complete privacy and offline capability.  
- **Educational Focus:** The primary aim is to gain practical experience with production-level code, learn Swift, and understand the challenges of local AI model integration.  
- **Team Dynamics:** While we initially envisioned an object-oriented approach, a web app was chosen for simplicity, then combined with OLMoE’s on-device approach for an offline solution.

## Limitations

Due to the absence of a paid Apple Developer account, some features may not be fully implemented or may have limited usability. Nonetheless, this project’s primary goal is to provide a real-world application and serve as a valuable learning experience for me.

---

## Getting Started

1. **Clone the Repository:**
   ```bash
   git clone git@github.com:ryantigi254/Mental-Health-Chatbot-App.git

	2.	Open the Xcode Project
Inside the cloned repository, locate the OLMoE.swift folder. The Xcode project file is at:

/Users/ryangichuru/Documents/SSD-K/Uni/2nd year/2nd Semester/AI Group Project/Misc/OLMoE.swift/OLMoE.swift.xcodeproj

Double-click OLMoE.swift.xcodeproj or open it via File → Open in Xcode.

	3.	Build & Run
	•	Select an iPhone simulator (e.g., iPhone 15 Pro or higher) or a connected device.
	•	Enable “Automatically manage signing” under Signing & Capabilities if needed.
	•	Press the Run button (▶) in Xcode to build and launch the app.

⸻

Using the OLMoE App
	1.	Open the App
Launch the OLMoE app on your device or simulator.
	2.	Download the Model
If prompted, follow the instructions to download the required model files. Once downloaded, everything runs locally.
	3.	Ask Questions
Type your question, and the app will generate a response. All queries and responses stay on your device—no cloud usage.
	4.	Offline Capability
After the initial setup, you can use the app even in Flight Mode. No internet connection is required for inference.

Enjoy a fully open, private, and offline-capable AI experience with OLMoE!

⸻

"Running OLMoE with Hugging Face

You can also run the OLMoE model in a Python environment using Hugging Face:

from transformers import OlmoeForCausalLM, AutoTokenizer
import torch

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# Load different checkpoints, e.g. revision=step10000-tokens41B
model = OlmoeForCausalLM.from_pretrained("allenai/OLMoE-1B-7B-0125").to(DEVICE)
tokenizer = AutoTokenizer.from_pretrained("allenai/OLMoE-1B-7B-0125")

inputs = tokenizer("Bitcoin is", return_tensors="pt")
inputs = {k: v.to(DEVICE) for k, v in inputs.items()}
out = model.generate(**inputs, max_length=64)
print(tokenizer.decode(out[0]))"



⸻

Open Source Dependencies

This project relies on various open-source libraries, each licensed under the MIT License:
	•	LlamaCPP
Author(s): The ggml authors (2023–2024)
License: MIT
Repository: LlamaCPP
	•	ggml
Author(s): The ggml authors (2023–2024)
License: MIT
Repository: ggml
	•	MarkdownUI
Author(s): Guillermo Gonzalez (2020)
License: MIT
Repository: MarkdownUI
	•	HighlightSwift
Author(s): Stefan Blos
License: MIT
Repository: HighlightSwift

For more details on each license, visit the respective repositories linked above.

⸻

References (Harvard Style)
•Allen Institute for AI (2023) On-Device AI. [Online]. Available at: https://allenai.org/on-device [Accessed 26 March 2025].
•Allen Institute for AI (2023) OLMoE.swift GitHub Repository. [Online]. Available at: https://github.com/allenai/OLMoE.swift?tab=readme-ov-file [Accessed 26 March 2025].
•ryantigi254 (2025) AI-Mental-Health-Chatbot. [Online]. Available at: https://github.com/ryantigi254/AI-Mental-Health-Chatbot.git [Accessed 26 March 2025].

