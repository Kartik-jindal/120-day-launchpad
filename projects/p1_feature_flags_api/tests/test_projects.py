from fastapi.testclient import TestClient
from app.main import app
import random

client = TestClient(app)

def test_create_project():
    # First, create an organization to put the project in
    org_name = f"Project Test Org {random.randint(1000, 9999)}"
    org_response = client.post("/orgs/", json={"name": org_name})
    assert org_response.status_code == 200
    org_id = org_response.json()["id"]

    # Now, create a project inside that organization
    project_name = "My First Project"
    project_response = client.post(
        "/projects/",
        json={"name": project_name, "org_id": org_id}
    )
    
    # Check that it was successful
    assert project_response.status_code == 200
    data = project_response.json()
    assert data["name"] == project_name
    assert data["org_id"] == org_id
    assert "api_key" in data # It should have automatically generated an API key
