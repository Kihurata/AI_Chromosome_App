from fastapi import FastAPI
from app.core import firebase  # This initializes Firebase SDK

app = FastAPI(title="Chromosome App API")

@app.get("/")
def read_root():
    return {"message": "Welcome to Chromosome App Backend"}
