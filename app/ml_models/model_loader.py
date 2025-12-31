import torch
from app.ml_models.s3_utils import ensure_model_file

def load_phq9_model(model_class):
    model_path = ensure_model_file(
        filename="phq9_model.pt",
        subdir="models"   # هذا لملف التخزين محلياً فقط
    )

    device = torch.device("cpu")
    ckpt = torch.load(model_path, map_location=device)

    # إذا الملف مخزن كموديل كامل
    if isinstance(ckpt, torch.nn.Module):
        model = ckpt.to(device)
        model.eval()
        return model

    # إذا الملف مخزن كـ state_dict
    if isinstance(ckpt, dict) and "state_dict" in ckpt:
        state_dict = ckpt["state_dict"]
    elif isinstance(ckpt, dict) and all(hasattr(v, "shape") for v in ckpt.values()):
        state_dict = ckpt
    else:
        raise ValueError("Unsupported checkpoint format in phq9_model.pt")

    # شيل module. إذا كان محفوظ من DataParallel
    cleaned = {k.replace("module.", ""): v for k, v in state_dict.items()}

    # ✅ لازم نفس أبعاد التدريب: 11 inputs, 5 classes
    model = model_class(in_dim=11, num_classes=5).to(device)
    model.load_state_dict(cleaned, strict=True)
    model.eval()
    return model