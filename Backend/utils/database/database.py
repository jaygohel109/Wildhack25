from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv
from typing import List
import urllib.parse
from bson import ObjectId
from passlib.context import CryptContext
from urllib.parse import quote_plus
import certifi  # Add this import
from .auth_util import hash_password, verify_password
from .model import ProfileCreate
from datetime import datetime
from .tasks_model import TasksRequest
from bson import ObjectId

# Password hashing setup
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Load environment variables
load_dotenv()

# Retrieve environment variables
USERNAME = os.getenv("USERNAME")
PASSWORD = os.getenv("PASSWORD")
DATABASE_URL = os.getenv("DATABASE_URL")

# URL encode the username and password in case there are special characters
USERNAME = quote_plus(USERNAME)
PASSWORD = quote_plus(PASSWORD)

# Update the DATABASE_URL with the encoded username and password
DATABASE_URL = DATABASE_URL.format(username=USERNAME, password=PASSWORD)
print(f"Connecting to MongoDB at: {DATABASE_URL}")

# Initialize MongoDB client with proper SSL configuration
client = AsyncIOMotorClient(
    DATABASE_URL,
    tlsCAFile=certifi.where(),  # Add this parameter
    serverSelectionTimeoutMS=5000  # Optional: sets a timeout for server selection
)
db = client["wildhack"]  # Replace with your database name


async def signup_user(username: str, password: str, role: int) -> dict:
    existing_user = await db["users"].find_one({"username": username})
    if existing_user:
        return {"error": f"User '{username}' already exists."}
    
    hashed_password = hash_password(password)
    user_data = {
        "username": username,
        "password": hashed_password,
        "role": role
    }
    result = await db["users"].insert_one(user_data)
    return {"message": "User created successfully", "id": str(result.inserted_id)}

async def login_user(username: str, password: str) -> dict:
    user = await db["users"].find_one({"username": username})
    if not user:
        return {"error": "Invalid username or password"}

    if not verify_password(password, user["password"]):
        return {"error": "Invalid username or password"}

    return {
        "message": "Login successful",
        "username": user["username"],
        "role": user.get("role", 1),
        "id": str(user["_id"])
    }

async def create_user_profile(profile: ProfileCreate):
    user = await db["users"].find_one({"_id": ObjectId(profile.user_id)})

    if not user:
        return {"error": "User not found"}
    
    if user.get("role") != profile.role:
        return {"error": "User role mismatch"}

    profile_data = profile.dict()
    profile_data["user_id"] = ObjectId(profile.user_id)
    
    result = await db["profiles"].insert_one(profile_data)
    
    return {"message": "Profile created successfully", "profile_id": str(result.inserted_id)}

async def forgot_password(username: str, new_password: str):
    user = await db["users"].find_one({"username": username})
    if not user:
        return {"error": "User does not exist"}

    hashed_password = pwd_context.hash(new_password)
    update_result = await db["users"].update_one(
        {"username": username},
        {"$set": {"password": hashed_password}}
    )

    if update_result.modified_count == 1:
        return {"message": "Password updated successfully"}
    else:
        return {"error": "Password update failed"}

async def create_task(task: TasksRequest):
    task_data = task.dict()
    task_data["created_at"] = datetime.utcnow()
    task_data["status"] = "open"
    task_data["volunteer_id"] = None
    task_data["created_by"] = ObjectId(task_data["created_by"])

    result = await db["tasks"].insert_one(task_data)

    if result.inserted_id:
        return {
            "message": "Task created successfully",
            "task_id": str(result.inserted_id)
        }
    else:
        return {"error": "Task creation failed"}


async def get_matching_tasks(volunteer_id: str):
    volunteer = await db["users"].find_one({"_id": volunteer_id})
    if not volunteer:
        return {"error": "Volunteer not found"}

    skills = volunteer.get("skills", [])

    cursor = db["tasks"].find({
        "category": {"$in": skills},
        "status": {"$in": ["in-progress"]}
    })

    matching_tasks = []
    async for task in cursor:
        task["_id"] = str(task["_id"])
        task["created_by"] = str(task["created_by"])
        print(task.get("volunteer_id"))
        if task.get("volunteer_id"):
            task["volunteer_id"] = str(task["volunteer_id"])
        matching_tasks.append(task)

    return {"matching_tasks": matching_tasks}

