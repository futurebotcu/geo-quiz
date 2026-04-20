"""
Play Store Asset Generator for Geo Quiz
Generates all required graphic assets using Pillow.
"""
import math
import os
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BRAND = os.path.join(BASE, "assets", "brand")
OUT = os.path.join(BASE, "store_assets", "play_store")
ANDROID_RES = os.path.join(BASE, "android", "app", "src", "main", "res")

os.makedirs(OUT, exist_ok=True)

# ── Color palette ──────────────────────────────────────────────
BG_DARK   = (30, 41, 59)       # Slate-800
BG_MID    = (51, 65, 85)       # Slate-700
ACCENT    = (79, 70, 229)      # Indigo-600 (matches app theme)
ACCENT_LT = (99, 102, 241)     # Indigo-500
GREEN     = (16, 185, 129)     # Emerald-500
TEAL      = (20, 184, 166)     # Teal-500
WHITE     = (255, 255, 255)
OFF_WHITE = (241, 245, 249)    # Slate-100
GOLD      = (250, 204, 21)     # Yellow-400
ICON_BG   = (79, 70, 229)      # Indigo-600

# ── Font helper ────────────────────────────────────────────────
def get_font(size, bold=False):
    """Try to load a clean sans-serif font, fallback to default."""
    candidates = [
        "C:/Windows/Fonts/segoeui.ttf" if not bold else "C:/Windows/Fonts/segoeuib.ttf",
        "C:/Windows/Fonts/calibri.ttf" if not bold else "C:/Windows/Fonts/calibrib.ttf",
        "arial.ttf" if not bold else "arialbd.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except (OSError, IOError):
            continue
    return ImageFont.load_default()


# ── Drawing helpers ────────────────────────────────────────────
def draw_circle(draw, cx, cy, r, fill):
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=fill)

def draw_globe(draw, cx, cy, radius, line_color, line_width=2):
    """Draw a simplified globe wireframe."""
    # Outer circle
    draw.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        outline=line_color, width=line_width
    )
    # Horizontal lines (latitudes)
    for frac in [0.33, 0.66]:
        y = cy - radius + int(2 * radius * frac)
        # Calculate width at this latitude
        dy = abs(y - cy)
        if dy < radius:
            half_w = int(math.sqrt(radius * radius - dy * dy))
            draw.arc(
                [cx - half_w, y - int(half_w * 0.3), cx + half_w, y + int(half_w * 0.3)],
                0, 360, fill=line_color, width=max(1, line_width - 1)
            )
    # Equator
    draw.arc(
        [cx - radius, cy - int(radius * 0.15), cx + radius, cy + int(radius * 0.15)],
        0, 360, fill=line_color, width=line_width
    )
    # Vertical meridians
    for frac in [0.35, 0.65]:
        x_off = int(radius * (frac - 0.5) * 2)
        half_h = int(math.sqrt(max(0, radius * radius - x_off * x_off)))
        w = int(abs(x_off) * 0.4) + 4
        draw.arc(
            [cx + x_off - w, cy - half_h, cx + x_off + w, cy + half_h],
            0, 360, fill=line_color, width=max(1, line_width - 1)
        )
    # Center meridian
    draw.arc(
        [cx - int(radius * 0.08), cy - radius, cx + int(radius * 0.08), cy + radius],
        0, 360, fill=line_color, width=line_width
    )

