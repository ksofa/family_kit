import random
import string
from datetime import datetime, timedelta
from ..firebase_admin import db

class AccessCodeService:
    @staticmethod
    def generate_access_code() -> str:
        """Generate a unique access code in format FAM-XXXX-XXXX"""
        while True:
            # Generate random code
            code = 'FAM-' + ''.join(random.choices(string.digits, k=4)) + '-' + \
                  ''.join(random.choices(string.digits, k=4))
            
            # Check if code already exists
            existing = db.collection('access_codes').document(code).get()
            if not existing.exists:
                return code

    @staticmethod
    async def create_access_code(first_aid_kit_id: str, role: str) -> str:
        """Create a new access code for a first aid kit"""
        code = AccessCodeService.generate_access_code()
        
        # Store code in Firestore with 24-hour expiration
        db.collection('access_codes').document(code).set({
            'first_aid_kit_id': first_aid_kit_id,
            'role': role,
            'expires_at': datetime.utcnow() + timedelta(hours=24)
        })
        
        return code

    @staticmethod
    async def validate_access_code(code: str) -> dict:
        """Validate access code and return first aid kit info"""
        code_ref = db.collection('access_codes').document(code)
        code_doc = code_ref.get()
        
        if not code_doc.exists:
            return None
            
        code_data = code_doc.to_dict()
        
        # Check if code has expired
        if code_data['expires_at'] < datetime.utcnow():
            code_ref.delete()
            return None
            
        return code_data 