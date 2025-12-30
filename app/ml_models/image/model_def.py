import torch.nn as nn

class CNN(nn.Module):
    def __init__(self):
        super().__init__()

        def block(in_ch, out_ch):
            return nn.Sequential(
                nn.Conv2d(in_ch, out_ch, 3, padding=1),
                nn.LeakyReLU(inplace=True),
                nn.BatchNorm2d(out_ch),
            )

        self.features = nn.Sequential(
            block(1, 64),
            block(64, 64),
            nn.MaxPool2d(2),
            nn.Dropout(0.3),

            block(64, 128),
            block(128, 128),
            nn.MaxPool2d(2),
            nn.Dropout(0.4),

            block(128, 256),
            block(256, 256),
            nn.MaxPool2d(2),
            nn.Dropout(0.5),

            nn.AdaptiveAvgPool2d((1, 1))
        )

        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(256, 256),
            nn.LeakyReLU(inplace=True),
            nn.BatchNorm1d(256),
            nn.Dropout(0.5),
            nn.Linear(256, 1)
        )

    def forward(self, x):
        x = self.features(x)
        x = self.classifier(x)
        return x