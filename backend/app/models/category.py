from pydantic import BaseModel
from typing import Optional, List

class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    parent_id: Optional[str] = None  # For subcategories

class CategoryCreate(CategoryBase):
    pass

class Category(CategoryBase):
    id: str
    subcategories: List[str] = []  # List of subcategory IDs

class PresetCategory(BaseModel):
    name: str
    subcategories: List[str] = []

PRESET_CATEGORIES = [
    PresetCategory(
        name="Cold and Flu",
        subcategories=["Cough", "Fever", "Nasal Congestion"]
    ),
    PresetCategory(
        name="Pain Relief",
        subcategories=["Headache", "Muscle Pain", "Joint Pain"]
    ),
    PresetCategory(
        name="Allergies",
        subcategories=["Antihistamines", "Decongestants"]
    ),
    PresetCategory(
        name="Gastrointestinal",
        subcategories=["Antacids", "Anti-diarrheal", "Digestive Health"]
    ),
    PresetCategory(
        name="Heart and Circulation",
        subcategories=["Blood Pressure", "Heart Health"]
    ),
    PresetCategory(
        name="Vitamins and Supplements",
        subcategories=["Multivitamins", "Minerals", "Dietary Supplements"]
    )
] 