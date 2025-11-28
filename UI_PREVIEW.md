# 🎨 UI Preview - FunAging Studio Platform

## 📱 ภาพรวมการออกแบบ

เว็บไซต์ใช้ **Modern Design System** ด้วย:
- **shadcn/ui** components (Radix UI based)
- **Tailwind CSS** สำหรับ styling
- **Responsive Design** (Mobile-first)
- **Dark/Light Theme** support
- **Accessibility** (WCAG compliant)

---

## 🏠 หน้าแรก (Homepage) - `/`

### Layout Structure

```
┌─────────────────────────────────────────────────┐
│  HEADER (Sticky)                                │
│  [Logo] [Nav Items] [Language] [Sign In] [Join] │
└─────────────────────────────────────────────────┘
│                                                 │
│  HERO SECTION                                   │
│  ┌─────────────────┐  ┌──────────────────┐     │
│  │ [Badge]         │  │                  │     │
│  │ Title (Large)   │  │   Hero Image     │     │
│  │ Description     │  │   (500px height)│     │
│  │ [CTA Buttons]   │  │                  │     │
│  └─────────────────┘  └──────────────────┘     │
│                                                 │
│  FEATURES GRID                                  │
│  ┌──────┐ ┌──────┐ ┌──────┐                   │
│  │ 💚   │ │ 🛡️   │ │ 👥   │                   │
│  │Health│ │Safety│ │Social│                   │
│  └──────┘ └──────┘ └──────┘                   │
│                                                 │
│  ACTIVITIES SECTION                             │
│  ┌────────┐ ┌────────┐ ┌────────┐            │
│  │Morning │ │Art      │ │Brain   │            │
│  │Exercise│ │Craft    │ │Games   │            │
│  └────────┘ └────────┘ └────────┘            │
│                                                 │
│  TESTIMONIALS                                   │
│  [Carousel with member reviews]                │
│                                                 │
│  CTA SECTION                                    │
│  [Join Now] [Contact Us]                        │
│                                                 │
└─────────────────────────────────────────────────┘
│  FOOTER (Desktop only)                         │
│  [Company Info] [Links] [Support] [Contact]    │
└─────────────────────────────────────────────────┘
│  MOBILE BOTTOM NAV (Mobile only)               │
│  [Home] [Activities] [Trips] [Media] [Account] │
└─────────────────────────────────────────────────┘
```

### Design Elements

**Header:**
- Logo: `fun-logo-2025.png` (height: 56px)
- Brand: "FunAging Studio" + "Active Aging Ecosystem"
- Navigation: Ghost buttons with hover effects
- Language Switcher: Dropdown (TH/EN)
- CTA Buttons: "Sign In" (ghost) + "Join Now" (primary, `btn-elderly` class)

**Hero Section:**
- Background: `gradient-warm` class
- Badge: Primary color with rounded-full
- Title: 4xl-6xl font-bold
- Description: xl text-muted-foreground
- Buttons: Large size with `btn-elderly` class
- Image: Rounded-2xl with shadow-large

**Activity Cards:**
- Image: Top section
- Title + Description
- Time, Duration, Capacity
- Intensity badge (Low/Medium/High)
- Tags (Wellness, Outdoor, Social, etc.)

**Mobile Navigation:**
- Fixed bottom bar (height: 80px)
- Icons + Labels
- Active state highlighting

---

## 👤 Member Dashboard - `/member/dashboard`

### Layout Structure

