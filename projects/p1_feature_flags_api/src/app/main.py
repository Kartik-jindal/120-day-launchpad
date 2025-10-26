from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from src.app.db.session import SessionLocal, engine
# --- Import all our models so create_all sees them ---
from src.app.models.base import Base
from src.app.models.user import User
from src.app.models.org import Org, OrgMember
from src.app.models.project import Project # <-- NEW IMPORT
# --- Import all our API routers ---
from src.app.api import auth as auth_api
from src.app.api import orgs as orgs_api
from src.app.api import projects as projects_api # <-- NEW IMPORT

# This simple command creates all tables from all imported models
Base.metadata.create_all(bind=engine)

app = FastAPI(title="FFaaS")

def get_db():
    db = SessionLocal(); yield db; db.close()

@app.get("/health")
def health(): return {"ok": True}

# This is just a placeholder now, we'll remove it later
@app.get("/users/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if user:
        return {"email": user.email}
    return {"error": "User not found"}

# Include all the "doors" from our different API files
app.include_router(auth_api.router)
app.include_router(orgs_api.router)
app.include_router(projects_api.router) # <-- NEW CONNECTION
