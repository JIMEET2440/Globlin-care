"""
Database Models (ORM)
Define your database tables as Python classes using SQLAlchemy
"""
from sqlalchemy import Column, Integer, String, DateTime, Float, Boolean, Text
from sqlalchemy.sql import func
from database import Base


class Customer(Base):
    """Customer table model"""

    __tablename__ = "customers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False)
    phone = Column(String(15), nullable=False, unique=True)
    area = Column(String(30), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    # created_at = Column(DateTime(timezone=True), server_default=func.now())
    # updated_at = Column(DateTime(timezone=True), onupdate=func.now())


# class Sales(Base):
#     """Sales transaction table model"""
#     __tablename__ = "sales"
    
#     id = Column(Integer, primary_key=True, index=True)
#     customer_id = Column(Integer, nullable=False)
#     product_name = Column(String(255), nullable=False)
#     quantity = Column(Integer, nullable=False)
#     price = Column(Float, nullable=False)
#     total_amount = Column(Float, nullable=False)
#     sale_date = Column(DateTime(timezone=True), server_default=func.now())
#     notes = Column(Text)
#     created_at = Column(DateTime(timezone=True), server_default=func.now())


# class Product(Base):
#     """Product inventory table model"""
#     __tablename__ = "products"
    
#     id = Column(Integer, primary_key=True, index=True)
#     name = Column(String(255), unique=True, nullable=False)
#     description = Column(Text)
#     price = Column(Float, nullable=False)
#     quantity_in_stock = Column(Integer, default=0)
#     is_active = Column(Boolean, default=True)
#     created_at = Column(DateTime(timezone=True), server_default=func.now())
#     updated_at = Column(DateTime(timezone=True), onupdate=func.now())
