"""
Database Connection Module
Handles MySQL database connections and session management
"""
from fastapi import FastAPI
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.exc import SQLAlchemyError
from config import DATABASE_URL, DB_CONFIG, SQLALCHEMY_POOL_SIZE, SQLALCHEMY_MAX_OVERFLOW

# SQLAlchemy Setup (if using ORM with FastAPI/Flask)
engine = create_engine(
    DATABASE_URL,
    pool_size=SQLALCHEMY_POOL_SIZE,
    max_overflow=SQLALCHEMY_MAX_OVERFLOW,
    pool_pre_ping=True,  # Verify connection before using
    echo=False
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """
    Dependency for getting database session in FastAPI
    Usage in route: def read_items(db: Session = Depends(get_db))
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def create_tables():
    """Create all tables defined in models"""
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Database tables created successfully")
    except SQLAlchemyError as e:
        print(f"❌ Error creating tables: {e}")


if __name__ == "__main__":
    # Create tables when running directly
    get_db()
