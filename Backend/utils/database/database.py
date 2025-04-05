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
from .model import User

              
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