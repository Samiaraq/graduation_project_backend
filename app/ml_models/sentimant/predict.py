import torch
from .loader import load_sentemant

def predict_depression_text(text: str):
    model, tokenizer = load_sentemant()

    enc = tokenizer(
        text,
        return_tensors="pt",
        padding=True,
        truncation=True,
        max_length=128
    )
    enc = {k: v.to("cpu") for k, v in enc.items()}

    # ✅ احتياط: بعض الموديلات ما بدها token_type_ids
    if "token_type_ids" in enc:
        enc.pop("token_type_ids")

    with torch.no_grad():
        out = model(**enc)
        pred = torch.argmax(out.logits, dim=1).item()

    return "depression user" if pred == 1 else "not depression user"