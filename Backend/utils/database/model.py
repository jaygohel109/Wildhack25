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
    
class ForgotPasswordRequest(BaseModel):
    username: str
    new_password: str