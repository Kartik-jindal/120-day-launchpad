from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import timedelta
from pydantic import BaseModel, EmailStr
from src.app.db.session import SessionLocal, engine # Import engine to create tables
from src.app.models.user import User, Base
from src.app.core.security import hash_password, verify_password, create_access_token
from src.app.core.settings import settings

# Create tables if they don't exist (simple approach for now)
Base.metadata.create_all(bind=engine)

router = APIRouter(prefix="/auth", tags=["auth"])
def get_db():
    db = SessionLocal(); yield db; db.close()

class RegisterRequest(BaseModel):
    email: EmailStr; password: str
class LoginRequest(BaseModel):
    email: EmailStr; password: str

@router.post("/register")
def register_user(user_in: RegisterRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == user_in.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    new_user = User(email=user_in.email, password_hash=hash_password(user_in.password))
    db.add(new_user); db.commit(); db.refresh(new_user)
    return {"id": new_user.id, "email": new_user.email}

@router.post("/login")
def login_user(user_in: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == user_in.email).first()
    if not user or not verify_password(user_in.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Incorrect email or password")
    expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    token = create_access_token(subject=user.id, expires_delta=expires)
    return {"access_token": token, "token_type": "bearer"}
