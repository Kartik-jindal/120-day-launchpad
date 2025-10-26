from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from src.app.db.session import SessionLocal
from src.app.models.org import Org

router = APIRouter(prefix="/orgs", tags=["organizations"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class OrgCreate(BaseModel):
    name: str

@router.post("/")
def create_organization(org_in: OrgCreate, db: Session = Depends(get_db)):
    # Check if an org with this name already exists
    existing_org = db.query(Org).filter(Org.name == org_in.name).first()
    if existing_org:
        raise HTTPException(status_code=400, detail="Organization name already exists")

    # Create the new organization and save it to the database
    new_org = Org(name=org_in.name)
    db.add(new_org)
    db.commit()
    db.refresh(new_org)
    
    return new_org
