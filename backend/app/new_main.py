from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

def create_app():
    from app.routes import health, dashboard, auth

    app = FastAPI()

    app.add_middleware(
        CORSMiddleware,
        allow_origins=[
            "http://localhost:3000",
            "http://127.0.0.1:3000",
        ],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(health.router)
    app.include_router(dashboard.router)
    app.include_router(auth.router)

    return app

app = create_app()
