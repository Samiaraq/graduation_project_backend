import os
import torch

BASE_DIR = os.path.dirname(__file__)  # app/ml_models
MODEL_PATH = os.path.join(BASE_DIR, "phq_9", "phq9_model.pt")

phq9_model = None

def load_phq9_model(model_class):
    global phq9_model
    if phq9_model is None:
        phq9_model = model_class()
        phq9_model.load_state_dict(torch.load(MODEL_PATH, map_location="cpu"))
        phq9_model.eval()
    return phq9_model