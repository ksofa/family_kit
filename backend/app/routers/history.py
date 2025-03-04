from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from datetime import datetime, timedelta
from ..models.history import MedicineLog, MedicineLogCreate, Prescription, PrescriptionCreate
from ..middleware.auth import get_current_user
from ..models.user import User
from ..firebase_admin import db
from ..services.report_service import ReportService
from fastapi.responses import JSONResponse

router = APIRouter(prefix="/history", tags=["history"])

@router.post("/logs", response_model=MedicineLog)
async def create_medicine_log(
    log: MedicineLogCreate,
    current_user: User = Depends(get_current_user)
):
    try:
        log_data = log.dict()
        log_data["created_at"] = datetime.utcnow()
        log_data["updated_at"] = log_data["created_at"]
        log_data["date"] = log_data["created_at"].date()
        log_data["time"] = log_data["created_at"].time()
        
        # Create document in Firestore
        doc_ref = db.collection('medicine_logs').document()
        log_data["id"] = doc_ref.id
        doc_ref.set(log_data)
        
        # Update medicine quantity if status is "Accepted"
        if log_data["status"] == "Accepted":
            med_ref = db.collection('medicines').document(log.medicine_id)
            med = med_ref.get()
            
            if med.exists:
                med_data = med.to_dict()
                new_quantity = med_data["remaining_quantity"] - log.dosage
                med_ref.update({
                    "remaining_quantity": max(0, new_quantity),
                    "updated_at": datetime.utcnow()
                })
        
        return MedicineLog(**log_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/logs/medicine/{medicine_id}", response_model=List[MedicineLog])
async def get_medicine_logs(
    medicine_id: str,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(get_current_user)
):
    try:
        # Query logs
        logs_ref = db.collection('medicine_logs')
        query = logs_ref.where('medicine_id', '==', medicine_id)
        
        if start_date:
            query = query.where('date', '>=', start_date)
        if end_date:
            query = query.where('date', '<=', end_date)
            
        logs = query.stream()
        
        return [MedicineLog(**log.to_dict()) for log in logs]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/prescriptions", response_model=Prescription)
async def create_prescription(
    prescription: PrescriptionCreate,
    current_user: User = Depends(get_current_user)
):
    try:
        prescription_data = prescription.dict()
        prescription_data["created_at"] = datetime.utcnow()
        prescription_data["updated_at"] = prescription_data["created_at"]
        
        # Calculate end date if not provided
        if not prescription_data.get("end_date"):
            prescription_data["end_date"] = (
                prescription_data["start_date"] + 
                timedelta(days=prescription_data["course_duration"])
            )
        
        # Create document in Firestore
        doc_ref = db.collection('prescriptions').document()
        prescription_data["id"] = doc_ref.id
        doc_ref.set(prescription_data)
        
        return Prescription(**prescription_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/reports/user/{user_id}", response_model=List[MedicineLog])
async def generate_user_report(
    user_id: str,
    start_date: datetime,
    end_date: datetime,
    current_user: User = Depends(get_current_user)
):
    try:
        # Verify access rights (user can only access their own reports)
        if current_user.id != user_id:
            raise HTTPException(
                status_code=403,
                detail="Not authorized to access this report"
            )
            
        # Query logs
        logs_ref = db.collection('medicine_logs')
        logs = logs_ref.where('user_id', '==', user_id)\
                      .where('date', '>=', start_date)\
                      .where('date', '<=', end_date)\
                      .stream()
        
        return [MedicineLog(**log.to_dict()) for log in logs]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/reports/user/{user_id}/pdf")
async def generate_pdf_report(
    user_id: str,
    start_date: datetime,
    end_date: datetime,
    current_user: User = Depends(get_current_user)
):
    try:
        # Verify access rights
        if current_user.id != user_id:
            raise HTTPException(
                status_code=403,
                detail="Not authorized to access this report"
            )
            
        # Get logs
        logs_ref = db.collection('medicine_logs')
        logs = logs_ref.where('user_id', '==', user_id)\
                      .where('date', '>=', start_date)\
                      .where('date', '<=', end_date)\
                      .stream()
        
        logs_list = [MedicineLog(**log.to_dict()) for log in logs]
        
        # Generate PDF
        pdf_url = await ReportService.generate_pdf_report(
            logs_list,
            f"{current_user.first_name} {current_user.last_name}"
        )
        
        return JSONResponse(content={"pdf_url": pdf_url})
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        ) 