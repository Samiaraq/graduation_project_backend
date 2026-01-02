import torch
import numpy as np
from app.ml_models.s3_utils import ensure_model_file

# نخليهم global عشان نستخدمهم وقت التنبؤ
_phq_model = None
_phq_scaler_mean = None
_phq_scaler_scale = None


def load_phq9_model(model_class):
    global _phq_model, _phq_scaler_mean, _phq_scaler_scale

    if _phq_model is not None:
        return _phq_model

    model_path = ensure_model_file(
        filename="phq9_model.pt",
        subdir="models"
    )

    device = torch.device("cpu")
    ckpt = torch.load(model_path, map_location=device)

    # نتأكد إنو الملف فيه كل اللي بدنا إياه
    if not all(k in ckpt for k in ["state_dict", "scaler_mean", "scaler_scale"]):
        raise ValueError("phq9_model.pt missing scaler or state_dict")

    state_dict = ckpt["state_dict"]
    _phq_scaler_mean = np.array(ckpt["scaler_mean"], dtype=np.float32)
    _phq_scaler_scale = np.array(ckpt["scaler_scale"], dtype=np.float32)

    cleaned = {k.replace("module.", ""): v for k, v in state_dict.items()}

    model = model_class(in_dim=11, num_classes=5).to(device)
    model.load_state_dict(cleaned, strict=True)
    model.eval()

    _phq_model = model
    return _phq_model


def scale_phq_input(x_np):
    """
    x_np: numpy array shape (1, 11)
    """
    return (x_np - _phq_scaler_mean) / _phq_scaler_scale