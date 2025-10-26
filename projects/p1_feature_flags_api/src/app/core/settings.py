from pydantic_settings import BaseSettings
class Settings(BaseSettings):
    JWT_SECRET: str = "a-very-secret-key-that-you-should-change"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
settings = Settings()
