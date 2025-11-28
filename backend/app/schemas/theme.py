"""
Theme Customization Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from uuid import UUID
from datetime import datetime


# Theme Settings Structure
class ThemeColors(BaseModel):
    primary: str = Field(default="#F36F21", description="Primary color")
    secondary: str = Field(default="#D2142C", description="Secondary color")
    accent: str = Field(default="#4CAF50", description="Accent color")
    background: str = Field(default="#FAF5EF", description="Background color")
    foreground: str = Field(default="#0D0D0D", description="Foreground/Text color")
    muted: str = Field(default="#3D3D3D", description="Muted color")
    border: str = Field(default="#D3D3D3", description="Border color")
    destructive: str = Field(default="#EF4444", description="Destructive color")
    success: str = Field(default="#10B981", description="Success color")
    warning: str = Field(default="#F59E0B", description="Warning color")


class HeadingSizes(BaseModel):
    h1: str = Field(default="3rem", description="H1 size")
    h2: str = Field(default="2.5rem", description="H2 size")
    h3: str = Field(default="2rem", description="H3 size")
    h4: str = Field(default="1.5rem", description="H4 size")
    h5: str = Field(default="1.25rem", description="H5 size")
    h6: str = Field(default="1rem", description="H6 size")


class ThemeTypography(BaseModel):
    fontFamily: str = Field(default="Noto Serif Thai", description="Font family")
    baseFontSize: str = Field(default="18px", description="Base font size")
    headingSizes: HeadingSizes = Field(default_factory=HeadingSizes)
    lineHeight: str = Field(default="1.6", description="Line height")
    letterSpacing: str = Field(default="0em", description="Letter spacing")
    fontWeight: str = Field(default="400", description="Font weight")


class ThemeSpacing(BaseModel):
    base: str = Field(default="1rem", description="Base spacing")
    cardPadding: str = Field(default="1.5rem", description="Card padding")
    buttonPadding: str = Field(default="0.75rem 1.5rem", description="Button padding")
    inputPadding: str = Field(default="0.75rem 1rem", description="Input padding")
    sectionSpacing: str = Field(default="3rem", description="Section spacing")


class ThemeLayout(BaseModel):
    containerMaxWidth: str = Field(default="100%", description="Container max width")
    sidebarWidth: str = Field(default="16rem", description="Sidebar width")
    headerHeight: str = Field(default="5rem", description="Header height")
    footerHeight: str = Field(default="auto", description="Footer height")
    gridGaps: str = Field(default="1rem", description="Grid gaps")


class ComponentStyles(BaseModel):
    borderRadius: str = Field(default="0.5rem", description="Border radius")
    shadow: str = Field(default="0 2px 4px rgba(0,0,0,0.1)", description="Shadow")


class ThemeComponents(BaseModel):
    button: ComponentStyles = Field(default_factory=lambda: ComponentStyles(borderRadius="0.5rem", shadow="0 2px 4px rgba(0,0,0,0.1)"))
    card: ComponentStyles = Field(default_factory=lambda: ComponentStyles(borderRadius="0.75rem", shadow="0 4px 6px rgba(0,0,0,0.1)"))
    input: ComponentStyles = Field(default_factory=lambda: ComponentStyles(borderRadius="0.5rem", shadow="none"))
    table: ComponentStyles = Field(default_factory=lambda: ComponentStyles(borderRadius="0.5rem", shadow="none"))


class ThemeEffects(BaseModel):
    borderRadius: str = Field(default="0.75rem", description="Global border radius")
    shadow: str = Field(default="0 2px 8px rgba(0,0,0,0.1)", description="Global shadow")
    transition: str = Field(default="0.2s ease", description="Transition")
    hoverEffect: str = Field(default="scale(1.02)", description="Hover effect")


class ThemeSettings(BaseModel):
    """Complete theme settings"""
    colors: ThemeColors = Field(default_factory=ThemeColors)
    typography: ThemeTypography = Field(default_factory=ThemeTypography)
    spacing: ThemeSpacing = Field(default_factory=ThemeSpacing)
    layout: ThemeLayout = Field(default_factory=ThemeLayout)
    components: ThemeComponents = Field(default_factory=ThemeComponents)
    effects: ThemeEffects = Field(default_factory=ThemeEffects)


# Request/Response Schemas
class ThemeCreate(BaseModel):
    name: str = Field(..., min_length=1, description="Theme name")
    description: Optional[str] = None
    is_preset: bool = Field(default=False)
    settings: ThemeSettings = Field(default_factory=ThemeSettings)


class ThemeUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    settings: Optional[ThemeSettings] = None


class ThemeResponse(BaseModel):
    id: UUID
    name: str
    description: Optional[str]
    is_preset: bool
    is_active: bool
    created_by: Optional[UUID]
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class ThemeWithSettingsResponse(BaseModel):
    id: UUID
    name: str
    description: Optional[str]
    is_preset: bool
    is_active: bool
    settings: Dict[str, Any]
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class ApplyThemeRequest(BaseModel):
    theme_id: UUID
    preview: bool = Field(default=False, description="Preview mode (don't apply)")