def draw_question_mark(draw, cx, cy, size, color):
    """Draw a stylized question mark."""
    font = get_font(size, bold=True)
    bbox = font.getbbox("?")
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    draw.text((cx - tw // 2, cy - th // 2 - bbox[1]), "?", fill=color, font=font)

def draw_flag_mini(draw, x, y, w, h):
    """Draw a tiny abstract flag (3 horizontal stripes)."""
    stripe_h = h // 3
    colors = [(220, 38, 38), WHITE, (37, 99, 235)]  # Red, White, Blue
    for i, c in enumerate(colors):
        draw.rectangle([x, y + i * stripe_h, x + w, y + (i + 1) * stripe_h], fill=c)
    draw.rectangle([x, y, x + w, y + h], outline=(100, 100, 100), width=1)

def draw_gradient_rect(img, x1, y1, x2, y2, color_top, color_bottom):
    """Draw a vertical gradient rectangle."""
    draw = ImageDraw.Draw(img)
    h = y2 - y1
    for i in range(h):
        ratio = i / max(h - 1, 1)
        r = int(color_top[0] + (color_bottom[0] - color_top[0]) * ratio)
        g = int(color_top[1] + (color_bottom[1] - color_top[1]) * ratio)
        b = int(color_top[2] + (color_bottom[2] - color_top[2]) * ratio)
        draw.line([(x1, y1 + i), (x2, y1 + i)], fill=(r, g, b))


# ══════════════════════════════════════════════════════════════
# 1) APP ICON — 512x512 Play Store version
# ══════════════════════════════════════════════════════════════
def generate_app_icon():
    size = 512
    img = Image.new("RGB", (size, size), ICON_BG)
    draw = ImageDraw.Draw(img)

    # Subtle diagonal gradient overlay
    for y in range(size):
        for x in range(size):
            # Lighten top-left, darken bottom-right
            factor = (x + y) / (2 * size)
            r, g, b = img.getpixel((x, y))
            r = max(0, min(255, int(r + (1 - factor) * 25 - factor * 15)))
            g = max(0, min(255, int(g + (1 - factor) * 20 - factor * 10)))
            b = max(0, min(255, int(b + (1 - factor) * 15 - factor * 5)))
            img.putpixel((x, y), (r, g, b))

    draw = ImageDraw.Draw(img)

    # Globe in upper area
    globe_cx, globe_cy = size // 2, size // 2 - 30
    globe_r = 130
    # Globe fill (slightly lighter)
    draw_circle(draw, globe_cx, globe_cy, globe_r, (67, 56, 202))
    draw_globe(draw, globe_cx, globe_cy, globe_r, (180, 180, 255), line_width=3)

    # Question mark overlay on globe
    draw_question_mark(draw, globe_cx, globe_cy, 140, GOLD)

    # "GQ" text at bottom
    font_gq = get_font(72, bold=True)
    bbox = font_gq.getbbox("GQ")
    tw = bbox[2] - bbox[0]
    draw.text((size // 2 - tw // 2, size - 120), "GQ", fill=WHITE, font=font_gq)

    # Small decorative dots (representing locations on a map)
    dots = [(120, 140), (380, 160), (150, 300), (360, 320), (100, 220), (400, 240)]
    for dx, dy in dots:
        draw_circle(draw, dx, dy, 4, GOLD)

    path = os.path.join(OUT, "icon_512.png")
    img.save(path, "PNG")
    print(f"[OK] {path} — {img.size} RGB, no transparency")
    return img


# ══════════════════════════════════════════════════════════════
# 2) FEATURE GRAPHIC — 1024x500
# ══════════════════════════════════════════════════════════════
def generate_feature_graphic():
    w, h = 1024, 500
    img = Image.new("RGB", (w, h))

    # Gradient background: dark indigo → teal
    draw_gradient_rect(img, 0, 0, w, h, (30, 27, 75), (13, 71, 75))
    draw = ImageDraw.Draw(img)

    # Subtle grid pattern (world map feel)
    grid_color = (255, 255, 255, 15)
    for gx in range(0, w, 60):
        draw.line([(gx, 0), (gx, h)], fill=(40, 45, 90), width=1)
    for gy in range(0, h, 60):
        draw.line([(0, gy), (w, gy)], fill=(40, 45, 90), width=1)

    # Globe (left-center area)
    globe_cx, globe_cy = 220, 250
    globe_r = 150
    # Globe background circle
    draw_circle(draw, globe_cx, globe_cy, globe_r + 5, (45, 40, 110))
    draw_circle(draw, globe_cx, globe_cy, globe_r, (55, 50, 130))
    draw_globe(draw, globe_cx, globe_cy, globe_r, (120, 130, 220), line_width=2)

    # Decorative elements around globe
    # Small flag
    draw_flag_mini(draw, 100, 80, 30, 20)
    draw_flag_mini(draw, 330, 120, 25, 17)

    # Location pins
    pin_positions = [(160, 170), (260, 200), (200, 310), (300, 350)]
    for px, py in pin_positions:
        draw_circle(draw, px, py, 5, GOLD)
        draw_circle(draw, px, py, 2, WHITE)

    # Title: "Geo Quiz"
    title_font = get_font(96, bold=True)
    title_x = 430
    draw.text((title_x, 120), "Geo Quiz", fill=WHITE, font=title_font)

    # Subtitle
    sub_font = get_font(32, bold=False)
    draw.text((title_x, 240), "Capitals  •  Flags  •  World Food", fill=OFF_WHITE, font=sub_font)

    # Decorative line under subtitle
    draw.rectangle([title_x, 290, title_x + 400, 293], fill=GOLD)

    # Bottom tagline
    tag_font = get_font(22, bold=False)
    draw.text((title_x, 320), "Test your world knowledge", fill=(180, 190, 210), font=tag_font)

    # Accent dots on right side
    for i in range(5):
        y = 100 + i * 80
        draw_circle(draw, 970, y, 3 + i, (ACCENT_LT[0], ACCENT_LT[1], ACCENT_LT[2]))

    # Question mark accent (top right)
    draw_question_mark(draw, 940, 400, 60, (60, 60, 120))

    path = os.path.join(OUT, "feature_graphic_1024x500.png")
    img.save(path, "PNG")
    print(f"[OK] {path} — {img.size} RGB")
    return img


# ══════════════════════════════════════════════════════════════
# 3) ADAPTIVE ICON — foreground 432x432 + background 432x432
# ══════════════════════════════════════════════════════════════
def generate_adaptive_icons():
    size = 432
    safe_zone = int(size * 66 / 108)  # ~264px inner safe zone
    padding = (size - safe_zone) // 2  # ~84px each side

    # ── Foreground ──
    fg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(fg)

    cx, cy = size // 2, size // 2

    # Globe
    globe_r = 95
    draw_circle(draw, cx, cy - 15, globe_r, (67, 56, 202, 255))
    # Globe wireframe
    r = globe_r
    ccx, ccy = cx, cy - 15
    # Outer circle
    draw.ellipse([ccx - r, ccy - r, ccx + r, ccy + r], outline=(180, 180, 255, 200), width=3)
    # Equator
    draw.arc([ccx - r, ccy - int(r * 0.12), ccx + r, ccy + int(r * 0.12)], 0, 360, fill=(180, 180, 255, 200), width=2)
    # Meridian
    draw.arc([ccx - int(r * 0.06), ccy - r, ccx + int(r * 0.06), ccy + r], 0, 360, fill=(180, 180, 255, 200), width=2)

    # Question mark
    qfont = get_font(100, bold=True)
    bbox = qfont.getbbox("?")
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    draw.text((cx - tw // 2, cy - 15 - th // 2 - bbox[1]), "?", fill=GOLD + (255,), font=qfont)

    # "GQ" at bottom of safe zone
    gq_font = get_font(44, bold=True)
    bbox2 = gq_font.getbbox("GQ")
    tw2 = bbox2[2] - bbox2[0]
    draw.text((cx - tw2 // 2, cy + 85), "GQ", fill=WHITE + (255,), font=gq_font)

    fg_path = os.path.join(OUT, "ic_launcher_foreground.png")
    fg.save(fg_path, "PNG")
    print(f"[OK] {fg_path} — {fg.size} RGBA (transparent background)")

    # ── Background ── solid color
    bg = Image.new("RGB", (size, size), ICON_BG)
    bg_path = os.path.join(OUT, "ic_launcher_background.png")
    bg.save(bg_path, "PNG")
    print(f"[OK] {bg_path} — {bg.size} RGB solid ({ICON_BG})")

    # ── Also generate density-specific PNGs for mipmap ──
    densities = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    # Composite preview (for non-adaptive launchers)
    composite = Image.new("RGB", (size, size), ICON_BG)
    composite.paste(fg, (0, 0), fg)

    for density, px in densities.items():
        d_dir = os.path.join(ANDROID_RES, density)
        os.makedirs(d_dir, exist_ok=True)
        resized = composite.resize((px, px), Image.LANCZOS)
        p = os.path.join(d_dir, "ic_launcher.png")
        resized.save(p, "PNG")
        print(f"[OK] {p} — {resized.size}")

    return fg, bg


# ══════════════════════════════════════════════════════════════
# 4) FEATURE GRAPHIC MINIMAL — 1024x500 (no subtitle)
# ══════════════════════════════════════════════════════════════
def generate_feature_graphic_minimal():
    w, h = 1024, 500
    img = Image.new("RGB", (w, h))

    # Gradient: deep indigo → indigo
    draw_gradient_rect(img, 0, 0, w, h, (30, 27, 75), (49, 46, 129))
    draw = ImageDraw.Draw(img)

    # Subtle radial glow in center
    for r in range(200, 0, -1):
        alpha = int(15 * (1 - r / 200))
        c = (ACCENT[0] + alpha, ACCENT[1] + alpha, ACCENT[2] + alpha)
        draw_circle(draw, w // 2, h // 2, r, c)

    # Large centered globe
    globe_cx, globe_cy = w // 2, h // 2
    globe_r = 160
    draw_circle(draw, globe_cx, globe_cy, globe_r, (55, 50, 140))
    draw_globe(draw, globe_cx, globe_cy, globe_r, (130, 140, 230), line_width=3)

    # Large question mark on globe
    draw_question_mark(draw, globe_cx, globe_cy, 180, GOLD)

    # "Geo Quiz" below globe (or overlapping bottom)
    title_font = get_font(72, bold=True)
    bbox = title_font.getbbox("Geo Quiz")
    tw = bbox[2] - bbox[0]
    draw.text((w // 2 - tw // 2, h - 100), "Geo Quiz", fill=WHITE, font=title_font)

    # Decorative location dots
    import random
    random.seed(42)  # Deterministic
    for _ in range(20):
        dx = random.randint(50, w - 50)
        dy = random.randint(30, h - 30)
        dist = math.sqrt((dx - globe_cx) ** 2 + (dy - globe_cy) ** 2)
        if dist > globe_r + 30:
            draw_circle(draw, dx, dy, 3, (100, 110, 180))

    path = os.path.join(OUT, "feature_graphic_minimal.png")
    img.save(path, "PNG")
    print(f"[OK] {path} — {img.size} RGB")
    return img


# ══════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════
if __name__ == "__main__":
    print("=" * 60)
    print("Geo Quiz — Play Store Asset Generator")
    print("=" * 60)
    print()

    print("1) App Icon (512x512)...")
    generate_app_icon()
    print()

    print("2) Feature Graphic (1024x500)...")
    generate_feature_graphic()
    print()

    print("3) Adaptive Icon (432x432 fg/bg + density PNGs)...")
    generate_adaptive_icons()
    print()

    print("4) Feature Graphic Minimal (1024x500)...")
    generate_feature_graphic_minimal()
    print()

    print("=" * 60)
    print("ALL ASSETS GENERATED SUCCESSFULLY")
    print("=" * 60)
