"""Generate a square white-background app icon from the SAHAMITHRA artwork.

The source asset is a JPEG with a solid black background and the SAHAMITHRA
logo + Malayalam title rendered on top. App icons must be square; this script
recomposes the artwork on a 1024x1024 white canvas and replaces near-black
pixels in the original artwork with white so the icon reads cleanly on light
home-screen backgrounds.

Usage:
    python3 tools/build_app_icon.py
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "icon" / "app_icon.png"
OUT = ROOT / "assets" / "icon" / "app_icon.png"
ICON_SIZE = 1024
PADDING = 64  # logo safe-area padding inside the canvas
BLACK_THRESHOLD = 40  # treat pixels darker than this as background


def remove_black_background(img: Image.Image) -> Image.Image:
    """Return an RGBA copy where near-black pixels become fully transparent."""
    rgba = img.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    threshold_sq = BLACK_THRESHOLD * BLACK_THRESHOLD
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            # Cheap perceptual-ish darkness check.
            if (r * r + g * g + b * b) <= threshold_sq * 3:
                pixels[x, y] = (255, 255, 255, 0)
    return rgba


def main() -> None:
    if not SRC.exists():
        raise FileNotFoundError(f"Source icon missing: {SRC}")

    src_img = Image.open(SRC)
    transparent = remove_black_background(src_img)

    # Trim transparent borders so the artwork tightly fills the safe area.
    bbox = transparent.getbbox()
    if bbox:
        transparent = transparent.crop(bbox)

    # Fit into the safe area while preserving aspect ratio.
    safe_size = ICON_SIZE - PADDING * 2
    artwork = ImageOps.contain(transparent, (safe_size, safe_size), Image.LANCZOS)

    canvas = Image.new("RGB", (ICON_SIZE, ICON_SIZE), (255, 255, 255))
    offset = (
        (ICON_SIZE - artwork.width) // 2,
        (ICON_SIZE - artwork.height) // 2,
    )
    canvas.paste(artwork, offset, artwork)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUT, format="PNG", optimize=True)
    print(f"Wrote {OUT} ({ICON_SIZE}x{ICON_SIZE}, white background)")


if __name__ == "__main__":
    main()
