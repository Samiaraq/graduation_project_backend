import os
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification

BASE_DIR = os.path.dirname(__file__)
MODEL_PATH = os.path.join(BASE_DIR, "SentemantAnalysis.pt")

_model = None
_tokenizer = None

def load_sentemant():
    global _model, _tokenizer

    if _model is None or _tokenizer is None:
        # same base model used in training
        _tokenizer = AutoTokenizer.from_pretrained("aubmindlab/bert-base-arabertv02")

        _model = AutoModelForSequenceClassification.from_pretrained(
            "aubmindlab/bert-base-arabertv02",
            num_labels=2
        )

        state = torch.load(MODEL_PATH, map_location="cpu")
        _model.load_state_dict(state)
        _model.eval()

    return _model, _tokenizer


def load_sent_model():
    return None