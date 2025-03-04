from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from .notification_service import NotificationService
from .alert_service import AlertService
from .reminder_service import ReminderService

scheduler = AsyncIOScheduler()

async def check_expiring_medicines_task():
    """Background task to check for expiring medicines"""
    await NotificationService.check_expiring_medicines()

async def process_alerts_task():
    """Background task to process alerts"""
    await AlertService.process_alerts()

async def process_reminders_task():
    """Background task to process medicine reminders"""
    await ReminderService.process_due_reminders()

def start_background_tasks():
    """Start all background tasks"""
    # Check expiring medicines daily at midnight
    scheduler.add_job(
        check_expiring_medicines_task,
        CronTrigger(hour=0, minute=0),
        id='check_expiring_medicines'
    )
    
    # Process alerts every 6 hours
    scheduler.add_job(
        process_alerts_task,
        CronTrigger(hour='*/6'),
        id='process_alerts'
    )
    
    # Process reminders every minute
    scheduler.add_job(
        process_reminders_task,
        CronTrigger(minute='*'),
        id='process_reminders'
    )
    
    scheduler.start() 