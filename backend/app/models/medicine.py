from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class MedicineBase(BaseModel):
    name: str
    active_substance: str
    category: str
    form: str
    dosage: float
    unit: str
    volume_quantity: float
    expiration_date: datetime
    storage_conditions: Optional[str] = None
    barcode: Optional[str] = None
    is_private: bool = False

class MedicineCreate(MedicineBase):
    first_aid_kit_id: str

class Medicine(MedicineBase):
    id: str
    first_aid_kit_id: str
    created_at: datetime
    updated_at: datetime
    remaining_quantity: float 