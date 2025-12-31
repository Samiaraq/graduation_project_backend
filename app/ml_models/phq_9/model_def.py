import torch.nn as nn

class MLP(nn.Module):
    def __init__(self, in_dim: int = 11, num_classes: int = 5):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(in_dim, 16),
            nn.ReLU(),
            nn.Dropout(0.5),

            nn.Linear(16, 8),
            nn.ReLU(),
            nn.Dropout(0.5),

            nn.Linear(8, 4),
            nn.ReLU(),
            nn.Dropout(0.5),

            nn.Linear(4, num_classes),
        )

    def forward(self, x):
        return self.net(x)