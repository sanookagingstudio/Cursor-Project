from pydantic import BaseModel, EmailStr




class UserBase(BaseModel):
    email: EmailStr




class UserCreate(UserBase):
    password: str




class UserLogin(UserBase):
    password: str




class UserRead(UserBase):
    id: int
    is_active: bool
    is_superuser: bool

    class Config:
        from_attributes = True




class PromoteUserRequest(BaseModel):
    email: EmailStr
    is_superuser: bool = True
