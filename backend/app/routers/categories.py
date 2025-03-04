from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from ..models.category import Category, CategoryCreate, PRESET_CATEGORIES
from ..middleware.auth import get_current_user
from ..models.user import User
from ..firebase_admin import db

router = APIRouter(prefix="/categories", tags=["categories"])

@router.get("/presets", response_model=List[Category])
async def get_preset_categories():
    """Get list of preset categories"""
    try:
        categories = []
        for preset in PRESET_CATEGORIES:
            category = Category(
                id=preset.name.lower().replace(" ", "_"),
                name=preset.name,
                subcategories=preset.subcategories
            )
            categories.append(category)
        return categories
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/custom", response_model=Category)
async def create_custom_category(
    category: CategoryCreate,
    current_user: User = Depends(get_current_user)
):
    """Create a custom category"""
    try:
        category_data = category.dict()
        
        # Create document in Firestore
        doc_ref = db.collection('categories').document()
        category_data["id"] = doc_ref.id
        category_data["created_by"] = current_user.id
        doc_ref.set(category_data)
        
        return Category(**category_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/custom", response_model=List[Category])
async def get_custom_categories(current_user: User = Depends(get_current_user)):
    """Get user's custom categories"""
    try:
        categories_ref = db.collection('categories')
        categories = categories_ref.where('created_by', '==', current_user.id).stream()
        
        return [Category(**cat.to_dict()) for cat in categories]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/custom/{category_id}")
async def delete_custom_category(
    category_id: str,
    current_user: User = Depends(get_current_user)
):
    """Delete a custom category"""
    try:
        category_ref = db.collection('categories').document(category_id)
        category = category_ref.get()
        
        if not category.exists:
            raise HTTPException(status_code=404, detail="Category not found")
            
        category_data = category.to_dict()
        if category_data['created_by'] != current_user.id:
            raise HTTPException(
                status_code=403,
                detail="Not authorized to delete this category"
            )
            
        # Check if any medicines are using this category
        medicines_ref = db.collection('medicines')
        medicines = medicines_ref.where('category', '==', category_id).limit(1).stream()
        
        if next(medicines, None) is not None:
            raise HTTPException(
                status_code=400,
                detail="Cannot delete category that is being used by medicines"
            )
            
        category_ref.delete()
        return {"message": "Category deleted successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        ) 