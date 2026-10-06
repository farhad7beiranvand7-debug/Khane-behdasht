from pathlib import Path
from PIL import Image, ImageDraw

# ============================================================
# Project paths
# ============================================================

root = Path(__file__).resolve().parents[1]

tool_dir = root / "tool"
icon_file = tool_dir / "icon.png"

res_root = (
    root
    / "android"
    / "app"
    / "src"
    / "main"
    / "res"
)

tool_dir.mkdir(parents=True, exist_ok=True)

# ============================================================
# Create our app icon
# ============================================================

SIZE = 1024

# روشن‌تر و هماهنگ با ظاهر جدید برنامه
GREEN = (118, 170, 62, 255)
WHITE = (255, 255, 255, 255)

img = Image.new(
    "RGBA",
    (SIZE, SIZE),
    GREEN,
)

draw = ImageDraw.Draw(img)

# ------------------------------------------------------------
# Simple white house
# بدون کادر و بدون قاب
# ------------------------------------------------------------

# Roof
draw.polygon(
    [
        (185, 465),
        (512, 205),
        (839, 465),
    ],
    fill=WHITE,
)

# House body
draw.rounded_rectangle(
    (285, 420, 739, 790),
    radius=55,
    fill=WHITE,
)

# ------------------------------------------------------------
# Medical cross
# ------------------------------------------------------------

cross_color = GREEN

# Vertical
draw.rounded_rectangle(
    (455, 505, 569, 720),
    radius=18,
    fill=cross_color,
)

# Horizontal
draw.rounded_rectangle(
    (405, 555, 619, 670),
    radius=18,
    fill=cross_color,
)

# ------------------------------------------------------------
# Door
# ------------------------------------------------------------

draw.rounded_rectangle(
    (455, 690, 569, 790),
    radius=18,
    fill=GREEN,
)

# ============================================================
# Save master icon
# ============================================================

img.save(
    icon_file,
    format="PNG",
)

print("========================================")
print("APP ICON CREATED")
print("========================================")
print(icon_file)
print(f"Size: {SIZE}x{SIZE}")

# ============================================================
# Generate Android launcher icons
# ============================================================

if not res_root.exists():
    print("Android res folder does not exist yet.")
    print("Master icon was created successfully.")
    raise SystemExit(0)

densities = {
    "mdpi": 1,
    "hdpi": 1.5,
    "xhdpi": 2,
    "xxhdpi": 3,
    "xxxhdpi": 4,
}

for density, scale in densities.items():

    output_dir = res_root / f"mipmap-{density}"
    output_dir.mkdir(
        parents=True,
        exist_ok=True,
    )

    size = int(48 * scale)

    resized = img.resize(
        (size, size),
        Image.Resampling.LANCZOS,
    )

    resized.save(
        output_dir / "ic_launcher.png",
        format="PNG",
    )

    resized.save(
        output_dir / "ic_launcher_round.png",
        format="PNG",
    )

    print(
        f"Created {density}: "
        f"{size}x{size}"
    )

print("========================================")
print("ANDROID ICONS CREATED SUCCESSFULLY")
print("========================================")
