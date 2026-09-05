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

output = os.path.join(os.path.dirname(__file__), "fnos", "ui", "icon.png")
os.makedirs(os.path.dirname(output), exist_ok=True)
img.save(output)
print(f"Icon saved to {output}")
