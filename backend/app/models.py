from sqlalchemy import Column, Integer, String, Boolean
from .database import Base




class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    role = Column(String, nullable=False, default="customer")
    is_active = Column(Boolean, nullable=False, default=True)
