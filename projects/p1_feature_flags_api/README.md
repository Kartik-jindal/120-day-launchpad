# FFaaS — Feature Flags as a Service (Day 0)

A tiny FastAPI service that exposes a health check and a deterministic percentage-based rollout evaluator. Built to be simple, testable and easy to run locally.

## What it does
- POST /evaluate/{flagKey} — send `{ "userId": "...", "context": { ... } }` and get back ON/OFF based on a deterministic percent rollout.
- Small code surface so you can reason about behavior and cover it well with tests.

## Requirements
- Python 3.11 (will work with compatible 3.11.x installs)
- Optional: conda or any virtualenv tool

## Quick start (development)
1. Create and activate an environment:
```bash
conda create -n ffaaS python=3.11 -y
conda activate ffaaS
```
2. Install runtime and test dependencies:
```bash
python -m pip install -q fastapi "uvicorn[standard]" pytest httpx pydantic
```
3. Run the dev server:
```bash
# if your app entry is app/main.py
python -m uvicorn app.main:app --reload --port 8000

# if using src/ as the source root
python -m uvicorn app.main:app --reload --port 8000 --app-dir src
```

## Example API call
Request:
```bash
curl -sS -X POST "http://localhost:8000/evaluate/my-flag" \
    -H "Content-Type: application/json" \
    -d '{"userId":"user-123","context":{"country":"US"}}'
```
Possible response:
```json
{
    "flagKey": "my-flag",
    "result": "ON",
    "reason": "percent_rollout:42%"
}
```

## Tests
Run the test suite with:
```bash
python -m pytest -q
```
Tests should cover determinism of the rollout logic and edge cases (missing fields, invalid input, etc).

## Project layout
```
src/           # optional source root
    app/
        main.py    # API
tests/
    test_eval.py # tests
README.md
```

## Notes and recommendations
- The provided uvicorn command is for development. Use a production-grade ASGI setup (gunicorn + uvicorn workers, containers, etc.) for deployments.
- Keep the rollout computation deterministic so behavior is predictable across runs and environments.
- If you need different behavior in different environments, add config via environment variables or a config file.
- Consider adding linting, type checking (mypy), and CI integration to keep quality high.


