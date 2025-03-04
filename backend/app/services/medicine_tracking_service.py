from datetime import datetime, timedelta
from typing import List, Dict
from ..firebase_admin import db
from ..models.medicine import Medicine
from ..models.history import MedicineLog

class MedicineTrackingService:
    @staticmethod
    async def track_medicine_intake(medicine_id: str, log: MedicineLog) -> None:
        """Track medicine intake and update remaining quantity"""
        med_ref = db.collection('medicines').document(medicine_id)
        med = med_ref.get()
        
        if not med.exists:
            raise ValueError("Medicine not found")
            
        med_data = med.to_dict()
        
        # Update remaining quantity
        if log.status == "Accepted":
            new_quantity = med_data["remaining_quantity"] - log.dosage
            med_ref.update({
                "remaining_quantity": max(0, new_quantity),
                "updated_at": datetime.utcnow()
            })
            
            # Check if quantity is low
            if new_quantity <= med_data["volume_quantity"] * 0.05 or new_quantity <= 3:
                return True  # Indicates low stock
        
        return False

    @staticmethod
    async def get_medicine_analytics(medicine_id: str, start_date: datetime, end_date: datetime) -> Dict:
        """Get analytics for a specific medicine"""
        logs_ref = db.collection('medicine_logs')
        logs = logs_ref.where('medicine_id', '==', medicine_id)\
                      .where('date', '>=', start_date)\
                      .where('date', '<=', end_date)\
                      .stream()
                      
        total_doses = 0
        accepted_doses = 0
        missed_doses = 0
        total_quantity = 0
        
        for log in logs:
            log_data = log.to_dict()
            total_doses += 1
            if log_data['status'] == 'Accepted':
                accepted_doses += 1
                total_quantity += log_data['dosage']
            else:
                missed_doses += 1
        
        adherence_rate = (accepted_doses / total_doses * 100) if total_doses > 0 else 0
        
        return {
            'total_doses': total_doses,
            'accepted_doses': accepted_doses,
            'missed_doses': missed_doses,
            'total_quantity_used': total_quantity,
            'adherence_rate': adherence_rate
        }

    @staticmethod
    async def get_user_analytics(user_id: str, start_date: datetime, end_date: datetime) -> Dict:
        """Get analytics for all user's medicines"""
        logs_ref = db.collection('medicine_logs')
        logs = logs_ref.where('user_id', '==', user_id)\
                      .where('date', '>=', start_date)\
                      .where('date', '<=', end_date)\
                      .stream()
        
        medicines_data = {}
        total_doses = 0
        total_accepted = 0
        
        for log in logs:
            log_data = log.to_dict()
            med_id = log_data['medicine_id']
            
            if med_id not in medicines_data:
                medicines_data[med_id] = {
                    'doses': 0,
                    'accepted': 0,
                    'missed': 0
                }
            
            medicines_data[med_id]['doses'] += 1
            total_doses += 1
            
            if log_data['status'] == 'Accepted':
                medicines_data[med_id]['accepted'] += 1
                total_accepted += 1
            else:
                medicines_data[med_id]['missed'] += 1
        
        overall_adherence = (total_accepted / total_doses * 100) if total_doses > 0 else 0
        
        return {
            'overall_adherence': overall_adherence,
            'total_doses': total_doses,
            'total_accepted': total_accepted,
            'total_missed': total_doses - total_accepted,
            'medicines_breakdown': medicines_data
        } 