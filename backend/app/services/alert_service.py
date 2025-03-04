from datetime import datetime, timedelta
from typing import List, Dict
from ..firebase_admin import db, messaging
from ..models.medicine import Medicine

class AlertService:
    @staticmethod
    async def check_expiring_medicines(days_threshold: int = 7) -> List[Dict]:
        """Check for medicines expiring within specified days"""
        try:
            expiry_date = datetime.utcnow() + timedelta(days=days_threshold)
            
            # Query medicines expiring soon
            medicines_ref = db.collection('medicines')
            query = medicines_ref.where(
                'expiration_date', '<=', expiry_date
            ).where(
                'expiration_date', '>', datetime.utcnow()
            )
            
            expiring_medicines = []
            for med in query.stream():
                med_data = med.to_dict()
                
                # Get first aid kit info
                kit_ref = db.collection('first_aid_kits').document(med_data['first_aid_kit_id'])
                kit = kit_ref.get()
                
                if kit.exists:
                    kit_data = kit.to_dict()
                    expiring_medicines.append({
                        'medicine': med_data,
                        'first_aid_kit': kit_data,
                        'days_until_expiry': (med_data['expiration_date'] - datetime.utcnow()).days
                    })
            
            return expiring_medicines
        except Exception as e:
            print(f"Error checking expiring medicines: {str(e)}")
            return []

    @staticmethod
    async def check_low_stock_medicines(threshold_percent: float = 0.05) -> List[Dict]:
        """Check for medicines with low stock"""
        try:
            medicines_ref = db.collection('medicines')
            medicines = medicines_ref.stream()
            
            low_stock_medicines = []
            for med in medicines:
                med_data = med.to_dict()
                remaining_ratio = med_data['remaining_quantity'] / med_data['volume_quantity']
                
                if remaining_ratio <= threshold_percent or med_data['remaining_quantity'] <= 3:
                    # Get first aid kit info
                    kit_ref = db.collection('first_aid_kits').document(med_data['first_aid_kit_id'])
                    kit = kit_ref.get()
                    
                    if kit.exists:
                        kit_data = kit.to_dict()
                        low_stock_medicines.append({
                            'medicine': med_data,
                            'first_aid_kit': kit_data,
                            'remaining_ratio': remaining_ratio
                        })
            
            return low_stock_medicines
        except Exception as e:
            print(f"Error checking low stock medicines: {str(e)}")
            return []

    @staticmethod
    async def send_alert_notification(
        user_token: str,
        title: str,
        body: str,
        data: Dict = None
    ) -> bool:
        """Send push notification to user"""
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                token=user_token,
            )
            
            response = messaging.send(message)
            return True if response else False
        except Exception as e:
            print(f"Error sending notification: {str(e)}")
            return False

    @staticmethod
    async def process_alerts():
        """Process all alerts and send notifications"""
        try:
            # Check expiring medicines
            expiring_medicines = await AlertService.check_expiring_medicines()
            for med in expiring_medicines:
                for user in med['first_aid_kit']['users']:
                    user_ref = db.collection('users').document(user['user_id'])
                    user_data = user_ref.get().to_dict()
                    
                    if user_data.get('fcm_token'):
                        await AlertService.send_alert_notification(
                            user_data['fcm_token'],
                            "Medicine Expiring Soon",
                            f"{med['medicine']['name']} will expire in {med['days_until_expiry']} days",
                            {
                                'type': 'expiry_warning',
                                'medicine_id': med['medicine']['id']
                            }
                        )
            
            # Check low stock medicines
            low_stock_medicines = await AlertService.check_low_stock_medicines()
            for med in low_stock_medicines:
                for user in med['first_aid_kit']['users']:
                    user_ref = db.collection('users').document(user['user_id'])
                    user_data = user_ref.get().to_dict()
                    
                    if user_data.get('fcm_token'):
                        remaining = med['medicine']['remaining_quantity']
                        await AlertService.send_alert_notification(
                            user_data['fcm_token'],
                            "Low Medicine Stock",
                            f"{med['medicine']['name']} is running low ({remaining} {med['medicine']['unit']} remaining)",
                            {
                                'type': 'low_stock_warning',
                                'medicine_id': med['medicine']['id']
                            }
                        )
                        
        except Exception as e:
            print(f"Error processing alerts: {str(e)}") 