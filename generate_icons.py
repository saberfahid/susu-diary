from PIL import Image, ImageDraw, ImageFilter
import math

# Load source image (transparent background)
src = Image.open("1770576797-removebg-preview.png").convert("RGBA")

# ─── 1. app_icon.png (1024x1024) ───
# Pastel gradient background matching the app brand
size = 1024
icon = Image.new("RGBA", (size, size))
draw = ImageDraw.Draw(icon)

# Create a smooth diagonal gradient: Pink → Purple → Blue
for y in range(size):
    for x in range(size):
        # Diagonal progress (0..1)
        t = (x + y) / (2 * size)
        if t < 0.5:
            # Pink to Purple
            t2 = t * 2
            r = int(255 + (179 - 255) * t2)  # FFB3C6 -> B388EB
            g = int(179 + (136 - 179) * t2)
            b = int(198 + (235 - 198) * t2)
        else:
            # Purple to Blue
            t2 = (t - 0.5) * 2
            r = int(179 + (139 - 179) * t2)  # B388EB -> 8BD3E6
            g = int(136 + (211 - 136) * t2)
            b = int(235 + (230 - 235) * t2)
        draw.point((x, y), fill=(r, g, b, 255))

# Add subtle rounded-rect clip (for a polished look on web/windows)
mask = Image.new("L", (size, size), 0)
mask_draw = ImageDraw.Draw(mask)
radius = 180
mask_draw.rounded_rectangle([(0, 0), (size - 1, size - 1)], radius=radius, fill=255)

# Place source image centered, scaled to ~70% of icon with padding
src_w, src_h = src.size
# Scale to fit in 70% of 1024
max_dim = int(size * 0.68)
scale = min(max_dim / src_w, max_dim / src_h)
new_w = int(src_w * scale)
new_h = int(src_h * scale)
resized = src.resize((new_w, new_h), Image.LANCZOS)

# Center on icon
paste_x = (size - new_w) // 2
paste_y = (size - new_h) // 2
icon.paste(resized, (paste_x, paste_y), resized)

# Apply rounded mask
bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
icon = Image.composite(icon, bg, mask)

icon.save("assets/icons/app_icon.png", "PNG")
print(f"✓ app_icon.png saved ({size}x{size})")


# ─── 2. app_icon_foreground.png (1024x1024, transparent) ───
# Android adaptive icons use a 108dp grid with 72dp safe zone (66.7%)
# The foreground must be 1024x1024 with the content in the center ~66%
fg_size = 1024
foreground = Image.new("RGBA", (fg_size, fg_size), (0, 0, 0, 0))

# Scale source to fit in the safe zone (~62% for extra safety)
safe_pct = 0.58
safe_dim = int(fg_size * safe_pct)
fg_scale = min(safe_dim / src_w, safe_dim / src_h)
fg_w = int(src_w * fg_scale)
fg_h = int(src_h * fg_scale)
fg_resized = src.resize((fg_w, fg_h), Image.LANCZOS)

fg_x = (fg_size - fg_w) // 2
fg_y = (fg_size - fg_h) // 2
foreground.paste(fg_resized, (fg_x, fg_y), fg_resized)

foreground.save("assets/icons/app_icon_foreground.png", "PNG")
print(f"✓ app_icon_foreground.png saved ({fg_size}x{fg_size})")

print("\nDone! Both icons are ready.")
