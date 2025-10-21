# Import the os module to access environment variables and interact with the operating system
import os
# Import the FastAPI class to create the web application
from fastapi import FastAPI

#This is main application

# Create a FastAPI app instance that will handle incoming HTTP requests
app = FastAPI()

# Read the database host from the environment variable POSTGRES_HOST (or None if not set)
DB_HOST = os.getenv("POSTGRES_HOST")
# Read the database name from the environment variable POSTGRES_DB (or None if not set)
DB_NAME = os.getenv("POSTGRES_DB")
# Read the database user from the environment variable POSTGRES_USER (or None if not set)
DB_USER = os.getenv("POSTGRES_USER")

# Define a GET endpoint for the root path "/"
@app.get("/")
# This function runs when someone visits the root URL and returns a JSON response
def read_root():
    # Return a dictionary that becomes a JSON response showing a message and the env values
    return {
        "message": "API is running and trying to connect to the database!",
        "database_host_from_env": DB_HOST,
        "database_name_from_env": DB_NAME,
        "database_user_from_env": DB_USER
    }