from fastapi.testclient import TestClient
from app.main import app
import random

client = TestClient(app)
test_email = f"testuser{random.randint(1000, 9999)}@example.com"
test_password = "a-strong-password"

def test_full_auth_flow():
    # 1. Register a new user
    reg_res = client.post("/auth/register", json={"email": test_email, "password": test_password})
    assert reg_res.status_code == 200

    # 2. Try to register the same user again (should fail)
    fail_reg_res = client.post("/auth/register", json={"email": test_email, "password": test_password})
    assert fail_reg_res.status_code == 400

    # 3. Log in with the wrong password (should fail)
    fail_login_res = client.post("/auth/login", json={"email": test_email, "password": "wrong-password"})
    assert fail_login_res.status_code == 401

    # 4. Log in with the correct password (should succeed)
    good_login_res = client.post("/auth/login", json={"email": test_email, "password": test_password})
    assert good_login_res.status_code == 200
    data = good_login_res.json()
    assert "access_token" in data
