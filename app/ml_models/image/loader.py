import os
import torch
from PIL import Image
from torchvision import transforms

from .model_def import CNN

BASE_DIR = os.path.dirname(__file__)  # app/ml_models/image
MODEL_PATH = os.path.join(BASE_DIR, "image_model.pt")

_image_model = None

# نفس إعدادات FER2013 عادة: 48x48 و grayscale
_transform = transforms.Compose([
    transforms.Grayscale(num_output_channels=1),
    transforms.Resize((48, 48)),
    transforms.ToTensor(),
])

def load_image_model():
    global _image_model
    if _image_model is None:


        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        model = CNN().to(device)
        state = torch.load(MODEL_PATH, map_location=device)
        model.load_state_dict(state)
        model.eval()
        _image_model = model
    return _image_model

def predict_image(image_path: str) -> float:
    model = load_image_model()

    img = Image.open(image_path).convert("RGB")
    x = _transform(img).unsqueeze(0)  # (1,1,48,48)

    with torch.no_grad():
        logits = model(x)
        prob = torch.sigmoid(logits).item()  # 0..1
    return float(prob)