from fastapi import FastAPI
from .config import settings
from .routers import auth, medicines, first_aid_kits, reminders
from .services.background_tasks import start_background_tasks

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
)

@app.on_event("startup")
async def startup_event():
    start_background_tasks()

# Include routers
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(medicines.router, prefix=settings.API_V1_STR)
app.include_router(first_aid_kits.router, prefix=settings.API_V1_STR)
app.include_router(reminders.router, prefix=settings.API_V1_STR)

@app.get("/")
async def root():
    return {"message": "Welcome to Medicine Cabinet API"} 