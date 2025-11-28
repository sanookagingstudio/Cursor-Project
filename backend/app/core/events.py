"""Event Bus for inter-module communication"""
from typing import Dict, Any
import json
from datetime import datetime
from app.core.redis import get_redis
from app.core.config import settings


class EventBus:
    """Event Bus using Redis pub/sub"""
    
    def __init__(self):
        self.redis = get_redis()
        self.channel_prefix = "media_creator"
    
    def publish_event(
        self,
        event_type: str,
        payload: Dict[str, Any],
        source: str = "media_creator_core"
    ):
        """Publish event to event bus"""
        event = {
            "event_type": event_type,
            "timestamp": datetime.utcnow().isoformat(),
            "source": source,
            "payload": payload
        }
        
        channel = f"{self.channel_prefix}.{event_type.lower()}"
        
        try:
            self.redis.publish(channel, json.dumps(event))
            return True
        except Exception as e:
            print(f"Failed to publish event: {e}")
            return False
    
    def subscribe(self, event_type: str, callback):
        """Subscribe to event type"""
        pubsub = self.redis.pubsub()
        channel = f"{self.channel_prefix}.{event_type.lower()}"
        pubsub.subscribe(channel)
        
        for message in pubsub.listen():
            if message["type"] == "message":
                try:
                    event = json.loads(message["data"])
                    callback(event)
                except Exception as e:
                    print(f"Error processing event: {e}")


# Global event bus instance
event_bus = EventBus()


# Convenience functions
def publish_event(event_type: str, payload: Dict[str, Any], source: str = "media_creator_core"):
    """Publish event"""
    return event_bus.publish_event(event_type, payload, source)


# Event types
class EventTypes:
    """Standard event types"""
    # Job events
    JOB_CREATED = "JOB_CREATED"
    JOB_STARTED = "JOB_STARTED"
    JOB_COMPLETED = "JOB_COMPLETED"
    JOB_FAILED = "JOB_FAILED"
    JOB_CANCELLED = "JOB_CANCELLED"
    
    # Asset events
    ASSET_CREATED = "ASSET_CREATED"
    ASSET_UPDATED = "ASSET_UPDATED"
    ASSET_DELETED = "ASSET_DELETED"
    
    # Workflow events
    WORKFLOW_STARTED = "WORKFLOW_STARTED"
    WORKFLOW_COMPLETED = "WORKFLOW_COMPLETED"
    WORKFLOW_FAILED = "WORKFLOW_FAILED"
    
    # Module events
    MODULE_REGISTERED = "MODULE_REGISTERED"
    MODULE_UPDATED = "MODULE_UPDATED"
    
    # Content events
    CONTENT_PUBLISHED = "CONTENT_PUBLISHED"
    VIDEO_GENERATED = "VIDEO_GENERATED"
    IMAGE_GENERATED = "IMAGE_GENERATED"
    AUDIO_STEMS_CREATED = "AUDIO_STEMS_CREATED"
    MUSIC_ANALYZED = "MUSIC_ANALYZED"

