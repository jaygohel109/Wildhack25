from pydantic import BaseModel
from enum import Enum
from typing import Optional, List
from enum import IntEnum

class Priority(str, Enum):
    urgent = "urgent"
    intermediate = "intermediate"
    normal = "normal"

class Gender(str, Enum):
    male = "male"
    female = "female"

class Category(IntEnum):
    TECH_HELP = 1
    TRANSPORTATION = 2
    HOME_REPAIRS = 3
    COMPANIONSHIP = 4
    GROCERY_SUPPORT = 5
    OTHER = 6

class TasksRequest(BaseModel):
    issue: str
    priority: Priority
    preferable_gender: Gender
    description: str
    category: Optional[Category] = None
    status: str = "open"
    created_by: str  # required to embed into correct user
    
class AssignTasks(BaseModel):
    task_id: str
    volunteer_id: str
