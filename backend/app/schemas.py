from typing import Optional

from pydantic import BaseModel, EmailStr, field_validator




class SignupRequest(BaseModel):
    email: EmailStr
    password: str

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v




class LoginRequest(BaseModel):
    email: EmailStr
    password: str




class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"




class UserRead(BaseModel):
    id: int
    email: EmailStr
    role: str

    class Config:
        from_attributes = True
