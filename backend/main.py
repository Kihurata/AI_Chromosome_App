import asyncio
from fastapi import FastAPI
from app.core import firebase  # This initializes Firebase SDK
from app.api.endpoints import image_slicing, orchestrator, orders
from app.services.firestore_listener import start_order_listener

app = FastAPI(title="Chromosome App API")

app.include_router(image_slicing.router, prefix="/api", tags=["slicing"])
app.include_router(orchestrator.router, prefix="/api", tags=["orchestrator"])
app.include_router(orders.router, prefix="/api", tags=["orders"])

@app.on_event("startup")
async def startup_event():
    # Start the Firestore listener as a background task
    asyncio.create_task(start_order_listener())

@app.get("/")
def read_root():
    return {"message": "Welcome to Chromosome App Backend"}
