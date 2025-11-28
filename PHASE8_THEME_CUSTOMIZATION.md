# Phase 8: Theme Customization System (เทพช้อป)

## 🎯 เป้าหมาย

สร้างระบบปรับแต่ง Theme/UI สำหรับ Admin ที่สามารถ:
- ปรับแต่งได้ทุกหน้าของเว็บ
- มี Theme Presets ให้เลือก
- Custom ได้อย่างละเอียด
- Preview แบบ Real-time
- Save/Load Themes

---

## 📋 Features

### 1. Visual Theme Editor

#### Colors
- Primary Color (Picker + Hex input)
- Secondary Color
- Accent Color
- Background Color
- Foreground/Text Color
- Border Color
- Muted Colors
- Destructive Color
- Success Color
- Warning Color

#### Typography
- Font Family (เลือกจาก Google Fonts หรือ Custom)
- Base Font Size (Global)
- Heading Sizes (H1-H6)
- Line Height
- Letter Spacing
- Font Weight

#### Spacing
- Base Padding
- Base Margin
- Card Padding
- Button Padding
- Input Padding
- Section Spacing

#### Layout
- Container Max Width
- Sidebar Width
- Header Height
- Footer Height
- Grid Gaps

#### Components
- Button Styles (Size, Border Radius, Shadow)
- Card Styles (Border, Shadow, Border Radius)
- Input Styles
- Table Styles
- Badge Styles
- Modal/Dialog Styles

#### Effects
- Border Radius (Global)
- Shadow Levels
- Transitions
- Hover Effects

---

### 2. Theme Presets

#### Default Themes
- **Default FUN Theme** (Current)
- **High Contrast Theme** (สำหรับผู้สูงอายุ)
- **Large Text Theme** (Font ใหญ่ขึ้น)
- **Compact Theme** (Spacing น้อยลง)
- **Colorful Theme** (สีสันมากขึ้น)
- **Minimal Theme** (เรียบง่าย)

#### Custom Presets
- Admin สามารถสร้าง Preset เองได้
- Save as New Preset
- Delete Preset
- Export/Import Preset (JSON)

---

### 3. Real-time Preview

- Live Preview Panel
- Preview หลาย Device (Mobile, Tablet, Desktop)
- Preview หลายหน้า (Dashboard, Public, Admin)
- Undo/Redo
- Reset to Default

---

### 4. Save & Apply

- Save Theme (บันทึกใน Database)
- Apply Theme (ใช้ทันที)
- Preview Before Apply
- Rollback (ย้อนกลับ)
- Export Theme (JSON)
- Import Theme (JSON)

---

## 🏗️ Architecture

### Backend

#### Database Schema
```sql
-- Theme configurations
CREATE TABLE themes (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  is_preset BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT false,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Theme settings (JSON)
CREATE TABLE theme_settings (
  id UUID PRIMARY KEY,
  theme_id UUID REFERENCES themes(id),
  settings JSONB NOT NULL, -- All theme configs
  version INTEGER DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW()
);

-- User theme preferences
CREATE TABLE user_theme_preferences (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  theme_id UUID REFERENCES themes(id),
  custom_settings JSONB, -- Override specific settings
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### API Endpoints
```
GET    /api/themes                    # List all themes
GET    /api/themes/:id                # Get theme details
POST   /api/themes                    # Create new theme
PUT    /api/themes/:id                # Update theme
DELETE /api/themes/:id                # Delete theme
POST   /api/themes/:id/apply          # Apply theme
POST   /api/themes/:id/preview        # Preview theme
GET    /api/themes/presets            # Get preset themes
POST   /api/themes/export/:id         # Export theme as JSON
POST   /api/themes/import             # Import theme from JSON
GET    /api/themes/active             # Get active theme
```

---

### Frontend

#### Components Structure
```
src/
├── components/
│   ├── theme-editor/
│   │   ├── ThemeEditor.tsx           # Main editor component
│   │   ├── ColorPicker.tsx           # Color picker
│   │   ├── FontSelector.tsx          # Font selector
│   │   ├── SpacingControl.tsx        # Spacing controls
│   │   ├── LayoutControl.tsx         # Layout controls
│   │   ├── ComponentPreview.tsx      # Component preview
│   │   ├── ThemePresets.tsx          # Preset selector
│   │   └── PreviewPanel.tsx          # Preview panel
│   └── theme-provider/
│       ├── ThemeProvider.tsx         # Theme context provider
│       └── useTheme.ts               # Theme hook
├── pages/
│   └── admin/
│       └── ThemeCustomization.tsx    # Main page
└── stores/
    └── themeStore.ts                 # Theme state management
