from datetime import datetime, timedelta
from typing import List, Dict
from ..firebase_admin import db, messaging
from ..models.medicine import Medicine

class ReminderService:
    @staticmethod
    async def create_reminder(
        medicine_id: str,
        user_id: str,
        time: datetime,
        frequency: str,
        duration_days: int,
        notes: str = None
    ) -> Dict:
        """Create a new medicine reminder"""
        try:
            # Get medicine details
            med_ref = db.collection('medicines').document(medicine_id)
            med = med_ref.get()
            
            if not med.exists:
                raise ValueError("Medicine not found")
                
            medicine = med.to_dict()
            
            # Create reminder document
            reminder_data = {
                'medicine_id': medicine_id,
                'medicine_name': medicine['name'],
                'user_id': user_id,
                'time': time,
                'frequency': frequency,
                'duration_days': duration_days,
                'notes': notes,
                'start_date': datetime.utcnow(),
                'end_date': datetime.utcnow() + timedelta(days=duration_days),
                'is_active': True,
                'created_at': datetime.utcnow(),
                'updated_at': datetime.utcnow()
            }
            
            doc_ref = db.collection('reminders').document()
            reminder_data['id'] = doc_ref.id
            doc_ref.set(reminder_data)
            
            return reminder_data
        except Exception as e:
            print(f"Error creating reminder: {str(e)}")
            raise e

    @staticmethod
    async def get_user_reminders(user_id: str) -> List[Dict]:
        """Get all active reminders for a user"""
        try:
            reminders_ref = db.collection('reminders')
            reminders = reminders_ref.where(
                'user_id', '==', user_id
            ).where(
                'is_active', '==', True
            ).where(
                'end_date', '>=', datetime.utcnow()
            ).stream()
            
            return [reminder.to_dict() for reminder in reminders]
        except Exception as e:
            print(f"Error getting user reminders: {str(e)}")
            return []

    @staticmethod
    async def update_reminder(reminder_id: str, updates: Dict) -> Dict:
        """Update a reminder"""
        try:
            reminder_ref = db.collection('reminders').document(reminder_id)
            reminder = reminder_ref.get()
            
            if not reminder.exists:
                raise ValueError("Reminder not found")
                
            updates['updated_at'] = datetime.utcnow()
            reminder_ref.update(updates)
            
            return reminder_ref.get().to_dict()
        except Exception as e:
            print(f"Error updating reminder: {str(e)}")
            raise e

    @staticmethod
    async def delete_reminder(reminder_id: str) -> bool:
        """Delete a reminder"""
        try:
            reminder_ref = db.collection('reminders').document(reminder_id)
            reminder = reminder_ref.get()
            
            if not reminder.exists:
                raise ValueError("Reminder not found")
                
            reminder_ref.delete()
            return True
        except Exception as e:
            print(f"Error deleting reminder: {str(e)}")
            return False

    @staticmethod
    async def process_due_reminders():
        """Process and send due reminders"""
        try:
            now = datetime.utcnow()
            
            # Get reminders due in the next minute
            reminders_ref = db.collection('reminders')
            reminders = reminders_ref.where(
                'is_active', '==', True
            ).where(
                'end_date', '>=', now
            ).stream()
            
            for reminder in reminders:
                reminder_data = reminder.to_dict()
                reminder_time = reminder_data['time'].time()
                current_time = now.time()
                
                # Check if reminder is due
                if (reminder_time.hour == current_time.hour and 
                    reminder_time.minute == current_time.minute):
                    
                    # Get user's FCM token
                    user_ref = db.collection('users').document(reminder_data['user_id'])
                    user_data = user_ref.get().to_dict()
                    
                    if user_data.get('fcm_token'):
                        # Send notification
                        message = messaging.Message(
                            notification=messaging.Notification(
                                title="Medicine Reminder",
                                body=f"Time to take {reminder_data['medicine_name']}"
                            ),
                            data={
                                'type': 'medicine_reminder',
                                'medicine_id': reminder_data['medicine_id'],
                                'reminder_id': reminder_data['id']
                            },
                            token=user_data['fcm_token'],
                        )
                        
                        messaging.send(message)
                        
        except Exception as e:
            print(f"Error processing reminders: {str(e)}") 