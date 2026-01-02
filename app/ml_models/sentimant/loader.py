import os
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification

BASE_DIR = os.path.dirname(__file__)
MODEL_PATH = os.path.join(BASE_DIR, "SentemantAnalysis.pt")
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification

from app.ml_models.s3_utils import ensure_model_file

_model = None
_tokenizer = None

def load_sentemant():
    global _model, _tokenizer

    if _model is None or _tokenizer is None:
        # same base model used in training
        _tokenizer = AutoTokenizer.from_pretrained("aubmindlab/bert-base-arabertv02")

        # tokenizer
        _tokenizer = AutoTokenizer.from_pretrained(
            "aubmindlab/bert-base-arabertv02"
        )

        # base model
        _model = AutoModelForSequenceClassification.from_pretrained(
            "aubmindlab/bert-base-arabertv02",
            num_labels=2
        )

        #نجيب الموديل من s3
        MODEL_PATH = ensure_model_file(
            filename="SentemantAnalysis.pt",
            subdir="models"
        )

        state = torch.load(MODEL_PATH, map_location="cpu")
        # حماية لو كان محفوظ بطريقة مختلفة
        if isinstance(state, dict) and "state_dict" in state:
            state = state["state_dict"]
        if isinstance(state, dict):
            state = {k.replace("module.", ""): v for k, v in state.items()}

        _model.load_state_dict(state , strict=True)
        _model.eval()

    return _model, _tokenizer


def load_sent_model():
    load_sentemant()
    return None
