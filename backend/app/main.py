
import uvicorn

from fastapi import FastAPI

from fastapi.middleware.cors import CORSMiddleware

from app.routers import health, trip, office, media



app = FastAPI(title="FunAging SAS Backend", version="0.1.0")



app.add_middleware(

    CORSMiddleware,

    allow_origins=["*"],

    allow_credentials=True,

    allow_methods=["*"],

    allow_headers=["*"],

)



@app.get("/")

async def root():

    return {"status": "ok", "service": "funaging-backend", "version": "v6"}



app.include_router(health.router, prefix="/health", tags=["health"])

app.include_router(trip.router,   prefix="/trip",   tags=["trip"])

app.include_router(office.router, prefix="/office", tags=["office"])

app.include_router(media.router,  prefix="/media",  tags=["media"])



if __name__ == "__main__":

    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)

