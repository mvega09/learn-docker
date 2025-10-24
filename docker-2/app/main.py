from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def hello():
    return {"message": "Hola desde FastAPI en Ubuntu Docker!"}