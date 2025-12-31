<<<<<<< HEAD
import os
import inspect
import torch


def _guess_init_kwargs(model_class):
    """
    Build kwargs for model_class __init__ if it requires args.
    We guess common names: input_dim/in_features/input_size = 9 (PHQ-9)
                          output_dim/out_features/num_classes = 2
                          hidden_dim/hidden_size = 16
                          dropout = 0.1
    """
    sig = inspect.signature(model_class.__init__)
    params = list(sig.parameters.values())[1:]  # skip self

    kwargs = {}
    for p in params:
        name = p.name.lower()

        # if param has default, we can skip it safely
        if p.default is not inspect._empty:
            continue

        if any(k in name for k in ["input", "in_features", "infeature", "input_dim", "input_size", "n_features"]):
            kwargs[p.name] = 9
        elif any(k in name for k in ["output", "out_features", "outfeature", "num_classes", "classes", "n_classes"]):
            kwargs[p.name] = 2
        elif any(k in name for k in ["hidden", "hidden_dim", "hidden_size"]):
            kwargs[p.name] = 16
        elif "dropout" in name:
            kwargs[p.name] = 0.1
        else:
            # fallback: give a reasonable default
            kwargs[p.name] = 16

    return kwargs


def _extract_state_dict(ckpt):
    """
    Accept various checkpoint formats.
    """
    if isinstance(ckpt, dict):
        for key in ["state_dict", "model_state_dict", "model", "net"]:
            if key in ckpt and isinstance(ckpt[key], dict):
                return ckpt[key]
        # maybe it is already a state_dict
        if all(isinstance(v, torch.Tensor) for v in ckpt.values()):
            return ckpt
    return None


def load_phq9_model(model_class):
    """
    Load PHQ-9 PyTorch model from app/ml_models/phq_9/phq9_model.pt
    """
    base_dir = os.path.dirname(__file__)
    model_path = os.path.join(base_dir, "phq_9", "phq9_model.pt")

    if not os.path.exists(model_path):
        raise FileNotFoundError(f"PHQ9 model file not found: {model_path}")

    device = torch.device("cpu")  # Render safer

    ckpt = torch.load(model_path, map_location=device)

    # If someone saved the whole model object (rare but possible)
    if isinstance(ckpt, torch.nn.Module):
        model = ckpt.to(device)
        model.eval()
        return model

    # Otherwise expect state_dict or dict wrapper
    state_dict = _extract_state_dict(ckpt)
    if state_dict is None:
        raise ValueError("Unsupported checkpoint format in phq9_model.pt")

    # remove possible 'module.' prefix (DataParallel)
    cleaned = {}
    for k, v in state_dict.items():
        nk = k.replace("module.", "")
        cleaned[nk] = v

    # Instantiate model with guessed args if needed
    kwargs = _guess_init_kwargs(model_class)
    model = model_class(**kwargs).to(device)

    # strict=False to avoid crashing if minor mismatch
    model.load_state_dict(cleaned, strict=False)
    model.eval()
    return model
=======
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
>>>>>>> f5d73912113ed64a87078367bec0efb445d58cb8
