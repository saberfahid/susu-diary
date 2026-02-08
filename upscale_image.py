from PIL import Image, ImageFilter, ImageEnhance
import os

src_path = "1770576797-removebg-preview.png"
out_path = "1770576797-removebg-preview.png"  # overwrite with better version
icon_path = "assets/icons/app_icon.png"
fg_path = "assets/icons/app_icon_foreground.png"

# Load original
src = Image.open(src_path).convert("RGBA")
print(f"Original: {src.size}")

# ─── 1. Upscale to 2048px on longest side with LANCZOS ───
w, h = src.size
target = 2048
scale = target / max(w, h)
new_w = int(w * scale)
new_h = int(h * scale)
upscaled = src.resize((new_w, new_h), Image.LANCZOS)

# Sharpen to recover detail
upscaled = upscaled.filter(ImageFilter.UnsharpMask(radius=2, percent=150, threshold=3))

# Boost contrast slightly
enhancer = ImageEnhance.Contrast(upscaled)
upscaled = enhancer.enhance(1.1)

# Boost color saturation slightly
enhancer = ImageEnhance.Color(upscaled)
upscaled = enhancer.enhance(1.15)

upscaled.save(out_path, "PNG", optimize=True)
print(f"Upscaled: {upscaled.size} -> {out_path}")

# ─── 2. Generate app_icon.png (1024x1024) ───
from PIL import ImageDraw

size = 1024
icon = Image.new("RGBA", (size, size))
draw = ImageDraw.Draw(icon)

# Pastel gradient: Pink (#FFB3C6) → Purple (#B388EB) → Blue (#8BD3E6)
for y in range(size):
    for x in range(size):
        t = (x + y) / (2 * size)
        if t < 0.5:
            t2 = t * 2
            r = int(255 + (179 - 255) * t2)
            g = int(179 + (136 - 179) * t2)
            b = int(198 + (235 - 198) * t2)
        else:
            t2 = (t - 0.5) * 2
            r = int(179 + (139 - 179) * t2)
            g = int(136 + (211 - 136) * t2)
            b = int(235 + (230 - 235) * t2)
        draw.point((x, y), fill=(r, g, b, 255))

# Rounded mask
mask = Image.new("L", (size, size), 0)
mask_draw = ImageDraw.Draw(mask)
mask_draw.rounded_rectangle([(0, 0), (size - 1, size - 1)], radius=180, fill=255)

# Place upscaled brand image centered at 70%
uw, uh = upscaled.size
max_dim = int(size * 0.68)
s = min(max_dim / uw, max_dim / uh)
rw = int(uw * s)
rh = int(uh * s)
resized = upscaled.resize((rw, rh), Image.LANCZOS)

px = (size - rw) // 2
py = (size - rh) // 2
icon.paste(resized, (px, py), resized)

bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
icon = Image.composite(icon, bg, mask)
icon.save(icon_path, "PNG")
print(f"app_icon.png: {size}x{size}")

# ─── 3. Generate app_icon_foreground.png (1024x1024) ───
fg_size = 1024
foreground = Image.new("RGBA", (fg_size, fg_size), (0, 0, 0, 0))

safe_pct = 0.58
safe_dim = int(fg_size * safe_pct)
fs = min(safe_dim / uw, safe_dim / uh)
fw = int(uw * fs)
fh = int(uh * fs)
fg_resized = upscaled.resize((fw, fh), Image.LANCZOS)

fx = (fg_size - fw) // 2
fy = (fg_size - fh) // 2
foreground.paste(fg_resized, (fx, fy), fg_resized)
foreground.save(fg_path, "PNG")
print(f"app_icon_foreground.png: {fg_size}x{fg_size}")

print("\nDone! Image upscaled and icons regenerated.")
