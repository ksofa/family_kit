from typing import List
import os
from datetime import datetime
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph
from reportlab.lib.styles import getSampleStyleSheet
from ..models.history import MedicineLog
from ..firebase_admin import storage

class ReportService:
    @staticmethod
    async def generate_pdf_report(logs: List[MedicineLog], user_name: str) -> str:
        """Generate PDF report from medicine logs"""
        try:
            # Create temporary file
            filename = f"report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pdf"
            filepath = f"/tmp/{filename}"
            
            # Create PDF document
            doc = SimpleDocTemplate(
                filepath,
                pagesize=letter,
                rightMargin=72,
                leftMargin=72,
                topMargin=72,
                bottomMargin=72
            )
            
            # Define styles
            styles = getSampleStyleSheet()
            title_style = styles['Heading1']
            
            # Create content
            elements = []
            
            # Add title
            title = Paragraph(
                f"Medicine Log Report - {user_name}",
                title_style
            )
            elements.append(title)
            
            # Create table data
            data = [['Date', 'Time', 'Medicine', 'Dosage', 'Status', 'Notes']]
            
            for log in logs:
                data.append([
                    log.date.strftime('%Y-%m-%d'),
                    log.time.strftime('%H:%M'),
                    log.medicine_id,  # You might want to fetch medicine name
                    f"{log.dosage} {log.unit}",
                    log.status,
                    log.notes or ''
                ])
            
            # Create table
            table = Table(data)
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 14),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
                ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
                ('FONTSIZE', (0, 1), (-1, -1), 12),
                ('GRID', (0, 0), (-1, -1), 1, colors.black)
            ]))
            
            elements.append(table)
            
            # Build PDF
            doc.build(elements)
            
            # Upload to Firebase Storage
            bucket = storage.bucket()
            blob = bucket.blob(f"reports/{filename}")
            blob.upload_from_filename(filepath)
            
            # Make the file publicly accessible
            blob.make_public()
            
            # Clean up temporary file
            os.remove(filepath)
            
            return blob.public_url
            
        except Exception as e:
            print(f"Error generating PDF report: {str(e)}")
            raise e 