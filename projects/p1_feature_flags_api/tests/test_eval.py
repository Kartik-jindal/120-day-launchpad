import sys, os

# Add project's src to sys.path so "from app.main import app" works
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

from app.main import app, bucket_0_99
from fastapi.testclient import TestClient

def test_evaluate_stub():
	c = TestClient(app)
	r = c.post("/evaluate/my-flag", json={"userId": "u1", "context": {"country": "US"}})
	assert r.status_code == 200
	data = r.json()
	assert data["flagKey"] == "my-flag"
	assert isinstance(data["on"], bool)
	assert data["cache"] is False

def test_bucket_stable_and_bounds():
	b1 = bucket_0_99("u1", "flagA")
	b2 = bucket_0_99("u1", "flagA")
	assert 0 <= b1 <= 99 and b1 == b2

def test_evaluate_percent_edges():
	c = TestClient(app)
	r0 = c.post("/evaluate/flagA?percent=0", json={"userId": "u1", "context": {}})
	assert r0.status_code == 200 and r0.json()["on"] is False
	r100 = c.post("/evaluate/flagA?percent=100", json={"userId": "u1", "context": {}})
	assert r100.status_code == 200 and r100.json()["on"] is True