```

#### Theme System
- CSS Variables (CSS Custom Properties)
- Dynamic CSS Injection
- Theme Context (React Context)
- Local Storage (Cache)
- Real-time Updates

---

## 🎨 Implementation Plan

### Step 1: Theme Infrastructure
1. Create database tables
2. Create API endpoints
3. Create Theme Provider
4. Setup CSS Variables system

### Step 2: Theme Editor UI
1. Create Theme Editor page
2. Color Picker component
3. Typography controls
4. Spacing controls
5. Layout controls

### Step 3: Preview System
1. Real-time preview
2. Multi-device preview
3. Multi-page preview
4. Undo/Redo

### Step 4: Presets System
1. Default presets
2. Save custom preset
3. Load preset
4. Delete preset

### Step 5: Save & Apply
1. Save theme to database
2. Apply theme
3. Export/Import
4. Rollback

---

## 📊 Data Model

### Theme Settings JSON Structure
```json
{
  "colors": {
    "primary": "#F36F21",
    "secondary": "#D2142C",
    "accent": "#4CAF50",
    "background": "#FAF5EF",
    "foreground": "#0D0D0D",
    "muted": "#3D3D3D",
    "border": "#D3D3D3"
  },
  "typography": {
    "fontFamily": "Noto Serif Thai",
    "baseFontSize": "18px",
    "headingSizes": {
      "h1": "3rem",
      "h2": "2.5rem",
      "h3": "2rem",
      "h4": "1.5rem",
      "h5": "1.25rem",
      "h6": "1rem"
    },
    "lineHeight": "1.6",
    "letterSpacing": "0em"
  },
  "spacing": {
    "base": "1rem",
    "cardPadding": "1.5rem",
    "buttonPadding": "0.75rem 1.5rem",
    "sectionSpacing": "3rem"
  },
  "layout": {
    "containerMaxWidth": "100%",
    "sidebarWidth": "16rem",
    "headerHeight": "5rem"
  },
  "components": {
    "button": {
      "borderRadius": "0.5rem",
      "shadow": "0 2px 4px rgba(0,0,0,0.1)"
    },
    "card": {
      "borderRadius": "0.75rem",
      "shadow": "0 4px 6px rgba(0,0,0,0.1)"
    }
  },
  "effects": {
    "borderRadius": "0.75rem",
    "shadow": "0 2px 8px rgba(0,0,0,0.1)",
    "transition": "0.2s ease"
  }
}
```

---

## 🔧 Technical Details

### CSS Variables Injection
```typescript
// Dynamic CSS variable injection
const applyTheme = (settings: ThemeSettings) => {
  const root = document.documentElement;
  
  // Colors
  root.style.setProperty('--primary', settings.colors.primary);
  root.style.setProperty('--secondary', settings.colors.secondary);
  // ... etc
  
  // Typography
  root.style.setProperty('--font-family', settings.typography.fontFamily);
  root.style.setProperty('--font-size-base', settings.typography.baseFontSize);
  // ... etc
};
```

### Theme Context
```typescript
interface ThemeContextType {
  currentTheme: Theme;
  settings: ThemeSettings;
  applyTheme: (themeId: string) => Promise<void>;
  updateSettings: (settings: Partial<ThemeSettings>) => void;
  saveTheme: (name: string) => Promise<void>;
  resetTheme: () => void;
  previewTheme: (settings: ThemeSettings) => void;
}
```

---

## 📝 User Flow

1. Admin เข้า Theme Customization page
2. เลือก Preset หรือเริ่มจาก Default
3. ปรับแต่ง Colors, Typography, Spacing, Layout
4. ดู Preview แบบ Real-time
5. Save Theme (ตั้งชื่อ)
6. Apply Theme (ใช้ทันที)
7. Export Theme (ถ้าต้องการ)

---

## ✅ Success Criteria

- [ ] Admin สามารถปรับแต่ง Theme ได้
- [ ] มี Presets ให้เลือก
- [ ] Preview แบบ Real-time
- [ ] Save/Load Themes
- [ ] Export/Import Themes
- [ ] Apply Theme ทันที
- [ ] ทำงานได้ทุกหน้า

---

## 🎯 Priority

**Phase 8** - หลังจาก Phase 1-7 เสร็จแล้ว

---

**Status:** 📋 Planned

**Next:** เริ่มทำหลังจาก Phase 7 เสร็จ

