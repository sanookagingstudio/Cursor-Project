from fastapi import FastAPI
from .routes import trip, office, media

def create_app():
    app = FastAPI(title='FunAging.club Backend')

    @app.get('/health')
    async def health(): return {'status': 'ok'}

    app.include_router(trip.router)
    app.include_router(office.router)
    app.include_router(media.router)
    app.include_router(auth.router)
    return app

app = create_app()
