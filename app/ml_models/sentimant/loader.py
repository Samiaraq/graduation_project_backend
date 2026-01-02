import os
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from app.ml_models.s3_utils import ensure_model_file

_model = None
_tokenizer = None
_loading = False

# (اختياري) كاش HuggingFace على Render Disk لو موجود
HF_CACHE_DIR = os.getenv("HF_HOME", "/opt/render/project/data/hf_cache")
os.makedirs(HF_CACHE_DIR, exist_ok=True)

def load_sentemant():
    global _model, _tokenizer, _loading

    # إذا محمّل قبل -> رجّع مباشرة
    if _model is not None and _tokenizer is not None:
        return _model, _tokenizer

    # حماية من التحميل المتزامن
    if _loading:
        raise RuntimeError("Sentiment model is loading, try again.")

    _loading = True
    try:
        # 1) تحميل tokenizer + base model
        _tokenizer = AutoTokenizer.from_pretrained(
            "aubmindlab/bert-base-arabertv02",
            cache_dir=HF_CACHE_DIR
        )

        _model = AutoModelForSequenceClassification.from_pretrained(
            "aubmindlab/bert-base-arabertv02",
            num_labels=2,
            cache_dir=HF_CACHE_DIR
        )

        # 2) تنزيل weights من S3 (✅ صححي subdir)
        model_path = ensure_model_file(
            filename="SentemantAnalysis.pt",
            subdir="models"
        )

        state = torch.load(model_path, map_location="cpu")
        _model.load_state_dict(state, strict=False)
        _model.eval()
        _model.to("cpu")

        return _model, _tokenizer

    finally:
        _loading = False


# خليها موجودة عشان لو في مكان بالمشروع بستدعيها
def load_sent_model():
    return load_sentemant()