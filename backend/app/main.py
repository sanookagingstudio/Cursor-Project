"""FastAPI application entry point"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.routers import health, projects, assets, jobs, workflows, modules, input_brain, image, video, music, dashboard, publishing, integration, theme, monetization, analytics, cost, external_app, discount

# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Media Creator Core Foundation API"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, prefix="/health", tags=["health"])
app.include_router(projects.router, prefix="/projects", tags=["projects"])
app.include_router(assets.router, prefix="/assets", tags=["assets"])
app.include_router(jobs.router, prefix="/jobs", tags=["jobs"])
app.include_router(workflows.router, prefix="/workflows", tags=["workflows"])
app.include_router(modules.router, prefix="/modules", tags=["modules"])
app.include_router(input_brain.router, prefix="/api", tags=["input-brain"])
app.include_router(image.router, prefix="/api", tags=["image"])
app.include_router(video.router, prefix="/api", tags=["video"])
app.include_router(music.router, prefix="/api", tags=["music"])
app.include_router(music.audio_router, prefix="/api", tags=["audio"])
app.include_router(dashboard.router, prefix="/api", tags=["dashboard"])
app.include_router(publishing.router, prefix="/api", tags=["publishing"])
app.include_router(integration.router, prefix="/api", tags=["integration"])
app.include_router(theme.router, prefix="/api", tags=["themes"])
app.include_router(monetization.router, prefix="/api/monetization", tags=["monetization"])
app.include_router(analytics.router, prefix="/api/analytics", tags=["analytics"])
app.include_router(cost.router, prefix="/api/cost", tags=["cost"])
app.include_router(external_app.router, prefix="/api/external-apps", tags=["external-apps"])
app.include_router(discount.router, prefix="/api/discount", tags=["discount"])


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running"
    }