```
┌─────────────────────────────────────────────────┐
│  MEMBER LAYOUT                                  │
│  ┌──────────┐  ┌─────────────────────────────┐ │
│  │ SIDEBAR  │  │  MAIN CONTENT               │ │
│  │          │  │                             │ │
│  │ Dashboard│  │  Welcome Header             │ │
│  │ Profile  │  │  [Premium Card Style]       │ │
│  │ Activities│ │                             │ │
│  │ Trips    │  │  Health Metrics             │ │
│  │ Documents│  │  ┌────┐ ┌────┐ ┌────┐      │ │
│  │ Notif... │  │  │❤️  │ │📊  │ │📈  │      │ │
│  │ Settings │  │  │HR  │ │BP  │ │Steps│     │ │
│  │          │  │  └────┘ └────┘ └────┘      │ │
│  └──────────┘  │                             │ │
│                │  Active Promotions           │ │
│                │  [Discount Cards]             │ │
│                │                             │ │
│                │  Personalized Tips           │ │
│                │  [Tip Cards with Icons]      │ │
│                │                             │ │
│                │  Upcoming Activities         │ │
│                │  [Calendar View]             │ │
│                └─────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Design Elements

**Welcome Header:**
- Gradient text: `from-primary via-accent to-primary`
- Premium card style with border
- User greeting

**Health Metrics:**
- Cards with icons (Heart, Activity, TrendingUp)
- Color coding: Green (normal), Blue (good)
- Values: Heart Rate, Blood Pressure, Steps

**Promotions:**
- Discount cards with:
  - Title
  - Discount percentage/amount
  - Expiry countdown
  - Urgent badge (if applicable)

**Personalized Tips:**
- Cards with category icons:
  - 🍎 Nutrition (Blood Type based)
  - 🌙 Zodiac (Aries energy)
  - 💧 Chakra Alignment
  - ☀️ Seasonal Wellness

**Upcoming Activities:**
- Calendar-style cards
- Date, Title, Time, Location

---

## 🔧 Admin Dashboard - `/admin/dashboard`

### Layout Structure

```
┌─────────────────────────────────────────────────┐
│  ADMIN LAYOUT                                   │
│  ┌──────────┐  ┌─────────────────────────────┐ │
│  │ SIDEBAR  │  │  TOP BAR                   │ │
│  │          │  │  [Menu] [Email] [Sign Out]  │ │
│  │ Dashboard│  ├─────────────────────────────┤ │
│  │ Staff    │  │  MAIN CONTENT               │ │
│  │ Customers│  │                             │ │
│  │ Schedule │  │  Stats Cards                │ │
│  │ Finance  │  │  ┌──────┐ ┌──────┐ ┌──────┐│ │
│  │ Billing  │  │  │Revenue│ │Member│ │Trips ││ │
│  │ Clients  │  │  │67,000 │ │ 248  │ │  8   ││ │
│  │ Trip Plan│  │  └──────┘ └──────┘ └──────┘│ │
│  │ Media    │  │                             │ │
│  │ AI       │  │  Quick Actions               │ │
│  │ Settings │  │  [Action Buttons]           │ │
│  │          │  │                             │ │
│  └──────────┘  │  Charts                      │ │
│                │  ┌──────────┐ ┌──────────┐   │ │
│                │  │ Revenue  │ │ Activity │   │ │
│                │  │  Chart   │ │  Chart   │   │ │
│                │  └──────────┘ └──────────┘   │ │
│                │                             │ │
│                │  Tables                      │ │
│                │  [Upcoming Trips Table]      │ │
│                │  [Today Activities Table]    │ │
│                └─────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Design Elements

**Sidebar:**
- Logo: KAI Icon (40x40px)
- "Admin Panel" + "Control Panel" text
- Collapsible menu items
- Active state: `bg-primary/10 text-primary`
- Icons from Lucide React

**Stats Cards:**
- Revenue Card: Total + Change percentage
- Member Stats: Total, New this month, Active today
- Trip Stats: Upcoming, This month, Completed

**Charts:**
- Revenue Chart (Recharts)
- Activity Chart (Recharts)
- Responsive grid layout

**Tables:**
- DataTable component
- Sortable columns
- Pagination

---

## 📋 Activities Page - `/activities`

### Layout Structure

