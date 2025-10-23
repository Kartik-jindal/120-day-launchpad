from fastapi import FastAPI # Import FastAPI framework which is used to create web applications using Python.

app = FastAPI() # Create an instance of the FastAPI class. This instance will be our main application.

@app.get("/") # Define a route for the root URL ("/") using the GET method. it specifies that when a user accesses the root URL, the following function will be executed.
def read_root(): # Define a function that will be called when the root URL is accessed.
    return {"message": "Hello from inside the FastAPI app!"} # Return a JSON response with a greeting message.

@app.get("/items/{item_id}") # Define a route for the URL pattern "/items/{item_id}" using the GET method. The {item_id} part is a path parameter that will be passed to the function.
def read_item(item_id: int, q: str | None = None): # Define a function that will be called when the "/items/{item_id}" URL is accessed. It takes an integer path parameter item_id and an optional query parameter q of type string.
    return {"item_id": item_id, "q": q} # Return a JSON response containing the item_id and the optional query parameter q.