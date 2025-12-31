import torch
from app.ml_models.s3_utils import ensure_model_file


def load_phq9_model(build_model_fn):
    """
    Load PHQ-9 model from S3 (download if missing) and load weights.
    build_model_fn: function that returns a torch.nn.Module
    """

    # تنزيل الموديل من S3 إذا مش موجود
    model_path = ensure_model_file(
        filename="phq9_model.pt",
        subdir="models"
    )

    device = torch.device("cpu")  # Render safer

    # نبني الموديل من نفس الفنكشن الأصلية
    model = build_model_fn().to(device)

    # نحمّل الـ state_dict
    state_dict = torch.load(model_path, map_location=device)

    model.load_state_dict(state_dict, strict=True)
    model.eval()

    return model