#!/usr/bin/env python3
"""Generate a simple icon for qnap8528 driver."""
from PIL import Image, ImageDraw, ImageFont
import os

size = 256
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Background circle
draw.ellipse([10, 10, size-10, size-10], fill=(0, 120, 212, 255))

# Chip icon
draw.rectangle([80, 90, 176, 166], fill=(255, 255, 255, 255), outline=(200, 200, 200, 255), width=2)

# Pins
for i in range(6):
    y = 100 + i * 12
    draw.rectangle([70, y, 80, y+6], fill=(255, 255, 255, 255))
    draw.rectangle([176, y, 186, y+6], fill=(255, 255, 255, 255))

# Text
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 28)
except:
    font = ImageFont.load_default()

draw.text((size//2, 200), "8528", fill=(255, 255, 255, 255), font=font, anchor="mm")

ui_dir = os.path.join(os.path.dirname(__file__), "fnos", "ui")
os.makedirs(ui_dir, exist_ok=True)
images_dir = os.path.join(ui_dir, "images")
os.makedirs(images_dir, exist_ok=True)
with open(os.path.join(ui_dir, "config"), "w", encoding="ascii") as config_file:
    config_file.write("{}\n")
resampling = getattr(Image, "Resampling", Image)
icon_64 = img.resize((64, 64), resampling.LANCZOS)
icon_64.save(os.path.join(os.path.dirname(__file__), "fnos", "ICON.PNG"))
icon_64.save(os.path.join(images_dir, "64.png"))
img.save(os.path.join(os.path.dirname(__file__), "fnos", "ICON_256.PNG"))
img.save(os.path.join(images_dir, "256.png"))
print(f"Icons saved to {ui_dir}")
