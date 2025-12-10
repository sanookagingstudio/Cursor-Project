import os
from pathlib import Path

from .database import init_db, SessionLocal
from . import models, security
from .routes import router  # re-export for main




def ensure_initial_admin_and_token():
    init_db()
    db = SessionLocal()
    try:
        existing_admin = db.query(models.User).filter(models.User.is_superuser == True).first()  # noqa: E712
        if existing_admin:
            return

        email = os.getenv("AUTH_ADMIN_EMAIL", "admin@example.com")
        password = os.getenv("AUTH_ADMIN_PASSWORD", "Admin1234!")

        user = models.User(
            email=email,
            hashed_password=security.hash_password(password),
            is_active=True,
            is_superuser=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)

        token = security.create_access_token(
            user_id=user.id,
            expires_delta_minutes=int(os.getenv("AUTH_BOOTSTRAP_TOKEN_MINUTES", "43200")),  # 30 days
        )

        base_dir = Path(__file__).resolve().parent.parent  # backend/app
        token_file = base_dir / "admin_token.txt"
        with token_file.open("w", encoding="utf-8") as f:
            f.write(token)
    finally:
        db.close()




ensure_initial_admin_and_token()
