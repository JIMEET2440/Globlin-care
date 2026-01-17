from fastapi import FastAPI, Depends, HTTPException, status
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
import os
from database import Base, engine, SessionLocal
from models import Customer
from schemas import CustomerCreate, CustomerUpdate, CustomerResponse

# Load environment variables
load_dotenv()

# Initialize database tables
#Base.metadata.create_all(bind=engine)

# Create FastAPI app
app = FastAPI(title="Globin Care API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(","),
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Content-Type", "Authorization"],
)

# ============================================================================
# DEPENDENCY INJECTION
# ============================================================================

def get_db():
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ============================================================================
# CUSTOMER ENDPOINTS - CRUD OPERATIONS
# ============================================================================

@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Welcome to Globin Care API"}


@app.post("/customers", response_model=CustomerResponse, status_code=status.HTTP_201_CREATED)
async def create_customer(customer: CustomerCreate, db: Session = Depends(get_db)):
    """
    Create a new customer
    
    - **name**: Customer name (required)
    - **phone**: Customer phone number
    - **area**: Customer area
    """
    # Check if customer with same phone already exists
    existing_customer = db.query(Customer).filter(Customer.phone == customer.phone).first()
    if existing_customer:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Customer with this phone number already exists"
        )
    
    # Create new customer
    db_customer = Customer(
        name=customer.name,
        phone=customer.phone,
        area=customer.Area
    )
    db.add(db_customer)
    db.commit()
    db.refresh(db_customer)
    return db_customer


@app.get("/customers", response_model=list[CustomerResponse])
async def get_all_customers(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Get all customers with pagination
    
    - **skip**: Number of records to skip (default: 0)
    - **limit**: Number of records to return (default: 100)
    """
    customers = db.query(Customer).offset(skip).limit(limit).all()
    return customers


@app.get("/customers/{customer_id}", response_model=CustomerResponse)
async def get_customer(customer_id: int, db: Session = Depends(get_db)):
    """Get a specific customer by ID"""
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Customer with ID {customer_id} not found"
        )
    return customer


@app.put("/customers/{customer_id}", response_model=CustomerResponse)
async def update_customer(customer_id: int, customer_update: CustomerUpdate, db: Session = Depends(get_db)):
    """Update a customer's information"""
    db_customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not db_customer:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Customer with ID {customer_id} not found"
        )
    
    # Update only provided fields
    if customer_update.name is not None:
        db_customer.name = customer_update.name
    if customer_update.phone is not None:
        db_customer.phone = customer_update.phone
    if customer_update.address is not None:
        db_customer.area = customer_update.address
    
    db.commit()
    db.refresh(db_customer)
    return db_customer


@app.delete("/customers/{customer_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_customer(customer_id: int, db: Session = Depends(get_db)):
    """Delete a customer"""
    db_customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not db_customer:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Customer with ID {customer_id} not found"
        )
    
    db.delete(db_customer)
    db.commit()
    return None


@app.get("/customers/search/by-phone/{phone}")
async def search_customer_by_phone(phone: str, db: Session = Depends(get_db)):
    """Search for a customer by phone number"""
    customer = db.query(Customer).filter(Customer.phone == phone).first()
    if not customer:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Customer with phone {phone} not found"
        )
    return customer


@app.get("/customers/search/by-name/{name}")
async def search_customer_by_name(name: str, db: Session = Depends(get_db)):
    """Search for customers by name"""
    customers = db.query(Customer).filter(Customer.name.ilike(f"%{name}%")).all()
    if not customers:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No customers found with name containing '{name}'"
        )
    return customers


# ============================================================================
# UTILITY ENDPOINTS
# ============================================================================

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}







