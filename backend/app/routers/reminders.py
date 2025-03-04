from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from ..models.reminder import Reminder, ReminderCreate
from ..firebase_admin import db
from datetime import datetime

router = APIRouter(prefix="/reminders", tags=["reminders"])

async def get_current_user():
    # Implement authentication logic here
    pass

@router.post("/", response_model=Reminder)
async def create_reminder(
    reminder: ReminderCreate,
    current_user = Depends(get_current_user)
):
    try:
        reminder_data = reminder.dict()
        reminder_data["created_at"] = datetime.utcnow()
        reminder_data["updated_at"] = reminder_data["created_at"]
        
        # Create document in Firestore
        doc_ref = db.collection('reminders').document()
        reminder_data["id"] = doc_ref.id
        doc_ref.set(reminder_data)
        
        return Reminder(**reminder_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/", response_model=List[Reminder])
async def get_user_reminders(current_user = Depends(get_current_user)):
    try:
        # Query Firestore for user's reminders
        reminders_ref = db.collection('reminders')
        query = reminders_ref.where('user_id', '==', current_user.id)
        reminders = query.stream()
        
        return [Reminder(**reminder.to_dict()) for reminder in reminders]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/{reminder_id}")
async def delete_reminder(
    reminder_id: str,
    current_user = Depends(get_current_user)
):
    try:
        reminder_ref = db.collection('reminders').document(reminder_id)
        reminder = reminder_ref.get()
        
        if not reminder.exists:
            raise HTTPException(status_code=404, detail="Reminder not found")
            
        reminder_data = reminder.to_dict()
        if reminder_data["user_id"] != current_user.id:
            raise HTTPException(
                status_code=403,
                detail="Not authorized to delete this reminder"
            )
            
        reminder_ref.delete()
        return {"message": "Reminder deleted successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        ) 