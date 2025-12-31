import inspect
import torch

from app.ml_models.s3_utils import ensure_model_file


def _guess_init_kwargs(model_class):
    sig = inspect.signature(model_class.__init__)
    params = list(sig.parameters.values())[1:]  # skip self

    kwargs = {}
    for p in params:
        name = p.name.lower()

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
            kwargs[p.name] = 16

    return kwargs


def _extract_state_dict(ckpt):
    if isinstance(ckpt, dict):
        for key in ["state_dict", "model_state_dict", "model", "net"]:
            if key in ckpt and isinstance(ckpt[key], dict):
                return ckpt[key]
        if all(isinstance(v, torch.Tensor) for v in ckpt.values()):
            return ckpt
    return None


def load_phq9_model(model_class):
    """
    Load PHQ-9 model from S3 (download if missing), then torch.load.
    """

    # نجيب الموديل من s3
    model_path = ensure_model_file(
        filename="phq9_model.pt",
        subdir=""
    )

    device = torch.device("cpu")  # Render safer

    ckpt = torch.load(model_path, map_location=device)

    if isinstance(ckpt, torch.nn.Module):
        model = ckpt.to(device)
        model.eval()
        return model

    state_dict = _extract_state_dict(ckpt)
    if state_dict is None:
        raise ValueError("Unsupported checkpoint format in phq9_model.pt")

    cleaned = {k.replace("module.", ""): v for k, v in state_dict.items()}

    kwargs = _guess_init_kwargs(model_class)
    model = model_class(**kwargs).to(device)

    model.load_state_dict(cleaned, strict=False)
    model.eval()
    return model
