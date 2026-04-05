#!/usr/bin/env python3
"""Generate assets/icon.png without external dependencies.

Creates a 1024x1024 PNG inspired by the provided brand mark:
- Black outer ring
- Warm off-white inner circle with subtle texture
- Top symbol: dot + short horizontal line
- Bottom wordmark: simplified "fday"
"""

from __future__ import annotations

import math
import random
import struct
import zlib
from pathlib import Path

SIZE = 1024
OUTPUT = Path(__file__).resolve().parent.parent / "assets" / "icon.png"

BLACK = (14, 14, 14, 255)
BG = (229, 219, 202, 255)


def _dist(x: int, y: int, cx: int, cy: int) -> float:
    return math.hypot(x - cx, y - cy)


def _capsule(x: int, y: int, x1: int, x2: int, yc: int, r: int) -> bool:
    in_rect = x1 <= x <= x2 and abs(y - yc) <= r
    in_cap1 = (x - x1) ** 2 + (y - yc) ** 2 <= r * r
    in_cap2 = (x - x2) ** 2 + (y - yc) ** 2 <= r * r
    return in_rect or in_cap1 or in_cap2


def _circle(x: int, y: int, cx: int, cy: int, r: int) -> bool:
    return (x - cx) ** 2 + (y - cy) ** 2 <= r * r


def _ring_pixel(x: int, y: int) -> tuple[int, int, int, int]:
    cx, cy = SIZE // 2, SIZE // 2
    d = _dist(x, y, cx, cy)

    # Outer black ring.
    if 450 <= d <= 505:
        return BLACK

    # Inner disc background + subtle grain.
    if d < 450:
        grain = random.randint(-7, 7)
        r = max(0, min(255, BG[0] + grain))
        g = max(0, min(255, BG[1] + grain))
        b = max(0, min(255, BG[2] + grain))
        return (r, g, b, 255)

    # Outside icon area transparent.
    return (0, 0, 0, 0)


def _draw_symbol(x: int, y: int) -> bool:
    # dot + short line (upper half)
    if _circle(x, y, 315, 430, 38):
        return True
    if _capsule(x, y, 470, 740, 430, 16):
        return True
    return False


def _draw_wordmark(x: int, y: int) -> bool:
    # Simplified handmade-like "fday" using circles/capsules.
    # f
    if _capsule(x, y, 300, 300, 635, 14):
        return True
    if _capsule(x, y, 280, 332, 610, 12):
        return True
    if _capsule(x, y, 290, 332, 662, 10):
        return True

    # d
    if _circle(x, y, 410, 665, 43) and not _circle(x, y, 410, 665, 24):
        return True
    if _capsule(x, y, 447, 447, 635, 11):
        return True

    # a
    if _circle(x, y, 530, 668, 43) and not _circle(x, y, 530, 668, 24):
        return True
    if _capsule(x, y, 568, 568, 666, 10):
        return True

    # y
    if _capsule(x, y, 620, 650, 655, 10):
        return True
    if _capsule(x, y, 660, 685, 660, 10):
        return True
    if _capsule(x, y, 652, 652, 700, 10):
        return True

    return False


def _pixel_rgba(x: int, y: int) -> tuple[int, int, int, int]:
    base = _ring_pixel(x, y)

    # Paint symbol/wordmark in black over inner disc only.
    if base[3] != 0 and (_draw_symbol(x, y) or _draw_wordmark(x, y)):
        return BLACK

    return base


def _png_chunk(chunk_type: bytes, data: bytes) -> bytes:
    return (
        struct.pack("!I", len(data))
        + chunk_type
        + data
        + struct.pack("!I", zlib.crc32(chunk_type + data) & 0xFFFFFFFF)
    )


def generate() -> None:
    rows: list[bytes] = []
    for y in range(SIZE):
        row = bytearray([0])
        for x in range(SIZE):
            row.extend(_pixel_rgba(x, y))
        rows.append(bytes(row))

    image_data = b"".join(rows)

    png = b"\x89PNG\r\n\x1a\n"
    png += _png_chunk(b"IHDR", struct.pack("!IIBBBBB", SIZE, SIZE, 8, 6, 0, 0, 0))
    png += _png_chunk(b"IDAT", zlib.compress(image_data, 9))
    png += _png_chunk(b"IEND", b"")

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_bytes(png)
    print(f"Generated {OUTPUT} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    generate()
