import time
import os
import numpy as np

from world import World
from enumdefs import TileType
from agent import Action
import config

class Colors:
    RESET = '\033[0m'
    DARK_GRAY = '\033[90m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    CYAN = '\033[96m'
    RED = '\033[91m'
    WHITE = '\033[97m'

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def print_map(world_map: np.typing.NDarray[object]):
    rows, cols = world_map.shape
    
    for r in range(rows):
        row_str = ""
        for c in range(cols):
            tile = world_map[r, c]
            
            if tile.type == TileType.VOID:
                row_str += f"{Colors.DARK_GRAY}.{Colors.RESET} "
            elif tile.type == TileType.FOOD:
                row_str += f"{Colors.GREEN}*{Colors.RESET} "
            elif tile.type == TileType.AGENT:
                agent = tile.agent
                last_act = getattr(agent, 'last_action', None)
                
                if last_act == Action.EAT:
                    row_str += f"{Colors.YELLOW}F{Colors.RESET} "
                elif last_act == Action.UP:
                    row_str += f"{Colors.CYAN}^{Colors.RESET} "
                elif last_act == Action.DOWN:
                    row_str += f"{Colors.CYAN}v{Colors.RESET} "
                elif last_act == Action.LEFT:
                    row_str += f"{Colors.CYAN}<{Colors.RESET} "
                elif last_act == Action.RIGHT:
                    row_str += f"{Colors.CYAN}>{Colors.RESET} "
                elif last_act == Action.MATE:
                    row_str += f"{Colors.CYAN}M{Colors.RESET} "
                elif last_act == Action.KILL:
                    row_str += f"{Colors.RED}K{Colors.RESET} "
                else:
                    row_str += f"{Colors.WHITE}@{Colors.RESET} "
        print(row_str)

def run_simulation(steps: int = 200, delay: float = 0.7):
    world = World(
        map_size=config.MAP_SIZE,
        seed=config.SEED,
        num_agents=config.NUM_AGENTS,
        num_food=config.NUM_FOOD
    )

    for step in range(steps):
        clear_screen()
        print(f"--- Step {step + 1}/{steps} ---")
        
        if step > 0 and step % config.FOOD_SPAWN_INTERVAL == 0:
            world.replenish_food(config.FOOD_SPAWN_AMOUNT)

        agents = []
        for row in world.map:
            for tile in row:
                if tile.type == TileType.AGENT and tile.agent is not None:
                    agents.append(tile.agent)

        total_loss = 0.0
        valid_agents_count = 0
        
        for agent in agents:
            result = agent.perform(world.map)
            
            if result is not None:
                try:
                    loss, action = result
                    agent.last_action = action
                    total_loss += loss
                    valid_agents_count += 1
                except ValueError:
                    loss = result
                    total_loss += loss
                    valid_agents_count += 1

        print_map(world.map)
        
        active_agents = sum(1 for row in world.map for t in row if t.type == TileType.AGENT)
        remaining_food = sum(1 for row in world.map for t in row if t.type == TileType.FOOD)
        avg_loss = total_loss / valid_agents_count if valid_agents_count > 0 else 0.0
        
        print(f"\nActive Agents: {active_agents}")
        print(f"Remaining Food: {remaining_food}")
        print(f"Average Loss:  {avg_loss:.4f}")
        
        if active_agents == 0:
            print("\nAll agents have died. Simulation terminated.")
            break
            
        time.sleep(delay)

if __name__ == "__main__":
    try:
        run_simulation()
    except KeyboardInterrupt:
        print("\nSimulation interrupted by user.")