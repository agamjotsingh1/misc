import config
import torch
import numpy as np

from brain import Brain, BrainConfig
from enumdefs import TileType, Action
from utils import get_id

def encode_tile(tile_type: TileType):
    if tile_type == TileType.VOID:
        return [1.0, 0.0, 0.0, 0.0]
    elif tile_type == TileType.FOOD:
        return [0.0, 1.0, 0.0, 0.0]
    elif tile_type == TileType.AGENT:
        return [0.0, 0.0, 1.0, 0.0]
    else: 
        return [0.0, 0.0, 0.0, 1.0]

class Agent:
    def __init__(self, id: int, spawn_loc: tuple[int, int], brain_cfg: BrainConfig):
        self.id = id
        self.loc = spawn_loc
        self.brain = Brain(brain_cfg)
        self.satiety = config.AGENT_SATIETY

    def perform(self, map: np.typing.NDarray[object], epsilon=0.1, gamma=0.95):
        state = self.get_state(map)

        with torch.no_grad():
            state_tensor = torch.tensor(state, dtype=torch.float32)
            actions = self.brain.forward(state_tensor).numpy()

        if np.random.rand() < epsilon:
            action_idx = np.random.randint(0, len(Action))
        else:
            action_idx = np.argmax(actions)
            
        action = Action(action_idx)

        reward = 0.0
        
        if action == Action.EAT:
            food_loc = self.check_adjacent_type(map, TileType.FOOD)

            if food_loc:
                fy, fx = food_loc
                map[fy, fx].type = TileType.VOID
                self.eat()
                reward = 10.0
            else:
                reward = -2.0 

        elif action == Action.MATE:
            partner_loc = self.check_adjacent_type(map, TileType.AGENT)
            spawn_loc = self.check_adjacent_type(map, TileType.VOID)

            if partner_loc and spawn_loc and self.satiety >= 4:
                cy, cx = spawn_loc
                py, px = partner_loc
                partner_agent = map[py, px].agent
                
                child_id = get_id()
                child = Agent(id=child_id, spawn_loc=(cy, cx), brain_cfg=BrainConfig())
                
                # crossover
                child_state_dict = {}
                self_sd = self.brain.state_dict()
                partner_sd = partner_agent.brain.state_dict()
                
                for key in self_sd:
                    alpha = torch.rand_like(self_sd[key])
                    child_state_dict[key] = alpha * self_sd[key] + (1 - alpha) * partner_sd[key]
                    
                child.brain.load_state_dict(child_state_dict)
                
                target_tile = map[cy, cx]
                target_tile.type = TileType.AGENT
                target_tile.agent = child
                
                self.satiety -= 3
                partner_agent.satiety -= 3
                child.satiety = 6

                reward = 20.0
            else:
                reward = -2.0

        elif action == Action.KILL:
            target_loc = self.check_adjacent_type(map, TileType.AGENT)
            
            if target_loc and self.satiety >= 6:
                ty, tx = target_loc
                target_agent = map[ty, tx].agent 
                map[ty, tx].type = TileType.VOID
                map[ty, tx].agent = None
                
                self.satiety += target_agent.satiety
                reward = 5.0
            else:
                reward = -2.0

        else:
            success = self.move(action, map)

            if not success:
                reward = -2.0
            else:
                reward = 2.0
        
            self.satiety -= 0.1

        if self.satiety <= 0:
            y, x = self.loc
            map[y, x].type = TileType.VOID
            map[y, x].agent = None
            return None

        targets = actions.copy()
        next_state = self.get_state(map)

        with torch.no_grad():
            next_state_tensor = torch.tensor(next_state, dtype=torch.float32)
            next_actions = self.brain.forward(next_state_tensor).numpy()
            
        targets[action_idx] = reward + (gamma * np.max(next_actions))
            
        loss, _ = self.brain.train_step(state, targets)
        return loss, action

    def check_adjacent_type(self, map: np.typing.NDarray[object], target_type: TileType):
        y, x = self.loc
        surrounding_coords = [
            (y-1, x), (y+1, x), (y, x-1), (y, x+1),
            (y-1, x-1), (y-1, x+1), (y+1, x-1), (y+1, x+1)
        ]

        map_size = map.shape
        
        for sy, sx in surrounding_coords:
            if 0 <= sy < map_size[0] and 0 <= sx < map_size[1]:
                if map[sy, sx].type == target_type:
                    return (sy, sx)
        return None

    def get_state(self, map: np.typing.NDarray[object]):
        state = []
        
        y, x = self.loc
        
        surrounding_coords = [
            (y-1, x), (y+1, x), (y, x-1), (y, x+1),
            (y-1, x-1), (y-1, x+1), (y+1, x-1), (y+1, x+1)
        ]

        map_size = map.shape
        
        for y, x in surrounding_coords:
            if 0 <= y < map_size[0] and 0 <= x < map_size[1]:
                tile = map[y, x]
                state.extend(encode_tile(tile.type))
            else:
                state.extend([0.0, 0.0, 0.0, 1.0])

        state.append(self.satiety)
        return state

    def eat(self):
        self.satiety += 1

    def move(self, action: Action, map: np.typing.NDarray[object]):
        y, x = self.loc
        ny, nx = y, x
        
        if action == Action.UP: ny -= 1
        elif action == Action.DOWN: ny += 1
        elif action == Action.LEFT: nx -= 1
        elif action == Action.RIGHT: nx += 1
        
        map_size = map.shape
        
        if 0 <= ny < map_size[0] and 0 <= nx < map_size[1]:
            target_tile = map[ny, nx]
            if target_tile.type == TileType.VOID:
                map[y, x].type = TileType.VOID
                map[y, x].agent = None
                
                target_tile.type = TileType.AGENT
                target_tile.agent = self 
                self.loc = (ny, nx)
                return True

        return False
