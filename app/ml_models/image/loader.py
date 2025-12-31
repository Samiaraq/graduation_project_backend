import os
import torch
from PIL import Image
from torchvision import transforms

<<<<<<< HEAD
from .model_def import CNN

BASE_DIR = os.path.dirname(__file__)  # app/ml_models/image
MODEL_PATH = os.path.join(BASE_DIR, "image_model.pt")

=======
from app.ml_models.s3_utils import ensure_model_file
from .model_def import CNN

>>>>>>> f5d73912113ed64a87078367bec0efb445d58cb8
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

<<<<<<< HEAD

        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

=======
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        #نجيب الموديل من s3
        MODEL_PATH = ensure_model_file(
            filename="best_model.pt",
            subdir="models"
        )

>>>>>>> f5d73912113ed64a87078367bec0efb445d58cb8
        model = CNN().to(device)
        state = torch.load(MODEL_PATH, map_location=device)
        model.load_state_dict(state)
        model.eval()
<<<<<<< HEAD
        _image_model = model
    return _image_model

=======

        _image_model = model

    return _image_model


>>>>>>> f5d73912113ed64a87078367bec0efb445d58cb8
def predict_image(image_path: str) -> float:
    model = load_image_model()

    img = Image.open(image_path).convert("RGB")
    x = _transform(img).unsqueeze(0)  # (1,1,48,48)

    with torch.no_grad():
        logits = model(x)
        prob = torch.sigmoid(logits).item()  # 0..1
<<<<<<< HEAD
    return float(prob)
=======

    return float(prob)
>>>>>>> f5d73912113ed64a87078367bec0efb445d58cb8