async def get_active_tasks_by_user(user_id: str):
    pipeline = [
        {
            "$match": {
                "created_by": ObjectId(user_id),
                "status": {"$in": ["open", "in-progress"]}
            }
        },
        {
            "$lookup": {
                "from": "profiles",
                "let": { "vol_id": "$volunteer_id" },
                "pipeline": [
                    {
                        "$match": {
                            "$expr": { "$eq": ["$user_id", "$$vol_id"] }
                        }
                    }
                ],
                "as": "volunteer_info"
            }
        },
        {
            "$unwind": {
                "path": "$volunteer_info",
                "preserveNullAndEmptyArrays": True
            }
        },
        {
            "$project": {
                "_id": { "$toString": "$_id" },
                "created_by": { "$toString": "$created_by" },
                "issue": 1,
                "status": 1,
                "category": 1,
                "priority": 1,
                "description": 1,
                "volunteer_id": {
                    "$cond": {
                        "if": { "$ifNull": ["$volunteer_id", False] },
                        "then": { "$toString": "$volunteer_id" },
                        "else": None
                    }
                },
                "volunteer": {
                    "name": "$volunteer_info.first_name",
                    "gender": "$volunteer_info.gender"
                }
            }
        }
    ]

    results = await db["tasks"].aggregate(pipeline).to_list(length=None)
    return {"active_tasks": results}

async def get_completed_tasks_by_user(user_id: str):
    pipeline = [
        {
            "$match": {
                "created_by": ObjectId(user_id),
                "status": "completed"
            }
        },
        {
            "$lookup": {
                "from": "profiles",
                "let": { "vol_id": "$volunteer_id" },
                "pipeline": [
                    {
                        "$match": {
                            "$expr": {
                                "$and": [
                                    { "$ne": ["$$vol_id", None] },
                                    { "$eq": ["$user_id", "$$vol_id"] }
                                ]
                            }
                        }
                    }
                ],
                "as": "volunteer_info"
            }
        },
        {
            "$unwind": {
                "path": "$volunteer_info",
                "preserveNullAndEmptyArrays": True
            }
        },
        {
            "$project": {
                "_id": { "$toString": "$_id" },
                "created_by": { "$toString": "$created_by" },
                "issue": 1,
                "status": 1,
                "category": 1,
                "priority": 1,
                "description": 1,
                "volunteer_id": {
                    "$cond": {
                        "if": { "$ifNull": ["$volunteer_id", False] },
                        "then": { "$toString": "$volunteer_id" },
                        "else": None
                    }
                },
                "volunteer": {
                    "$cond": {
                        "if": { "$gt": ["$volunteer_info", None] },
                        "then": {
                            "name": "$volunteer_info.first_name",
                            "gender": "$volunteer_info.gender"
                        },
                        "else": None
                    }
                }
            }
        }
    ]
    results = await db["tasks"].aggregate(pipeline).to_list(length=None)
    return {"completed_tasks": results}

async def assign_task_to_volunteer(task_id: str, volunteer_id: str):
    result = await db["tasks"].update_one(
        {
            "_id": ObjectId(task_id),
            "status": "open"
        },
        {
            "$set": {
                "volunteer_id": ObjectId(volunteer_id),
                "status": "in-progress"
            }
        }
    )

    if result.modified_count == 1:
        return {"message": "Task assigned successfully"}
    else:
        return {"error": "Task could not be assigned (already taken or not found)"}

async def get_task_with_volunteer(task_id: str):
    task = await db["tasks"].find_one({"_id": ObjectId(task_id)})
    if not task:
        return {"error": "Task not found"}

    volunteer = None
    print(task.get("volunteer_id"))
    if task.get("volunteer_id"):
        volunteer = await db["profiles"].find_one({"user_id": ObjectId(task["volunteer_id"])})
    print(volunteer)
    return {
        "task": {
            "issue": task["issue"],
            "status": task["status"],
            "category": task["category"],
            "priority": task["priority"],
            "description": task["description"]
        },
        "volunteer": {
            "name": volunteer["first_name"],
            "gender": volunteer["gender"]
        } if volunteer else None
    }
    
async def complete_task(task_id: str):
    result = await db["tasks"].update_one(
        {
            "_id": ObjectId(task_id),
            "status": "in-progress"
        },
        {
            "$set": {
                "status": "completed"
            }
        }
    )

    if result.modified_count == 1:
        return {"message": "Task completed successfully"}
    else:
        return {"error": "Task could not be completed (already taken or not found)"}