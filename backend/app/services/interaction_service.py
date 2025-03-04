from typing import List, Dict
from ..models.medicine import Medicine
from ..firebase_admin import db

class InteractionService:
    # Common drug interaction categories
    INTERACTION_CATEGORIES = {
        "severe": {
            "description": "Avoid combination - serious interaction possible",
            "action": "Do not take these medicines together without medical supervision"
        },
        "moderate": {
            "description": "Use with caution - monitor for side effects",
            "action": "Take at different times or consult healthcare provider"
        },
        "minor": {
            "description": "Minor interaction possible",
            "action": "Monitor for minor side effects"
        }
    }

    @staticmethod
    async def check_interactions(medicine_id: str, first_aid_kit_id: str) -> List[Dict]:
        """Check interactions between a medicine and others in the first aid kit"""
        try:
            # Get the medicine details
            med_ref = db.collection('medicines').document(medicine_id)
            med = med_ref.get()
            
            if not med.exists:
                return []
                
            medicine = med.to_dict()
            active_substance = medicine.get('active_substance', '').lower()
            
            # Get other medicines in the same first aid kit
            medicines_ref = db.collection('medicines')
            other_medicines = medicines_ref.where(
                'first_aid_kit_id', '==', first_aid_kit_id
            ).where(
                'id', '!=', medicine_id
            ).stream()
            
            interactions = []
            for other_med in other_medicines:
                other_med_data = other_med.to_dict()
                other_substance = other_med_data.get('active_substance', '').lower()
                
                # Check for known interactions
                interaction = InteractionService._check_substance_interaction(
                    active_substance,
                    other_substance
                )
                
                if interaction:
                    interactions.append({
                        'medicine': other_med_data,
                        'severity': interaction['severity'],
                        'description': interaction['description'],
                        'recommendation': interaction['recommendation']
                    })
            
            return interactions
        except Exception as e:
            print(f"Error checking interactions: {str(e)}")
            return []

    @staticmethod
    def _check_substance_interaction(substance1: str, substance2: str) -> Dict:
        """Check interaction between two active substances"""
        # This is a simplified version. In a real application, you would:
        # 1. Use a comprehensive drug interaction database
        # 2. Consider multiple active ingredients
        # 3. Account for drug classes and categories
        # 4. Include more detailed interaction information
        
        # Example interactions (you should replace with real data)
        KNOWN_INTERACTIONS = {
            ('aspirin', 'ibuprofen'): {
                'severity': 'moderate',
                'description': 'May increase risk of bleeding',
                'recommendation': 'Space doses apart by at least 8 hours'
            },
            ('warfarin', 'aspirin'): {
                'severity': 'severe',
                'description': 'Increased risk of serious bleeding',
                'recommendation': 'Avoid combination unless directed by healthcare provider'
            },
            # Add more interactions...
        }
        
        # Check both combinations (order doesn't matter)
        interaction = KNOWN_INTERACTIONS.get(
            (substance1, substance2)
        ) or KNOWN_INTERACTIONS.get(
            (substance2, substance1)
        )
        
        return interaction

    @staticmethod
    async def get_interaction_warnings(medicine_id: str, first_aid_kit_id: str) -> Dict:
        """Get formatted interaction warnings for a medicine"""
        try:
            interactions = await InteractionService.check_interactions(
                medicine_id,
                first_aid_kit_id
            )
            
            warnings = {
                'severe': [],
                'moderate': [],
                'minor': []
            }
            
            for interaction in interactions:
                severity = interaction['severity']
                if severity in warnings:
                    warnings[severity].append({
                        'medicine_name': interaction['medicine']['name'],
                        'description': interaction['description'],
                        'recommendation': interaction['recommendation']
                    })
            
            return {
                'has_warnings': any(len(w) > 0 for w in warnings.values()),
                'warnings': warnings,
                'categories': InteractionService.INTERACTION_CATEGORIES
            }
        except Exception as e:
            print(f"Error getting interaction warnings: {str(e)}")
            return {
                'has_warnings': False,
                'warnings': {},
                'categories': InteractionService.INTERACTION_CATEGORIES
            } 