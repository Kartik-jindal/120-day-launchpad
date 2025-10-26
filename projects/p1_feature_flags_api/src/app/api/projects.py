from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from src.app.db.session import SessionLocal
from src.app.models.project import Project

router = APIRouter(prefix="/projects", tags=["projects"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class ProjectCreate(BaseModel):
    name: str
    org_id: int

@router.post("/")
def create_project(project_in: ProjectCreate, db: Session = Depends(get_db)):
    # In a real app, you would check if the org exists and if the user has permission.
    # For now, we'll keep it simple.
    
    new_project = Project(name=project_in.name, org_id=project_in.org_id)
    db.add(new_project)
    db.commit()
    db.refresh(new_project)
    
    return new_project
