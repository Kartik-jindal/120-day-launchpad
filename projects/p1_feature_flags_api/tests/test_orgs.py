from fastapi.testclient import TestClient
from app.main import app
import random

client = TestClient(app)

def test_create_organization():
    # Generate a unique name for the organization for this test run
    org_name = f"Test Org {random.randint(1000, 9999)}"

    # Send a request to create the new organization
    response = client.post("/orgs/", json={"name": org_name})
    
    # Check that it was successful
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == org_name
    assert "id" in data

    # Try to create the same organization again, it should fail
    response_fail = client.post("/orgs/", json={"name": org_name})
    assert response_fail.status_code == 400
