import torch
import torch.nn as nn
import torch.optim as optim
from dataclasses import dataclass

import config

@dataclass
class BrainConfig:
    input_dim: int = config.BRAIN_INPUT_DIM
    hidden_dim: int = config.BRAIN_HIDDEN_DIM
    output_dim: int = config.BRAIN_OUTPUT_DIM
    lr: float = config.BRAIN_LR

class Brain(nn.Module):
    def __init__(self, brain_cfg: BrainConfig):
        super(Brain, self).__init__()
        self.cfg = brain_cfg
        self.fc1 = nn.Linear(brain_cfg.input_dim, brain_cfg.hidden_dim)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(brain_cfg.hidden_dim, brain_cfg.output_dim)
        
        self.optimizer = optim.Adam(self.parameters(), lr=brain_cfg.lr)
        self.criterion = nn.MSELoss()

    def forward(self, x):
        out = self.fc1(x)
        out = self.relu(out)
        out = self.fc2(out)
        return out

    def train_step(self, input, target):
        self.train()
        
        state_tensor = torch.tensor(input, dtype=torch.float32)
        target_tensor = torch.tensor(target, dtype=torch.float32)

        predictions = self.forward(state_tensor)
        loss = self.criterion(predictions, target_tensor)
        
        self.optimizer.zero_grad()
        loss.backward()
        self.optimizer.step()
        
        return loss.item(), predictions.detach().numpy()