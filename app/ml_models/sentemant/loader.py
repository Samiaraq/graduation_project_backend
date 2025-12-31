import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification

from app.ml_models.s3_utils import ensure_model_file

_model = None
_tokenizer = None


def load_sentemant():
    global _model, _tokenizer

    if _model is None or _tokenizer is None:
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
            subdir=""
        )

        state = torch.load(MODEL_PATH, map_location="cpu")
        _model.load_state_dict(state)
        _model.eval()

    return _model, _tokenizer


def load_sent_model():
    return None
