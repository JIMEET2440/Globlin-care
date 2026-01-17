"""
Database Schemas (Pydantic models for request/response validation)
Used for FastAPI request/response models
"""
from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional


class CustomerCreate(BaseModel):
    """Schema for creating a new customer"""
    name: str
    phone: Optional[str] = None
    area: Optional[str] = None


class CustomerUpdate(BaseModel):
    """Schema for updating customer"""
    name: Optional[str] = None
    phone: Optional[str] = None
    area: Optional[str] = None


class CustomerResponse(BaseModel):
    """Schema for customer response"""
    id: int
    name: str
    phone: Optional[str]
    area: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True


# class SalesCreate(BaseModel):
#     """Schema for creating a new sale"""
#     customer_id: int
#     product_name: str
#     quantity: int
#     price: float
#     total_amount: float
#     notes: Optional[str] = None


# class SalesResponse(BaseModel):
#     """Schema for sales response"""
#     id: int
#     customer_id: int
#     product_name: str
#     quantity: int
#     price: float
#     total_amount: float
#     sale_date: datetime
#     notes: Optional[str]
    
#     class Config:
#         from_attributes = True


# class ProductCreate(BaseModel):
#     """Schema for creating a new product"""
#     name: str
#     description: Optional[str] = None
#     price: float
#     quantity_in_stock: int = 0


# class ProductUpdate(BaseModel):
#     """Schema for updating product"""
#     name: Optional[str] = None
#     description: Optional[str] = None
#     price: Optional[float] = None
#     quantity_in_stock: Optional[int] = None
#     is_active: Optional[bool] = None


# class ProductResponse(BaseModel):
#     """Schema for product response"""
#     id: int
#     name: str
#     description: Optional[str]
#     price: float
#     quantity_in_stock: int
#     is_active: bool
#     created_at: datetime
    
#     class Config:
#         from_attributes = True
