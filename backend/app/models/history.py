from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class MedicineLogBase(BaseModel):
    medicine_id: str
    user_id: str
    dosage: float
    unit: str
    status: str  # "Accepted" or "Missed"
    notes: Optional[str] = None

class MedicineLogCreate(MedicineLogBase):
    pass

class MedicineLog(MedicineLogBase):
    id: str
    date: datetime
    time: datetime
    created_at: datetime
    updated_at: datetime

class PrescriptionBase(BaseModel):
    medicine_id: str
    user_id: str
    dosage: float
    unit: str
    frequency: str
    course_duration: int  # in days
    start_date: datetime
    end_date: Optional[datetime] = None
    notes: Optional[str] = None

class PrescriptionCreate(PrescriptionBase):
    pass

class Prescription(PrescriptionBase):
    id: str
    created_at: datetime
    updated_at: datetime 