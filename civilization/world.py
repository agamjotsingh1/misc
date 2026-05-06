import numpy as np

from agent import Agent
from brain import BrainConfig
from enumdefs import TileType
from utils import get_id

class Tile:
    def __init__(self, tile_type: TileType, agent: Agent = None):
        self.type = tile_type
        self.agent = agent
        
        if self.type == TileType.VOID:
            self.id = -1
        else:
            self.id = get_id()

    def __repr__(self):
        return f"{self.type.name}_{self.id}"

class World:
    def __init__(self, map_size: tuple[int, int], seed: int, num_agents: int, num_food: int):
        self.map_size = map_size
        self.seed = seed
        self.num_agents = num_agents
        self.num_food = num_food
        self.rng = np.random.default_rng(self.seed)
        self.default_brain_cfg = BrainConfig()
        
        self.init_map()

    def init_map(self):
        rows, cols = self.map_size
        
        self.map = np.array(
            [[Tile(TileType.VOID) for _ in range(cols)] for _ in range(rows)], 
            dtype=object
        )

        self.spawn_tiles(self.num_agents, TileType.AGENT)
        self.spawn_tiles(self.num_food, TileType.FOOD)

    def spawn_tiles(self, count: int, tile_type: TileType):
        is_void = np.vectorize(lambda tile: tile.type == TileType.VOID)
        empty_indices = np.argwhere(is_void(self.map))
        
        if len(empty_indices) < count:
            raise ValueError(f"Cannot spawn {count} items; only {len(empty_indices)} spaces available.")

        chosen_indices = self.rng.choice(len(empty_indices), size=count, replace=False)
        coords = empty_indices[chosen_indices]

        for y, x in coords:
            tile = Tile(tile_type)
            
            if tile_type == TileType.AGENT:
                tile.agent = Agent(
                    id=tile.id, 
                    spawn_loc=(y, x), 
                    brain_cfg=self.default_brain_cfg
                )
                
            self.map[y, x] = tile

    def replenish_food(self, amount: int):
        is_void = np.vectorize(lambda tile: tile.type == TileType.VOID)
        empty_indices = np.argwhere(is_void(self.map))
        
        actual_amount = min(amount, len(empty_indices))
        if actual_amount == 0:
            return

        chosen_indices = self.rng.choice(len(empty_indices), size=actual_amount, replace=False)
        coords = empty_indices[chosen_indices]

        for y, x in coords:
            self.map[y, x] = Tile(TileType.FOOD)

if __name__ == "__main__":
    world = World(map_size=(9, 9), seed=42, num_agents=10, num_food=20)
    print(world.map)