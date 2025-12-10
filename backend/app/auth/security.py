import base64
import hashlib
import hmac
import os
import time
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from .database import get_db
from . import models

SECRET_KEY = os.getenv("AUTH_SECRET_KEY", "CHANGE_ME_AUTH_SECRET_KEY")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("AUTH_ACCESS_TOKEN_EXPIRE_MINUTES", "60"))

security = HTTPBearer()




def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode("utf-8")).hexdigest()




def verify_password(plain: str, hashed: str) -> bool:
    return hash_password(plain) == hashed




def create_access_token(user_id: int, expires_delta_minutes: Optional[int] = None) -> str:
    if expires_delta_minutes is None:
        expires_delta_minutes = ACCESS_TOKEN_EXPIRE_MINUTES
    expire = int(time.time()) + expires_delta_minutes * 60
    payload = f"{user_id}:{expire}".encode("utf-8")
    signature = hmac.new(SECRET_KEY.encode("utf-8"), payload, hashlib.sha256).digest()
    token = base64.urlsafe_b64encode(payload + b"." + signature).decode("utf-8")
    return token




def decode_token(token: str) -> int:
    try:
        raw = base64.urlsafe_b64decode(token.encode("utf-8"))
        payload, signature = raw.rsplit(b".", 1)
        expected_sig = hmac.new(SECRET_KEY.encode("utf-8"), payload, hashlib.sha256).digest()
        if not hmac.compare_digest(signature, expected_sig):
            raise ValueError("Invalid signature")
        user_id_str, exp_str = payload.decode("utf-8").split(":")
        exp = int(exp_str)
        if time.time() > exp:
            raise ValueError("Token expired")
        return int(user_id_str)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )




def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> models.User:
    token = credentials.credentials
    user_id = decode_token(token)
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Inactive or missing user",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user




def get_current_active_superuser(current_user: models.User = Depends(get_current_user)) -> models.User:
    if not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions",
        )
    return current_user






