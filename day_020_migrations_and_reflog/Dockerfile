# INSTRUCTION 1: Start from a clean, minimal version of Python 3.10.
FROM python:3.10-slim

# INSTRUCTION 2: Create a workspace folder named `/app` inside the container.
WORKDIR /app

# INSTRUCTION 3: Copy our shopping list (`requirements.txt`) into the workspace.
COPY requirements.txt .

# INSTRUCTION 4: Install the items on the shopping list inside the container.
RUN pip install --no-cache-dir -r requirements.txt

# INSTRUCTION 5: Copy our application code (`main.py`) into the workspace.
COPY . .

# INSTRUCTION 6: Document that the app inside will use port 8000.
EXPOSE 8000

# INSTRUCTION 7: State the command to run the app when the container starts.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]