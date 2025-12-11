from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import health, trip, office, media

app = FastAPI(title="FunAging SAS Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(trip.router)
app.include_router(office.router)
app.include_router(media.router)

@app.get("/")
async def root():
    return {"status": "ok", "service": "FunAging SAS Backend"}
