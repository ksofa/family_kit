from fastapi import HTTPException, status
from typing import List
from datetime import datetime, timedelta
from ..firebase_admin import db, messaging
from ..models.reminder import Reminder

class NotificationService:
    @staticmethod
    async def send_reminder_notification(reminder: Reminder, user_token: str):
        """Send a push notification for medicine reminder"""
        try:
            # Get medicine details
            medicine_ref = db.collection('medicines').document(reminder.medicine_id)
            medicine = medicine_ref.get()
            
            if not medicine.exists:
                raise ValueError("Medicine not found")
                
            medicine_data = medicine.to_dict()
            
            # Create notification message
            message = messaging.Message(
                notification=messaging.Notification(
                    title="Time to take your medicine",
                    body=f"Take {medicine_data['name']} - {reminder.dosage} {reminder.unit}"
                ),
                data={
                    'reminder_id': reminder.id,
                    'medicine_id': reminder.medicine_id,
                    'type': 'medicine_reminder'
                },
                token=user_token,
            )
            
            # Send message
            response = messaging.send(message)
            return response
            
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to send notification: {str(e)}"
            )
    
    @staticmethod
    async def send_expiry_notification(medicine_id: str, user_token: str):
        """Send notification for medicine expiring soon"""
        try:
            # Get medicine details
            medicine_ref = db.collection('medicines').document(medicine_id)
            medicine = medicine_ref.get()
            
            if not medicine.exists:
                raise ValueError("Medicine not found")
                
            medicine_data = medicine.to_dict()
            expiry_date = medicine_data['expiration_date']
            
            # Create notification message
            message = messaging.Message(
                notification=messaging.Notification(
                    title="Medicine Expiring Soon",
                    body=f"{medicine_data['name']} will expire on {expiry_date.strftime('%Y-%m-%d')}"
                ),
                data={
                    'medicine_id': medicine_id,
                    'type': 'expiry_warning'
                },
                token=user_token,
            )
            
            # Send message
            response = messaging.send(message)
            return response
            
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to send notification: {str(e)}"
            )

    @staticmethod
    async def check_expiring_medicines():
        """Check for medicines expiring within 7 days"""
        try:
            # Get medicines expiring in next 7 days
            seven_days_later = datetime.utcnow() + timedelta(days=7)
            
            medicines_ref = db.collection('medicines')
            query = medicines_ref.where(
                'expiration_date', '<=', seven_days_later
            ).where(
                'expiration_date', '>', datetime.utcnow()
            )
            
            expiring_medicines = query.stream()
            
            for medicine in expiring_medicines:
                medicine_data = medicine.to_dict()
                
                # Get first aid kit users
                kit_ref = db.collection('first_aid_kits').document(medicine_data['first_aid_kit_id'])
                kit = kit_ref.get()
                
                if kit.exists:
                    kit_data = kit.to_dict()
                    # Send notification to all users with access
                    for user in kit_data['users']:
                        # Get user's FCM token
                        user_ref = db.collection('users').document(user['user_id'])
                        user_data = user_ref.get().to_dict()
                        if user_data.get('fcm_token'):
                            await NotificationService.send_expiry_notification(
                                medicine.id,
                                user_data['fcm_token']
                            )
                            
        except Exception as e:
            print(f"Error checking expiring medicines: {str(e)}") 