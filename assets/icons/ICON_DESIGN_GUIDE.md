# Susu App Icon Design Guide 🎨

## App Name
**Susu — Your AI Diary**

---

## Icon Design Specifications

### Main Icon (`app_icon.png`)
**Size:** 1024 x 1024 pixels (for best quality scaling)

### Visual Elements

#### 1. Background - Pastel Spiral Notebook
- **Shape:** Rounded square (iOS style) with soft corners
- **Color Gradient:** Soft pastel gradient flowing diagonally
  - Pink: `#FFB3C6` (top-left)
  - Purple: `#B388EB` (center)  
  - Blue: `#8BD3E6` (bottom-right)
- **Notebook Style:**
  - White stitched border pattern around edges (subtle)
  - Colorful spiral rings on the LEFT side (5-6 rings)
  - Ring colors: Pink, Purple, Blue, alternating
  - Paper lines visible subtly inside

#### 2. Center Element - Friendly AI Brain
- **Position:** Center of the notebook
- **Style:** Simple, cute, friendly brain shape
- **Color:** Light lavender `#D4B8FF` with white highlights
- **Circuit Lines:** Minimal, cute circuit line patterns
  - Thin, rounded lines connecting parts
  - Small dots at connection points
  - Color: Light purple `#9B7DCA`

#### 3. "AI" Letters
- **Position:** Inside/on the brain icon
- **Font:** Rounded, bubbly, friendly font
- **Color:** Soft warm yellow `#FFEB8A` with subtle glow
- **Effect:** Very subtle golden glow/shadow around letters

#### 4. Cute Decorative Elements (scattered around)
- **Smiling Stars:** 2-3 small yellow stars with happy faces ⭐
  - Color: `#FFEB8A` with pink cheeks
- **Tiny Sparkles:** 4-5 small white/light blue sparkles ✨
  - Various sizes, scattered around
- **Small Hearts:** 2-3 tiny hearts 💕
  - Colors: Pink `#FFB3C6`, Purple `#B388EB`

#### 5. Heart-Shaped Lock (Privacy Symbol)
- **Position:** Right side or bottom-right corner
- **Size:** Small, not dominant
- **Color:** Rose pink `#FF8FAB` with white keyhole
- **Style:** Cute rounded heart shape with a lock mechanism look

---

## What to AVOID ❌
- ~~Fingerprint symbols~~ (REMOVE completely)
- Complex detailed designs
- Dark or harsh colors
- Realistic styles
- Sharp edges

---

## Style Guidelines

### Overall Aesthetic
- **Style:** Flat 3D vector, kawaii aesthetic
- **Lighting:** Soft, warm lighting
- **Shadows:** Smooth, subtle drop shadows
- **Mood:** Warm, friendly, safe, cute

### Color Palette
| Element | Color Code | Description |
|---------|------------|-------------|
| Primary Pink | `#FFB3C6` | Soft coral pink |
| Primary Purple | `#B388EB` | Lavender |
| Primary Blue | `#8BD3E6` | Sky blue |
| AI Yellow | `#FFEB8A` | Warm yellow glow |
| Brain Purple | `#D4B8FF` | Light purple |
| Lock Pink | `#FF8FAB` | Rose pink |
| Background | `#F8E8FF` | Soft lavender white |

---

## Required Files

After creating the icon, save these files in `assets/icons/`:

1. **`app_icon.png`** - 1024x1024 main icon (full design)
2. **`app_icon_foreground.png`** - 1024x1024 with transparent background (for Android adaptive icons)

---

## How to Generate App Icons

Once you have `app_icon.png` in the `assets/icons/` folder:

```bash
# Install dependencies
flutter pub get

# Generate all platform icons
dart run flutter_launcher_icons
```

This will automatically generate:
- Android: mipmap icons (all sizes)
- iOS: AppIcon.appiconset (all sizes)
- Web: favicon and PWA icons
- Windows: app icon
- macOS: app icon

---

## AI Image Generation Prompt

Use this prompt with AI image generators (Midjourney, DALL-E, Leonardo.ai):

```
A very cute and attractive mobile app icon for an AI diary app called "Susu". 
A pastel-colored spiral notebook with rounded corners, soft gradients (pink #FFB3C6, purple #B388EB, blue #8BD3E6), and white stitched borders.
In the center, a friendly AI brain icon with simple circuit lines and the letters "AI" in a soft yellow color #FFEB8A, glowing slightly.
NO fingerprint symbols.
Add small cute elements like smiling stars, tiny sparkles, and hearts for a warm, emotional feeling.
The notebook has colorful spiral rings on the left and a heart-shaped lock icon on the side to represent privacy.
Flat 3D vector style, soft lighting, smooth shadows, kawaii aesthetic, modern UI, app-store ready, high resolution, clean background, centered composition.
```

---

## Preview Mockup Layout

```
┌────────────────────────────────┐
│  ○○○○○  ┌──────────────────┐   │
│  spiral │                  │   │
│  rings  │    ⭐  ✨        │   │
│  ○○○○○  │                  │ 💕│
│         │   🧠 AI         │   │
│         │   (brain)       │ 🔒│
│         │                  │   │
│         │  ✨    💝        │   │
│         └──────────────────┘   │
│  ─────  ─────  ─────  ─────    │
│  (paper lines)                 │
└────────────────────────────────┘
```

---

## Notes

- The icon should look great at all sizes (1024px down to 16px)
- Keep the design simple enough to be recognizable at small sizes
- The "AI" text should be readable even at smaller sizes
- Test the icon on both light and dark backgrounds
