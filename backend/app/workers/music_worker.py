"""
Music & Audio Workers
Celery tasks for stem separation, music analysis, tab generation, and music generation
"""

from celery import shared_task
from typing import Dict, Any
from uuid import UUID
from app.core.celery_app import celery_app
from app.core.db import SessionLocal
from app.models.job import Job
from app.models.asset import Asset
from app.models.music import AudioAnalysis, StemGroup, TabRecord
from app.providers.audio_provider_base import AudioProviderBase
from app.providers.audio_mock import MockAudioProvider
from app.core.events import publish_event


@shared_task(name="audio.stems", bind=True)
def separate_stems_task(self, job_id: str):
    """
    Separate audio into stems
    
    Args:
        job_id: Job ID
    """
    db = SessionLocal()
    job = None
    try:
        job = db.query(Job).filter(Job.id == UUID(job_id)).first()
        if not job:
            return {"status": "error", "message": "Job not found"}
        
        job.status = "processing"
        db.commit()
        
        # Get input payload
        input_data = job.input_payload or {}
        asset_id = input_data.get("asset_id")
        stems = input_data.get("stems", ["vocal", "drums", "bass", "other"])
        provider_name = input_data.get("provider", "mock")
        
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == UUID(asset_id)).first()
        if not source_asset:
            job.status = "failed"
            job.output_payload = {"error": "Source asset not found"}
            db.commit()
            return {"status": "error", "message": "Source asset not found"}
        
        # Get provider
        provider: AudioProviderBase = MockAudioProvider()
        
        # Separate stems
        result = provider.separate_stems(
            audio_path=source_asset.path,
            stems=stems
        )
        
        # Create stem assets
        stem_assets = {}
        for stem_type, stem_path in result.stems.items():
            stem_asset = Asset(
                project_id=job.project_id,
                type="audio",
                path=stem_path,
                provider=provider_name,
                meta_data={
                    "stem_type": stem_type,
                    "source_asset_id": asset_id,
                    **result.metadata
                }
            )
            db.add(stem_asset)
            db.flush()
            stem_assets[stem_type] = str(stem_asset.id)
        
        db.commit()
        
        # Create stem group
        stem_group = StemGroup(
            source_asset_id=UUID(asset_id),
            stem_assets=stem_assets,
            provider=provider_name
        )
        db.add(stem_group)
        db.commit()
        db.refresh(stem_group)
        
        # Update job
        job.status = "completed"
        job.output_payload = {
            "stem_group_id": str(stem_group.id),
            "stem_assets": stem_assets
        }
        db.commit()
        
        # Publish events
        for stem_asset_id in stem_assets.values():
            publish_event("ASSET_CREATED", {
                "asset_id": stem_asset_id,
                "type": "audio",
                "job_id": job_id
            })
        
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "audio.stems"
        })
        
        return {
            "status": "completed",
            "stem_group_id": str(stem_group.id),
            "stem_assets": stem_assets
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        publish_event("JOB_FAILED", {
            "job_id": job_id,
            "type": "audio.stems",
            "error": str(e)
        })
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


@shared_task(name="music.analyze", bind=True)
def analyze_music_task(self, job_id: str):
    """
    Analyze music properties
    
    Args:
        job_id: Job ID
    """
    db = SessionLocal()
    job = None
    try:
        job = db.query(Job).filter(Job.id == UUID(job_id)).first()
        if not job:
            return {"status": "error", "message": "Job not found"}
        
        job.status = "processing"
        db.commit()
        
        # Get input payload
        input_data = job.input_payload or {}
        asset_id = input_data.get("asset_id")
        tasks = input_data.get("tasks", ["bpm", "key", "chords", "sections"])
        provider_name = input_data.get("provider", "mock")
        
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == UUID(asset_id)).first()
        if not source_asset:
            job.status = "failed"
            job.output_payload = {"error": "Source asset not found"}
            db.commit()
            return {"status": "error", "message": "Source asset not found"}
        
        # Get provider
        provider: AudioProviderBase = MockAudioProvider()
        
        # Analyze music
        result = provider.analyze_music(
            audio_path=source_asset.path,
            tasks=tasks
        )
        
        # Create analysis record
        analysis = AudioAnalysis(
            asset_id=UUID(asset_id),
            bpm=result.bpm,
            key=result.key,
            time_signature=result.time_signature,
            sections=result.sections,
            chord_progression=result.chord_progression,
            energy_curve=result.energy_curve,
            metadata=result.metadata
        )
        db.add(analysis)
        db.commit()
        db.refresh(analysis)
        
        # Update job
        job.status = "completed"
        job.output_payload = {
            "analysis_id": str(analysis.id),
            "bpm": result.bpm,
            "key": result.key,
            "time_signature": result.time_signature
        }
        db.commit()
        
        # Publish events
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "music.analyze"
        })
        
        return {
            "status": "completed",
            "analysis_id": str(analysis.id),
            "bpm": result.bpm,
            "key": result.key
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


@shared_task(name="music.tab", bind=True)
def generate_tab_task(self, job_id: str):
    """
    Generate tab for instrument
    
    Args:
        job_id: Job ID
    """
    db = SessionLocal()
    job = None
    try:
        job = db.query(Job).filter(Job.id == UUID(job_id)).first()
        if not job:
            return {"status": "error", "message": "Job not found"}
        
        job.status = "processing"
        db.commit()
        
        # Get input payload
        input_data = job.input_payload or {}
        asset_id = input_data.get("asset_id")
        instrument = input_data.get("instrument", "guitar")
        difficulty = input_data.get("difficulty", "original")
        format_type = input_data.get("format", "text")
        provider_name = input_data.get("provider", "mock")
        
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == UUID(asset_id)).first()
        if not source_asset:
            job.status = "failed"
            job.output_payload = {"error": "Source asset not found"}
            db.commit()
            return {"status": "error", "message": "Source asset not found"}
        
        # Get provider
        provider: AudioProviderBase = MockAudioProvider()
        
        # Generate tab
        tab_content = provider.generate_tab(
            audio_path=source_asset.path,
            instrument=instrument,
            difficulty=difficulty
        )
        
        # Create tab record
        tab_record = TabRecord(
            audio_asset_id=UUID(asset_id),
            instrument=instrument,
            difficulty=difficulty,
            format=format_type,
            content=tab_content
        )
        db.add(tab_record)
        db.commit()
        db.refresh(tab_record)
        
        # Update job
        job.status = "completed"
        job.output_payload = {
            "tab_id": str(tab_record.id),
            "instrument": instrument,
            "difficulty": difficulty
        }
        db.commit()
        
        # Publish events
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "music.tab"
        })
        
        return {
            "status": "completed",
            "tab_id": str(tab_record.id),
            "content": tab_content[:100] + "..." if len(tab_content) > 100 else tab_content
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


@shared_task(name="music.generate", bind=True)
def generate_music_task(self, job_id: str):
    """
    Generate music from prompt
    
    Args:
        job_id: Job ID
    """
    db = SessionLocal()
    job = None
    try:
        job = db.query(Job).filter(Job.id == UUID(job_id)).first()
        if not job:
            return {"status": "error", "message": "Job not found"}
        
        job.status = "processing"
        db.commit()
        
        # Get input payload
        input_data = job.input_payload or {}
        prompt = input_data.get("prompt")
        duration_seconds = input_data.get("duration_seconds", 30)
        tempo = input_data.get("tempo")
        key = input_data.get("key")
        mood = input_data.get("mood")
        instruments = input_data.get("instruments", [])
        provider_name = input_data.get("provider", "mock")
        
        # Get provider
        provider: AudioProviderBase = MockAudioProvider()
        
        # Generate music
        audio_path = provider.generate_music(
            prompt=prompt,
            duration_seconds=duration_seconds,
            tempo=tempo,
            key=key,
            mood=mood,
            instruments=instruments
        )
        
        # Create asset
        asset = Asset(
            project_id=job.project_id,
            type="audio",
            path=audio_path,
            provider=provider_name,
            meta_data={
                "duration": duration_seconds,
                "tempo": tempo,
                "key": key,
                "mood": mood,
                "instruments": instruments,
                "generated": True
            }
        )
        db.add(asset)
        db.commit()
        db.refresh(asset)
        
        # Update job
        job.status = "completed"
        job.output_payload = {
            "asset_id": str(asset.id),
            "url": audio_path
        }
        db.commit()
        
        # Publish events
        publish_event("ASSET_CREATED", {
            "asset_id": str(asset.id),
            "type": "audio",
            "job_id": job_id
        })
        
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "music.generate"
        })
        
        return {
            "status": "completed",
            "asset_id": str(asset.id),
            "url": audio_path
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


@shared_task(name="audio.remaster", bind=True)
def remaster_audio_task(self, job_id: str):
    """
    Remaster audio
    
    Args:
        job_id: Job ID
    """
    db = SessionLocal()
    job = None
    try:
        job = db.query(Job).filter(Job.id == UUID(job_id)).first()
        if not job:
            return {"status": "error", "message": "Job not found"}
        
        job.status = "processing"
        db.commit()
        
        # Get input payload
        input_data = job.input_payload or {}
        asset_id = input_data.get("asset_id")
        operations = input_data.get("operations", [])
        provider_name = input_data.get("provider", "mock")
        
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == UUID(asset_id)).first()
        if not source_asset:
            job.status = "failed"
            job.output_payload = {"error": "Source asset not found"}
            db.commit()
            return {"status": "error", "message": "Source asset not found"}
        
        # Get provider
        provider: AudioProviderBase = MockAudioProvider()
        
        # Remaster audio
        audio_path = provider.remaster(
            audio_path=source_asset.path,
            operations=operations
        )
        
        # Create new asset
        asset = Asset(
            project_id=job.project_id,
            type="audio",
            path=audio_path,
            provider=provider_name,
            meta_data={
                "source_asset_id": asset_id,
                "operations": operations,
                "remastered": True
            }
        )
        db.add(asset)
        db.commit()
        db.refresh(asset)
        
        # Update job
        job.status = "completed"
        job.output_payload = {
            "asset_id": str(asset.id),
            "url": audio_path
        }
        db.commit()
        
        # Publish events
        publish_event("ASSET_CREATED", {
            "asset_id": str(asset.id),
            "type": "audio",
            "job_id": job_id
        })
        
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "audio.remaster"
        })
        
        return {
            "status": "completed",
            "asset_id": str(asset.id),
            "url": audio_path
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()

