#!/usr/bin/env python3
"""Generate assets/icon.png without external dependencies.

Creates a 1024x1024 PNG with an off-white subtle textured background and
minimal black dot + short line symbol for the fday brand icon.
"""

from __future__ import annotations

import random
import struct
import zlib
from pathlib import Path

SIZE = 1024
OUTPUT = Path(__file__).resolve().parent.parent / "assets" / "icon.png"


def _pixel_rgba(x: int, y: int) -> tuple[int, int, int, int]:
    base = (247, 246, 243)
    grain = random.randint(-3, 3)
    r = max(0, min(255, base[0] + grain))
    g = max(0, min(255, base[1] + grain))
    b = max(0, min(255, base[2] + grain))

    dx, dy = x - 300, y - 430
    in_dot = (dx * dx) + (dy * dy) <= 70 * 70

    yline = 410
    in_rect = 430 <= x <= 760 and abs(y - yline) <= 24
    in_cap1 = (x - 430) ** 2 + (y - yline) ** 2 <= 24 * 24
    in_cap2 = (x - 760) ** 2 + (y - yline) ** 2 <= 24 * 24

    if in_dot or in_rect or in_cap1 or in_cap2:
        return 0, 0, 0, 255

    return r, g, b, 255


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
        row = bytearray([0])  # filter byte per scanline
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
