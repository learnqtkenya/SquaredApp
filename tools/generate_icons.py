#!/usr/bin/env python3
"""Generate 128x128 app icon PNGs for all example apps.

Each icon renders a Material Symbols glyph (white) centered on a colored
rounded-rect background matching the app's brand color.

Usage: python3 tools/generate_icons.py
"""

import os
from PIL import Image, ImageDraw, ImageFont

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONT_PATH = os.path.join(
    REPO_ROOT, "src", "sdk", "ui", "fonts", "MaterialSymbolsOutlined-Variable.ttf"
)

SIZE = 128
RADIUS = 24
GLYPH_SIZE = 56

# (dir_name, unicode_codepoint, hex_color) from main.cpp seed data
APPS = [
    ("hello-world",     0xE9B2, "#2196F3"),
    ("counter",         0xE145, "#9C27B0"),
    ("todo",            0xE614, "#FF9800"),
    ("finance",         0xE850, "#22C55E"),
    ("weather",         0xE430, "#42A5F5"),
    ("unit-converter",  0xE8D4, "#FF9800"),
    ("habit-tracker",   0xE6B1, "#9C27B0"),
    ("color-picker",    0xE40A, "#E91E63"),
    ("markdown-notes",  0xE873, "#2196F3"),
    ("qml-playground",  0xE86F, "#00BCD4"),
    ("pomodoro-timer",  0xE425, "#4CAF50"),
    ("iot-dashboard",   0xE871, "#607D8B"),
]


def generate_icon(dir_name: str, codepoint: int, color: str) -> None:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Rounded rectangle background
    draw.rounded_rectangle(
        [(0, 0), (SIZE - 1, SIZE - 1)],
        radius=RADIUS,
        fill=color,
    )

    # Load Material Symbols font
    font = ImageFont.truetype(FONT_PATH, GLYPH_SIZE)

    # Render glyph centered
    glyph = chr(codepoint)
    bbox = draw.textbbox((0, 0), glyph, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    x = (SIZE - text_w) / 2 - bbox[0]
    y = (SIZE - text_h) / 2 - bbox[1]
    draw.text((x, y), glyph, font=font, fill="white")

    # Save
    out_path = os.path.join(
        REPO_ROOT, "examples", "apps", dir_name, "assets", "icon.png"
    )
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    img.save(out_path, "PNG")
    print(f"  {dir_name}: {out_path}")


def main() -> None:
    print(f"Font: {FONT_PATH}")
    print(f"Generating {len(APPS)} icons ({SIZE}x{SIZE})...")
    for dir_name, codepoint, color in APPS:
        generate_icon(dir_name, codepoint, color)
    print("Done.")


if __name__ == "__main__":
    main()
