from pydantic import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Medicine Cabinet API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Firebase config
    FIREBASE_CREDENTIALS_PATH: str = "path/to/your/firebase-credentials.json"
    
    # JWT settings
    JWT_SECRET_KEY: str = "your-secret-key"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

settings = Settings() 