```
┌─────────────────────────────────────────────────┐
│  PUBLIC LAYOUT                                  │
│  [Header]                                       │
├─────────────────────────────────────────────────┤
│                                                 │
│  SECTION HEADER                                 │
│  Title: "Activities"                            │
│  Description                                    │
│                                                 │
│  FILTER BAR                                     │
│  [Search] [Category] [Intensity] [Sort]         │
│                                                 │
│  ACTIVITIES GRID                                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ [Image]   │ │ [Image]  │ │ [Image]  │      │
│  │ Title     │ │ Title    │ │ Title    │      │
│  │ Desc...   │ │ Desc...  │ │ Desc...  │      │
│  │ ⏰ Time   │ │ ⏰ Time   │ │ ⏰ Time   │      │
│  │ 👥 20     │ │ 👥 15    │ │ 👥 25    │      │
│  │ [Tags]    │ │ [Tags]   │ │ [Tags]   │      │
│  │ [Button]  │ │ [Button] │ │ [Button] │      │
│  └──────────┘ └──────────┘ └──────────┘      │
│                                                 │
│  PAGINATION                                     │
│  [<] [1] [2] [3] [>]                           │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Activity Card Design

```
┌─────────────────────────────┐
│  [Activity Image]           │
│  (Aspect ratio 16:9)        │
├─────────────────────────────┤
│  Title (Bold)               │
│  Description (2-3 lines)    │
│                             │
│  ⏰ Time: 09:00 AM          │
│  ⏱️ Duration: 1 hour        │
│  👥 Capacity: 20/20         │
│                             │
│  [Low] [Wellness] [Outdoor] │
│                             │
│  [View Details Button]      │
└─────────────────────────────┘
```

---

## 🎫 Trips Page - `/trips`

### Layout Structure

```
┌─────────────────────────────────────────────────┐
│  TRIP CARDS GRID                                │
│  ┌──────────────┐ ┌──────────────┐            │
│  │ [Trip Image] │ │ [Trip Image] │            │
│  │              │ │              │            │
│  │ Title        │ │ Title        │            │
│  │ Location     │ │ Location     │            │
│  │ Date Range   │ │ Date Range   │            │
│  │ Price        │ │ Price        │            │
│  │ [Tags]       │ │ [Tags]       │            │
│  │ [Book Now]   │ │ [Book Now]   │            │
│  └──────────────┘ └──────────────┘            │
└─────────────────────────────────────────────────┘
```

---

## 🎨 Design System

### Colors
- **Primary**: Brand color (configurable)
- **Accent**: Secondary brand color
- **Background**: Light/Dark theme support
- **Muted**: For secondary text
- **Card**: Card background
- **Border**: Subtle borders

### Typography
- **Headings**: Bold, large sizes (3xl-6xl)
- **Body**: Regular, readable sizes (base-lg)
- **Muted**: Lighter color for descriptions

### Spacing
- **Container Padding**: Consistent padding
- **Section Padding**: Large vertical spacing
- **Card Padding**: Internal card spacing
- **Gap**: Grid gaps (4, 6, 8 units)

### Components Style

**Buttons:**
- `btn-elderly`: Special styling for elderly-friendly buttons (larger, more contrast)
- Variants: default, outline, ghost, secondary
- Sizes: sm, default, lg

**Cards:**
- Rounded corners (rounded-lg, rounded-xl, rounded-2xl)
- Shadow: shadow-sm, shadow-md, shadow-large
- Border: Subtle border
- Hover effects: Scale, shadow increase

**Forms:**
- Large input fields (elderly-friendly)
- Clear labels
- Error states
- Success states

---

## 📱 Responsive Breakpoints

- **Mobile**: < 768px
  - Single column layout
  - Bottom navigation
  - Hamburger menu
  - Stacked cards

- **Tablet**: 768px - 1024px
  - 2-column grids
  - Side navigation (collapsible)
  - Horizontal navigation

- **Desktop**: > 1024px
  - 3-4 column grids
  - Full sidebar navigation
  - Footer visible
  - Full feature set

---

## 🎯 Key UI Features

### 1. **Elderly-Friendly Design**
- ✅ Large buttons (`btn-elderly` class)
- ✅ High contrast colors
- ✅ Clear typography
- ✅ Simple navigation
- ✅ Large touch targets (click-target class)

### 2. **Accessibility**
- ✅ Semantic HTML
- ✅ ARIA labels
- ✅ Keyboard navigation
- ✅ Screen reader support
- ✅ Focus states

### 3. **Performance**
- ✅ Lazy loading (React.lazy)
- ✅ Code splitting
- ✅ Optimized images
- ✅ Fast page transitions

### 4. **User Experience**
- ✅ Loading states (spinners)
- ✅ Toast notifications (Sonner)
- ✅ Error handling
- ✅ Empty states
- ✅ Smooth animations

---

## 🖼️ Visual Style

### Theme
- **Modern & Clean**: Minimal design
- **Warm Colors**: Elderly-friendly palette
- **Professional**: Business-appropriate
- **Friendly**: Approachable and welcoming

### Icons
- **Lucide React**: Consistent icon set
- **Size**: 16px, 20px, 24px, 32px
- **Color**: Inherit from text color

### Images
- **Placeholder**: `/placeholder.svg` for development
- **Aspect Ratios**: 
  - Hero: Square or 16:9
  - Cards: 16:9
  - Avatars: 1:1

### Animations
- **Hover**: Scale, shadow, color transitions
- **Loading**: Spinner animations
- **Transitions**: Smooth (200-300ms)
- **Page Transitions**: Fade in/out

---

## 🎨 Component Examples

### Activity Card
```
┌─────────────────────────────┐
│  [Image: 16:9 aspect]       │
│  ┌─────────────────────┐   │
│  │ [Intensity Badge]   │   │
│  └─────────────────────┘   │
├─────────────────────────────┤
│  Morning Exercise           │
│  Start your day with...     │
│                             │
│  ⏰ 09:00 AM                │
│  ⏱️ 1 hour                  │
│  👥 20 participants         │
│                             │
│  [Wellness] [Outdoor]       │
│                             │
│  [View Details →]           │
└─────────────────────────────┘
```

### Stats Card
```
┌─────────────────────────────┐
│  Revenue                    │
│  ┌─────────────────────┐   │
│  │ ฿67,000             │   │
│  │ +12.5% vs last month│   │
│  └─────────────────────┘   │
│  [Chart Icon]              │
└─────────────────────────────┘
```

### Navigation Item (Active)
```
┌─────────────────────────────┐
│  🏠 Dashboard               │  ← Active: bg-primary/10
└─────────────────────────────┘
```

---

## 📊 Summary

### Design Strengths
✅ **Modern & Professional**: Clean, contemporary design
✅ **Elderly-Friendly**: Large buttons, high contrast, clear typography
✅ **Responsive**: Works on all devices
✅ **Accessible**: WCAG compliant
✅ **Consistent**: Design system throughout
✅ **User-Friendly**: Intuitive navigation

### Visual Hierarchy
1. **Hero Section**: First impression
2. **Features**: Key benefits
3. **Activities**: Main content
4. **Testimonials**: Social proof
5. **CTA**: Call to action

### Color Psychology
- **Warm Colors**: Comfort, trust
- **Primary Color**: Brand identity
- **Green**: Health, wellness
- **Blue**: Trust, reliability
- **Muted Colors**: Secondary information

---

*เอกสารนี้สรุปภาพ UI/UX ของเว็บไซต์ FunAging Studio ตามโครงสร้างโค้ดที่มีอยู่*

