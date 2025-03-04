from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class FirstAidKitBase(BaseModel):
    name: str
    location: Optional[str] = None
    is_private: bool = True

class FirstAidKitCreate(FirstAidKitBase):
    owner_id: str

class FirstAidKitUser(BaseModel):
    user_id: str
    role: str  # "administrator", "editor", or "observer"

class FirstAidKit(FirstAidKitBase):
    id: str
    owner_id: str
    users: List[FirstAidKitUser] = []
    created_at: datetime
    updated_at: datetime 