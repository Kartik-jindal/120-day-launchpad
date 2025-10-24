from fastapi import FastAPI, Query
from pydantic import BaseModel
from typing import Dict, Any
import hashlib

app = FastAPI(title="FFaaS")

@app.get("/health")
def health():
    return {"ok": True}

class EvaluateRequest(BaseModel):
    userId: str
    context: Dict[str, Any] = {}

def bucket_0_99(user_id: str, flag_key: str) -> int:
    # Stable bucket in [0..99] per (user, flag)
    h = hashlib.md5(f"{user_id}:{flag_key}".encode()).hexdigest()
    return int(h, 16) % 100

@app.post("/evaluate/{flagKey}")
def evaluate(
    flagKey: str,
    body: EvaluateRequest,
    percent: int = Query(25, ge=0, le=100),  # override with ?percent=0..100
):
    b = bucket_0_99(body.userId, flagKey)
    on = b < percent
    return {
        "flagKey": flagKey,
        "on": on,
        "matchedRuleId": None,   # placeholder for future rules
        "cache": False,          # will wire Redis later
        "bucket": b,             # debug: 0..99
        "percent": percent,
        "echo": {"userId": body.userId, "context": body.context},
    }