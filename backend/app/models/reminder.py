from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ReminderBase(BaseModel):
    medicine_id: str
    time: datetime
    frequency: str
    duration_days: int
    notes: Optional[str] = None

class ReminderCreate(ReminderBase):
    pass

class Reminder(ReminderBase):
    id: str
    user_id: str
    medicine_name: str
    start_date: datetime
    end_date: datetime
    is_active: bool
    created_at: datetime
    updated_at: datetime 