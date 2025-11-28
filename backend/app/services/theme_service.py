"""
Theme Service
Business logic for theme management
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from sqlalchemy.orm import Session
from app.models.theme import Theme, ThemeSetting, UserThemePreference
from app.schemas.theme import ThemeCreate, ThemeUpdate, ThemeSettings
from app.core.events import publish_event


class ThemeService:
    """Service for theme operations"""
    
    def create_theme(
        self,
        db: Session,
        theme_data: ThemeCreate,
        user_id: Optional[UUID] = None
    ) -> Theme:
        """Create new theme"""
        theme = Theme(
            name=theme_data.name,
            description=theme_data.description,
            is_preset=theme_data.is_preset,
            created_by=user_id
        )
        db.add(theme)
        db.flush()
        
        # Create theme settings
        theme_setting = ThemeSetting(
            theme_id=theme.id,
            settings=theme_data.settings.model_dump() if hasattr(theme_data.settings, 'model_dump') else theme_data.settings.dict()
        )
        db.add(theme_setting)
        db.commit()
        db.refresh(theme)
        
        publish_event("THEME_CREATED", {
            "theme_id": str(theme.id),
            "name": theme.name
        })
        
        return theme
    
    def get_themes(self, db: Session, include_presets: bool = True) -> List[Theme]:
        """Get all themes"""
        query = db.query(Theme)
        if not include_presets:
            query = query.filter(Theme.is_preset == False)
        return query.order_by(Theme.created_at.desc()).all()
    
    def get_presets(self, db: Session) -> List[Theme]:
        """Get preset themes"""
        return db.query(Theme).filter(Theme.is_preset == True).all()
    
    def get_theme(self, db: Session, theme_id: UUID) -> Optional[Theme]:
        """Get theme by ID"""
        return db.query(Theme).filter(Theme.id == theme_id).first()
    
    def get_active_theme(self, db: Session) -> Optional[Theme]:
        """Get active theme"""
        return db.query(Theme).filter(Theme.is_active == True).first()
    
    def get_theme_settings(self, db: Session, theme_id: UUID) -> Optional[Dict[str, Any]]:
        """Get theme settings"""
        setting = db.query(ThemeSetting).filter(
            ThemeSetting.theme_id == theme_id
        ).order_by(ThemeSetting.version.desc()).first()
        
        if setting:
            return setting.settings
        return None
    
    def update_theme(
        self,
        db: Session,
        theme_id: UUID,
        theme_data: ThemeUpdate
    ) -> Theme:
        """Update theme"""
        theme = self.get_theme(db, theme_id)
        if not theme:
            raise ValueError("Theme not found")
        
        if theme_data.name:
            theme.name = theme_data.name
        if theme_data.description is not None:
            theme.description = theme_data.description
        
        # Update settings if provided
        if theme_data.settings:
            # Create new version
            new_setting = ThemeSetting(
                theme_id=theme.id,
                settings=theme_data.settings.model_dump() if hasattr(theme_data.settings, 'model_dump') else theme_data.settings.dict(),
                version=db.query(ThemeSetting).filter(ThemeSetting.theme_id == theme_id).count() + 1
            )
            db.add(new_setting)
        
        db.commit()
        db.refresh(theme)
        
        publish_event("THEME_UPDATED", {
            "theme_id": str(theme_id)
        })
        
        return theme
    
    def delete_theme(self, db: Session, theme_id: UUID) -> bool:
        """Delete theme"""
        theme = self.get_theme(db, theme_id)
        if not theme:
            raise ValueError("Theme not found")
        
        if theme.is_preset:
            raise ValueError("Cannot delete preset theme")
        
        db.delete(theme)
        db.commit()
        
        publish_event("THEME_DELETED", {
            "theme_id": str(theme_id)
        })
        
        return True
    
    def apply_theme(
        self,
        db: Session,
        theme_id: UUID,
        preview: bool = False
    ) -> Theme:
        """Apply theme"""
        theme = self.get_theme(db, theme_id)
        if not theme:
            raise ValueError("Theme not found")
        
        if not preview:
            # Deactivate all themes
            db.query(Theme).update({"is_active": False})
            
            # Activate this theme
            theme.is_active = True
            db.commit()
            
            publish_event("THEME_APPLIED", {
                "theme_id": str(theme_id),
                "name": theme.name
            })
        
        return theme
    
    def get_user_preference(self, db: Session, user_id: UUID) -> Optional[UserThemePreference]:
        """Get user theme preference"""
        return db.query(UserThemePreference).filter(
            UserThemePreference.user_id == user_id
        ).first()
    
    def set_user_preference(
        self,
        db: Session,
        user_id: UUID,
        theme_id: Optional[UUID] = None,
        custom_settings: Optional[Dict[str, Any]] = None
    ) -> UserThemePreference:
        """Set user theme preference"""
        preference = self.get_user_preference(db, user_id)
        
        if preference:
            if theme_id:
                preference.theme_id = theme_id
            if custom_settings:
                preference.custom_settings = custom_settings
        else:
            preference = UserThemePreference(
                user_id=user_id,
                theme_id=theme_id,
                custom_settings=custom_settings
            )
            db.add(preference)
        
        db.commit()
        db.refresh(preference)
        
        return preference

