"""Database connection and session management"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

# Create engine (optional for testing)
engine = None
SessionLocal = None

try:
    if settings.DATABASE_URL and "postgresql" in settings.DATABASE_URL:
        engine = create_engine(
            settings.DATABASE_URL,
            pool_pre_ping=True,
            echo=settings.DEBUG
        )
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
except Exception as e:
    print(f"Warning: Database connection not available: {e}")
    print("Running in test mode without database")

# Base class for models
Base = declarative_base()


def get_db():
    """Dependency for getting database session"""
    if SessionLocal is None:
        raise Exception("Database not configured. Please set DATABASE_URL in .env")
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

