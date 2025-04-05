# app/models.py

from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import date


class User(BaseModel):
    id: Optional[str]  # For MongoDB, we'll use string as object ID
    username: str
    password: str
    role: int = Field(default=1)  # Default role is 1 (Senior citizen)

class UserCreateRequest(BaseModel):
    username: str
    password: str

class LoginRequest(BaseModel):
    username: str
    password: str

class SignupRequest(BaseModel):
    username: str = Field(..., description="Email or phone number")
    password: str = Field(..., min_length=6)
    role: int = Field(..., ge=1, le=3)  # 1 = senior citizen, 2 = volenteer, 3 = admin

class Availability(BaseModel):
    day: str
    from_time: str  # e.g., "12:00 PM"
    to_time: str    # e.g., "5:00 PM"

class ProfileCreate(BaseModel):
    user_id: str
    role: int
    first_name: str
    last_name: str
    phone: str
    email: Optional[str] = None
    dob: Optional[str] = None  # YYYY-MM
    
    # For seniors (role 1)
    preference: Optional[List[Availability]] = None
    
    # For volunteers (role 2)
    skills: Optional[List[str]] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    availability: Optional[List[Availability]] = None

    
class ForgotPasswordRequest(BaseModel):
    username: str
    new_password: str