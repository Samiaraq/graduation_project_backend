import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from app.ml_models.s3_utils import ensure_model_file

_model = None
_tokenizer = None

def load_sentemant():
    global _model, _tokenizer

    if _model is None or _tokenizer is None:
        _tokenizer = AutoTokenizer.from_pretrained("aubmindlab/bert-base-arabertv02")

        _model = AutoModelForSequenceClassification.from_pretrained(
            "aubmindlab/bert-base-arabertv02",
            num_labels=2
        )

        MODEL_PATH = ensure_model_file(
            filename="SentemantAnalysis.pt",
            subdir="models"
        )

        state = torch.load(MODEL_PATH, map_location="cpu")

        # لو محفوظ داخل dict باسم state_dict
        if isinstance(state, dict) and "state_dict" in state:
            state = state["state_dict"]

        # لو محفوظ من DataParallel
        if isinstance(state, dict):
            state = {k.replace("module.", ""): v for k, v in state.items()}

        _model.load_state_dict(state, strict=True)
        _model.eval()

    return _model, _tokenizer


def load_sent_model():
    # نخليه موجود بس ما بنستخدمه
    return None