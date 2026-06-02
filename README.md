# PromptLinks 🚀

IMPORTANT: This repository is a lightweight demo created for a blog post — it is NOT a published library or a production-ready package. The code and datasets are intended for demonstration and experimentation only. Do not use embedded secrets; all keys should be provided via environment variables or secret managers.

`promptlinks` is an ultra-lightweight Python demo that shows how long, repetitive, or noisy Markdown URLs can be compressed into compact numeric short codes (e.g., `[Label](=1#3)`).

It demonstrates bijective mapping, a simple hallucination-detection audit for generated text, and an extensible decoding approach suitable for instructional purposes.

---

## ⚖️ The Problem: Token Bloat in RAG Pipelines

When building Retrieval-Augmented Generation (RAG) applications—especially in domains like legal-tech, medicine, or compliance—retrieved context chunks often contain deep, structural, and heavily parameterized URLs.

Injecting dozens of these raw URLs into an LLM prompt introduces severe drawbacks:

1. **Context Bloat:** Long URLs consume massive amounts of precious context window tokens.
2. **Attention Contamination:** High-frequency, noisy URL text distracts the model's inner attention mechanism from actual semantic content.
3. **Mutilation & Hallucination:** LLMs frequently fail to reproduce long URLs exactly as provided, causing broken or dead links in production user interfaces.

---

## 🛠️ The Solution: Bijective Short-Coding

`promptlinks` addresses this by performing deterministic, stateful bidirectional mapping before sending payloads to the LLM:

* **Base URLs** map to simple IDs: `=1`, `=2`
* **Fragment Identifiers** map to short sub-IDs: `=1#1`, `=1#2`

```markdown
Check the rules under [Section 92](/SK/ZZ/2001/311#paragraf-92.odsek-1) and [Section 92(2)](/SK/ZZ/2001/311#paragraf-92.odsek-2.pismeno-a).

Check the rules under [Section 92](=1#1) and [Section 92(2)](=1#2).

```

Once the LLM generates its response utilizing these highly compressed short codes, `promptlinks` transparently decodes them back into full, original URLs while auditing the output for any hallucinations.

---

## 📦 Installation (Demo only)

This repository is intended for demo and blog usage. It is not packaged for distribution. To run the examples locally, clone the repo and install dependencies in a virtual environment. Do NOT commit API keys to the repository — use environment variables or your platform's secret store.

```bash
git clone https://github.com/yourusername/promptlinks.git
cd promptlinks
python -m venv .venv
.\.venv\Scripts\Activate.ps1  # PowerShell on Windows
python -m pip install -r pyproject.toml
```

If you only want to view the demonstration without running LLM calls, open `demo.ipynb` and skip cells that require API access.

---

## 🚀 Quick Start & Full-Cycle Evaluation

A fully functional, cell-by-cell demonstration using `litellm` and Google AI Studio's **Gemini 3.5 Flash** is available in the `demo.ipynb` notebook.

### Basic Usage (demo snippet)

The following is a minimal demo of how the short-coding flow works. This is for illustrative purposes only — do not ship hard-coded secrets or rely on this as a production library.

```python
from uri_shortener import UriShortener

shortener = UriShortener()

# Compress a prompt containing a long link (demo only)
raw_prompt = "Review the guidelines in [TOS Article 4](/legal/terms-of-service#article-4.liability-limitations)."
compressed_prompt = shortener.encode_text(raw_prompt)
print(compressed_prompt)  # e.g. "Review the guidelines in [TOS Article 4](=1#1)."

# After running through an LLM pipeline that references short codes,
# decode back into full URLs for your frontend (verify outputs first)
final_output = shortener.decode_text(compressed_prompt)
print(final_output)
```

---

## 📈 Scalability Metrics

While savings on simple prompts look modest, the token-reduction behavior shown here is illustrative. The numbers below are from synthetic examples in the demo and are meant to communicate the shape of the savings rather than guarantee production results. Evaluate performance in your own workload before making architectural decisions.

| Metric | Raw Context | PromptLinks Compressed | Optimization Gain |
| --- | --- | --- | --- |
| **Token Count** | ~1,200 tokens | ~350 tokens | **~50% Reduction** |
| **Systemic Overhead** | Heavy | Minimal | **Faster Time-to-First-Token (TTFT)** |

---

## 🔧 Extensibility

LLMs executing under high creative temperatures can emit syntax or formatting anomalies. The `UriShortener` implementation included in this demo is intentionally minimal and intended to illustrate concepts; it is not hardened for production edge cases.

Before using any of these techniques in production, add robust validation, unit tests, and domain-specific sanitization to ensure safety and correctness. The example below demonstrates a simple heuristic for repairing some common bracket-truncation patterns, but it is not exhaustive.

```python
import re

def custom_extended_decoder(text: str, shortener_instance: UriShortener) -> str:
    # Pre-process: Heal common bracket truncation patterns
    repaired_text = re.sub(r"\[([^\]]+)\]=([^\s\n]+)", r"[\1](\2)", text)
    
    # Process through core decoder
    return shortener_instance.decode_text(repaired_text)

```

---

## 📄 License

This project is open-source and available under the [MIT License](https://www.google.com/search?q=LICENSE).

## 🔒 Security & Secrets (Important)

- This repository is a demo for a blog post — do not commit API keys, credentials, or other secrets to the repository.
- Use environment variables, secret managers, or CI secret stores for runtime credentials. The `demo.ipynb` shows an interactive prompt for setting `GEMINI_API_KEY`; remove any hard-coded keys before publishing or sharing.
- If secrets are accidentally committed, rotate them immediately and follow the steps in this repo to scrub history or contact your provider and Git hosting support.

## Contributing & Contact

- Contributions, ideas, and suggestions are very welcome — this demo was created for a blog post and benefits from community feedback.
- To contribute:
  - Fork the repo and create a feature branch: `git checkout -b my-feature`.
  - Add tests for new functionality and document changes.
  - Open a pull request describing the motivation and changes.
- For issues, feature requests, or to share ideas, please open a GitHub Issue on this repository.
- If you prefer direct contact, add your preferred contact method in a new Issue and I'll follow up.

Thank you for taking an interest — contributions make demos like this more useful for everyone.
