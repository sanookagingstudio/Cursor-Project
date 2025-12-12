from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from . import models, schemas, security
from .database import get_db

router = APIRouter(prefix="/auth", tags=["auth"])




@router.post("/init-admin", response_model=schemas.UserRead)
def init_admin(payload: schemas.UserCreate, db: Session = Depends(get_db)):
    existing_admin = db.query(models.User).filter(models.User.is_superuser == True).first()  # noqa: E712
    if existing_admin:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Admin already initialized",
        )
    existing_user = db.query(models.User).filter(models.User.email == payload.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this email already exists",
        )
    user = models.User(
        email=payload.email,
        hashed_password=security.hash_password(payload.password),
        is_active=True,
        is_superuser=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user




@router.post("/login")
def login(payload: schemas.UserLogin, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == payload.email).first()
    if not user or not security.verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect email or password",
        )
    token = security.create_access_token(user_id=user.id)
    return {"access_token": token, "token_type": "bearer"}




@router.get("/me", response_model=schemas.UserRead)
def read_me(current_user: models.User = Depends(security.get_current_user)):
    return current_user




@router.post("/promote", response_model=schemas.UserRead)
def promote_user(
    payload: schemas.PromoteUserRequest,
    db: Session = Depends(get_db),
    _: models.User = Depends(security.get_current_active_superuser),
):
    user = db.query(models.User).filter(models.User.email == payload.email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    user.is_superuser = payload.is_superuser
    db.add(user)
    db.commit()
    db.refresh(user)
    return user












