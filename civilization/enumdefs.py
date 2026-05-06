from enum import Enum, auto

class TileType(Enum):
    VOID = auto()
    FOOD = auto()
    AGENT = auto()

class Action(Enum):
    UP = 0
    DOWN = 1
    LEFT = 2
    RIGHT = 3
    EAT = 4
    MATE = 5
    KILL = 6