<<<<<<< HEAD
import os
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification

BASE_DIR = os.path.dirname(__file__)
MODEL_PATH = os.path.join(BASE_DIR, "SentemantAnalysis.pt")
=======
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification

from app.ml_models.s3_utils import ensure_model_file
>>>>>>> f5d73912113ed64a87078367bec0efb445d58cb8

_model = None
_tokenizer = None

<<<<<<< HEAD
=======

>>>>>>> f5d73912113ed64a87078367bec0efb445d58cb8
def load_sentemant():
    global _model, _tokenizer

    if _model is None or _tokenizer is None:
<<<<<<< HEAD
        # same base model used in training
        _tokenizer = AutoTokenizer.from_pretrained("aubmindlab/bert-base-arabertv02")

=======
        # tokenizer
        _tokenizer = AutoTokenizer.from_pretrained(
            "aubmindlab/bert-base-arabertv02"
        )

        # base model
>>>>>>> f5d73912113ed64a87078367bec0efb445d58cb8
        _model = AutoModelForSequenceClassification.from_pretrained(
            "aubmindlab/bert-base-arabertv02",
            num_labels=2
        )

<<<<<<< HEAD
=======
        #نجيب الموديل من s3
        MODEL_PATH = ensure_model_file(
            filename="SentemantAnalysis.pt",
            subdir="mdels"
        )

>>>>>>> f5d73912113ed64a87078367bec0efb445d58cb8
        state = torch.load(MODEL_PATH, map_location="cpu")
        _model.load_state_dict(state)
        _model.eval()

    return _model, _tokenizer


def load_sent_model():
<<<<<<< HEAD
    return None
=======
    return None
>>>>>>> f5d73912113ed64a87078367bec0efb445d58cb8
