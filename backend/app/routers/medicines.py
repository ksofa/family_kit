from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile
from typing import List, Dict, Optional
from ..models.medicine import Medicine, MedicineCreate
from ..middleware.auth import get_current_user
from ..models.user import User
from ..firebase_admin import db
from datetime import datetime
from ..services.scanner import ScannerService
from ..services.medicine_tracking_service import MedicineTrackingService
from ..services.storage_service import StorageService
from ..services.interaction_service import InteractionService
from ..services.reminder_service import ReminderService

router = APIRouter(prefix="/medicines", tags=["medicines"])

@router.post("/", response_model=Medicine)
async def create_medicine(
    medicine: MedicineCreate,
    current_user: User = Depends(get_current_user)
):
    try:
        # Verify user has access to first aid kit
        kit_ref = db.collection('first_aid_kits').document(medicine.first_aid_kit_id)
        kit = kit_ref.get()
        
        if not kit.exists:
            raise HTTPException(status_code=404, detail="First aid kit not found")
            
        kit_data = kit.to_dict()
        user_role = next(
            (user["role"] for user in kit_data["users"] 
             if user["user_id"] == current_user.id),
            None
        )
        
        if not user_role or user_role == "observer":
            raise HTTPException(
                status_code=403,
                detail="Not authorized to add medicines"
            )
            
        # Create medicine document
        medicine_data = medicine.dict()
        medicine_data["created_at"] = datetime.utcnow()
        medicine_data["updated_at"] = medicine_data["created_at"]
        medicine_data["remaining_quantity"] = medicine_data["volume_quantity"]
        
        doc_ref = db.collection('medicines').document()
        medicine_data["id"] = doc_ref.id
        doc_ref.set(medicine_data)
        
        return Medicine(**medicine_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/first-aid-kit/{kit_id}", response_model=List[Medicine])
async def get_first_aid_kit_medicines(
    kit_id: str,
    current_user: User = Depends(get_current_user)
):
    try:
        # Verify user has access to first aid kit
        kit_ref = db.collection('first_aid_kits').document(kit_id)
        kit = kit_ref.get()
        
        if not kit.exists:
            raise HTTPException(status_code=404, detail="First aid kit not found")
            
        kit_data = kit.to_dict()
        user_role = next(
            (user["role"] for user in kit_data["users"] 
             if user["user_id"] == current_user.id),
            None
        )
        
        if not user_role:
            raise HTTPException(
                status_code=403,
                detail="Not authorized to view medicines"
            )
            
        # Query medicines
        medicines_ref = db.collection('medicines')
        query = medicines_ref.where('first_aid_kit_id', '==', kit_id)
        
        # If not admin/editor, filter out private medicines
        if user_role == "observer":
            query = query.where('is_private', '==', False)
            
        medicines = query.stream()
        
        return [Medicine(**med.to_dict()) for med in medicines]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.patch("/{medicine_id}/quantity")
async def update_medicine_quantity(
    medicine_id: str,
    quantity: float,
    current_user: User = Depends(get_current_user)
):
    try:
        # Get medicine and verify access
        med_ref = db.collection('medicines').document(medicine_id)
        med = med_ref.get()
        
        if not med.exists:
            raise HTTPException(status_code=404, detail="Medicine not found")
            
        med_data = med.to_dict()
        
        # Check first aid kit access
        kit_ref = db.collection('first_aid_kits').document(med_data['first_aid_kit_id'])
        kit = kit_ref.get()
        kit_data = kit.to_dict()
        
        user_role = next(
            (user["role"] for user in kit_data["users"] 
             if user["user_id"] == current_user.id),
            None
        )
        
        if not user_role or user_role == "observer":
            raise HTTPException(
                status_code=403,
                detail="Not authorized to update medicine"
            )
            
        # Update quantity
        med_ref.update({
            'remaining_quantity': quantity,
            'updated_at': datetime.utcnow()
        })
        
        return {"message": "Quantity updated successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/scan/qr", response_model=Dict)
async def scan_qr_code(
    qr_data: Dict,
    current_user: User = Depends(get_current_user)
):
    try:
        medicine_data = await ScannerService.process_qr_code(qr_data)
        return medicine_data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/scan/barcode/{barcode}", response_model=Dict)
async def scan_barcode(
    barcode: str,
    current_user: User = Depends(get_current_user)
):
    try:
        medicine_data = await ScannerService.process_barcode(barcode)
        return medicine_data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/search", response_model=List[Medicine])
async def search_medicines(
    query: str,
    category: Optional[str] = None,
    current_user: User = Depends(get_current_user)
):
    try:
        # Get all first aid kits the user has access to
        kits_ref = db.collection('first_aid_kits')
        kits_query = kits_ref.where('users', 'array_contains', {'user_id': current_user.id})
        kit_ids = [kit.id for kit in kits_query.stream()]
        
        if not kit_ids:
            return []
        
        # Query medicines
        medicines_ref = db.collection('medicines')
        base_query = medicines_ref.where('first_aid_kit_id', 'in', kit_ids)
        
        # Apply category filter if provided
        if category:
            base_query = base_query.where('category', '==', category)
        
        # Get all matching medicines
        medicines = base_query.stream()
        
        # Filter by name using case-insensitive partial match
        query = query.lower()
        filtered_medicines = [
            Medicine(**med.to_dict())
            for med in medicines
            if query in med.get('name', '').lower() or
               query in med.get('active_substance', '').lower()
        ]
        
        return filtered_medicines
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/{medicine_id}/analytics")
async def get_medicine_analytics(
    medicine_id: str,
    start_date: datetime,
    end_date: datetime,
    current_user: User = Depends(get_current_user)
):
    try:
        # Verify access to medicine
        med_ref = db.collection('medicines').document(medicine_id)
        med = med_ref.get()
        
        if not med.exists:
            raise HTTPException(status_code=404, detail="Medicine not found")
            
        med_data = med.to_dict()
        
        # Check first aid kit access
        kit_ref = db.collection('first_aid_kits').document(med_data['first_aid_kit_id'])
        kit = kit_ref.get()
        kit_data = kit.to_dict()
        
        if not any(user["user_id"] == current_user.id for user in kit_data["users"]):
            raise HTTPException(
                status_code=403,
                detail="Not authorized to view this medicine's analytics"
            )
        
        analytics = await MedicineTrackingService.get_medicine_analytics(
            medicine_id,
            start_date,
            end_date
        )
        
        return analytics
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/analytics/user/{user_id}")
async def get_user_analytics(
    user_id: str,
    start_date: datetime,
    end_date: datetime,
    current_user: User = Depends(get_current_user)
):
    try:
        # Users can only view their own analytics
        if current_user.id != user_id:
            raise HTTPException(
                status_code=403,
                detail="Not authorized to view this user's analytics"
            )
        
        analytics = await MedicineTrackingService.get_user_analytics(
            user_id,
            start_date,
            end_date
        )
        
        return analytics
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/{medicine_id}/storage-recommendations")
async def get_medicine_storage_recommendations(
    medicine_id: str,
    current_user: User = Depends(get_current_user)
):
    try:
        # Get medicine
        med_ref = db.collection('medicines').document(medicine_id)
        med = med_ref.get()
        
        if not med.exists:
            raise HTTPException(status_code=404, detail="Medicine not found")
            
        medicine = Medicine(**med.to_dict())
        
        # Get storage recommendations
        recommendations = StorageService.get_storage_recommendations(medicine)
        if not recommendations:
            raise HTTPException(
                status_code=500,
                detail="Failed to get storage recommendations"
            )
        
        return recommendations
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/{medicine_id}/interactions")
async def check_medicine_interactions(
    medicine_id: str,
    current_user: User = Depends(get_current_user)
):
    try:
        # Get medicine
        med_ref = db.collection('medicines').document(medicine_id)
        med = med_ref.get()
        
        if not med.exists:
            raise HTTPException(status_code=404, detail="Medicine not found")
            
        med_data = med.to_dict()
        
        # Check first aid kit access
        kit_ref = db.collection('first_aid_kits').document(med_data['first_aid_kit_id'])
        kit = kit_ref.get()
        kit_data = kit.to_dict()
        
        if not any(user["user_id"] == current_user.id for user in kit_data["users"]):
            raise HTTPException(
                status_code=403,
                detail="Not authorized to view this medicine's interactions"
            )
        
        # Get interaction warnings
        warnings = await InteractionService.get_interaction_warnings(
            medicine_id,
            med_data['first_aid_kit_id']
        )
        
        return warnings
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/{medicine_id}/reminders")
async def create_medicine_reminder(
    medicine_id: str,
    time: datetime,
    frequency: str,
    duration_days: int,
    notes: Optional[str] = None,
    current_user: User = Depends(get_current_user)
):
    try:
        reminder = await ReminderService.create_reminder(
            medicine_id,
            current_user.id,
            time,
            frequency,
            duration_days,
            notes
        )
        return reminder
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/reminders/user/me")
async def get_user_reminders(current_user: User = Depends(get_current_user)):
    try:
        reminders = await ReminderService.get_user_reminders(current_user.id)
        return reminders
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.patch("/reminders/{reminder_id}")
async def update_reminder(
    reminder_id: str,
    updates: Dict,
    current_user: User = Depends(get_current_user)
):
    try:
        reminder = await ReminderService.update_reminder(reminder_id, updates)
        return reminder
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/reminders/{reminder_id}")
async def delete_reminder(
    reminder_id: str,
    current_user: User = Depends(get_current_user)
):
    try:
        success = await ReminderService.delete_reminder(reminder_id)
        if success:
            return {"message": "Reminder deleted successfully"}
        raise HTTPException(
            status_code=500,
            detail="Failed to delete reminder"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        ) 