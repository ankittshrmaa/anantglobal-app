import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker
from passlib.context import CryptContext
from datetime import datetime, timedelta
import random

# ─── DATABASE SETUP ──────────────────────────────────────────────────────────
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://anant_user:anant_pass@localhost:5432/anantglobal"
)
engine = create_engine(DATABASE_URL)
SessionLocal  = sessionmaker(bind=engine)
Base          = declarative_base()

# ─── MODELS ──────────────────────────────────────────────────────────────────
class User(Base):
    __tablename__ = "users"
    id            = Column(Integer, primary_key=True, index=True)
    name          = Column(String, nullable=False)
    mobile        = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    is_verified   = Column(Boolean, default=False)
    created_at    = Column(DateTime, default=datetime.utcnow)

class OTPRecord(Base):
    __tablename__ = "otp_records"
    id            = Column(Integer, primary_key=True, index=True)
    mobile        = Column(String, nullable=False)
    otp           = Column(String, nullable=False)
    expires_at    = Column(DateTime, nullable=False)
    is_used       = Column(Boolean, default=False)

Base.metadata.create_all(bind=engine)

# ─── PASSWORD HASHING ────────────────────────────────────────────────────────
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

# ─── FASTAPI APP ─────────────────────────────────────────────────────────────
app = FastAPI(title="AnantGlobal API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── SCHEMAS (Request / Response models) ─────────────────────────────────────
class SendOTPRequest(BaseModel):
    name:   str
    mobile: str

class VerifyOTPRequest(BaseModel):
    name:     str
    mobile:   str
    otp:      str
    password: str

class LoginRequest(BaseModel):
    mobile:   str
    password: str

# ─── ROUTES ──────────────────────────────────────────────────────────────────

# Health check
@app.get("/")
def root():
    return {"status": "AnantGlobal API is running ✅"}


# ── STEP 1: Send OTP ─────────────────────────────────────────────────────────
@app.post("/auth/send-otp")
def send_otp(req: SendOTPRequest):
    db = SessionLocal()
    try:
        # Check name
        if not req.name.strip():
            raise HTTPException(status_code=400, detail="Name is required")

        # Check mobile length
        if len(req.mobile) != 10 or not req.mobile.isdigit():
            raise HTTPException(status_code=400, detail="Enter a valid 10-digit mobile number")

        # Check if mobile already registered
        existing = db.query(User).filter(User.mobile == req.mobile).first()
        if existing:
            raise HTTPException(status_code=409, detail="Mobile number already registered. Please log in.")

        # Generate 6-digit OTP
        otp_code  = str(random.randint(100000, 999999))
        expires   = datetime.utcnow() + timedelta(minutes=10)

        # Delete any old OTPs for this mobile
        db.query(OTPRecord).filter(OTPRecord.mobile == req.mobile).delete()

        # Save new OTP
        otp_record = OTPRecord(mobile=req.mobile, otp=otp_code, expires_at=expires)
        db.add(otp_record)
        db.commit()

        # In production: send via SMS API (Twilio / MSG91)
        # For now: print to terminal so you can see it
        print(f"\n{'='*40}")
        print(f"  OTP for {req.mobile}: {otp_code}")
        print(f"  Expires at: {expires}")
        print(f"{'='*40}\n")

        return {
            "success": True,
            "message": f"OTP sent to +91 {req.mobile}",
            # REMOVE this in production — only for development
            "dev_otp": otp_code
        }
    finally:
        db.close()


# ── STEP 2: Verify OTP + Register User ───────────────────────────────────────
@app.post("/auth/verify-otp")
def verify_otp(req: VerifyOTPRequest):
    db = SessionLocal()
    try:
        # Validate password length
        if len(req.password) < 6:
            raise HTTPException(status_code=400, detail="Password must be at least 6 characters")

        # Find OTP record
        otp_record = db.query(OTPRecord).filter(
            OTPRecord.mobile == req.mobile,
            OTPRecord.is_used == False
        ).order_by(OTPRecord.id.desc()).first()

        if not otp_record:
            raise HTTPException(status_code=404, detail="No OTP found. Please request a new one.")

        # Check expiry
        if datetime.utcnow() > otp_record.expires_at:
            raise HTTPException(status_code=410, detail="OTP has expired. Please request a new one.")

        # Check OTP value
        if otp_record.otp != req.otp:
            raise HTTPException(status_code=401, detail="Incorrect OTP. Please try again.")

        # Mark OTP as used
        otp_record.is_used = True

        # Create user
        new_user = User(
            name          = req.name.strip(),
            mobile        = req.mobile,
            password_hash = hash_password(req.password),
            is_verified   = True,
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)

        return {
            "success": True,
            "message": "Account created successfully!",
            "user": {
                "id":         new_user.id,
                "name":       new_user.name,
                "mobile":     new_user.mobile,
                "verified":   new_user.is_verified,
                "created_at": str(new_user.created_at),
            }
        }
    finally:
        db.close()


# ── LOGIN ─────────────────────────────────────────────────────────────────────
@app.post("/auth/login")
def login(req: LoginRequest):
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.mobile == req.mobile).first()

        if not user:
            raise HTTPException(status_code=404, detail="Mobile number not registered.")

        if not verify_password(req.password, user.password_hash):
            raise HTTPException(status_code=401, detail="Incorrect password.")

        return {
            "success": True,
            "message": "Login successful!",
            "user": {
                "id":     user.id,
                "name":   user.name,
                "mobile": user.mobile,
            }
        }
    finally:
        db.close()


# ── GET ALL USERS (for debugging) ─────────────────────────────────────────────
@app.get("/users")
def get_users():
    db = SessionLocal()
    users = db.query(User).all()
    db.close()
    return [{"id": u.id, "name": u.name, "mobile": u.mobile, "verified": u.is_verified} for u in users]