"""
CookSwipe app icon generator.
Produces a 1024x1024 PNG with:
  - Warm orange-to-red radial gradient background
  - Rounded square shape (for adaptive icon)
  - White fork + heart centrepiece
"""

from PIL import Image, ImageDraw, ImageFilter
import math
import os

SIZE = 1024
OUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'icon')
os.makedirs(OUT_DIR, exist_ok=True)


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def radial_gradient(size, inner, outer):
    img = Image.new('RGB', (size, size))
    cx = cy = size / 2
    max_r = size * 0.72
    pixels = img.load()
    for y in range(size):
        for x in range(size):
            dx, dy = x - cx, y - cy
            t = min(math.sqrt(dx * dx + dy * dy) / max_r, 1.0)
            pixels[x, y] = lerp_color(inner, outer, t)
    return img


def rounded_mask(size, radius):
    mask = Image.new('L', (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return mask


def draw_fork(draw, cx, cy, scale):
    """Draw a simplified white fork."""
    w = int(8 * scale)
    tine_w = int(4 * scale)
    tine_h = int(90 * scale)
    gap = int(18 * scale)
    handle_h = int(180 * scale)
    handle_top = int(-80 * scale)
    curve_h = int(30 * scale)

    # Three tines
    for offset in [-gap, 0, gap]:
        x = cx + offset
        top = cy + handle_top
        draw.rectangle([x - tine_w // 2, top, x + tine_w // 2, top + tine_h], fill='white')
        # Rounded tine tip
        draw.ellipse([x - tine_w // 2, top - tine_w // 2,
                      x + tine_w // 2, top + tine_w // 2], fill='white')

    # Bridge connecting tines to handle
    bridge_y = int(cy + handle_top + tine_h)
    draw.rectangle([cx - gap - tine_w // 2, bridge_y,
                    cx + gap + tine_w // 2, bridge_y + curve_h], fill='white')

    # Handle
    handle_x = cx - w // 2
    handle_y = bridge_y + curve_h
    draw.rounded_rectangle([handle_x, handle_y,
                             handle_x + w, handle_y + handle_h],
                            radius=w // 2, fill='white')


def draw_heart(draw, cx, cy, size):
    """Draw a filled white heart using overlapping circles + triangle."""
    r = size // 2
    # Left circle
    draw.ellipse([cx - size, cy - r, cx, cy + r], fill='white')
    # Right circle
    draw.ellipse([cx, cy - r, cx + size, cy + r], fill='white')
    # Bottom triangle
    draw.polygon([
        (cx - size, cy + r // 2),
        (cx + size, cy + r // 2),
        (cx, cy + size + r // 2),
    ], fill='white')


def main():
    # 1. Radial gradient background: warm amber centre → deep orange edge
    img = radial_gradient(SIZE, (255, 160, 30), (220, 60, 20))

    # 2. Apply rounded-square mask (like Android adaptive icon foreground)
    mask = rounded_mask(SIZE, radius=int(SIZE * 0.22))
    result = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    result.paste(img, mask=mask)

    draw = ImageDraw.Draw(result)

    # 3. Subtle inner glow ring
    glow_r = int(SIZE * 0.40)
    cx = cy = SIZE // 2
    for i in range(6, 0, -1):
        alpha = int(30 * (i / 6))
        overlay = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.ellipse([cx - glow_r - i * 4, cy - glow_r - i * 4,
                    cx + glow_r + i * 4, cy + glow_r + i * 4],
                   fill=(255, 220, 100, alpha))
        result = Image.alpha_composite(result, overlay)
        draw = ImageDraw.Draw(result)

    # 4. Fork — slightly left of centre
    fork_cx = cx - int(SIZE * 0.08)
    fork_cy = cy + int(SIZE * 0.04)
    draw_fork(draw, fork_cx, fork_cy, scale=SIZE / 512)

    # 5. Heart — lower-right of fork, small accent
    heart_cx = cx + int(SIZE * 0.16)
    heart_cy = cy + int(SIZE * 0.20)
    heart_size = int(SIZE * 0.095)
    draw_heart(draw, heart_cx, heart_cy, heart_size)

    # 6. Swipe arrow (➜) right of fork, subtle
    arrow_x = cx + int(SIZE * 0.19)
    arrow_y = cy - int(SIZE * 0.12)
    aw = int(SIZE * 0.09)
    ah = int(SIZE * 0.025)
    # Shaft
    draw.rectangle([arrow_x, arrow_y - ah, arrow_x + aw, arrow_y + ah], fill=(255, 255, 255, 180))
    # Arrowhead
    draw.polygon([
        (arrow_x + aw, arrow_y - ah * 3),
        (arrow_x + aw + int(SIZE * 0.055), arrow_y),
        (arrow_x + aw, arrow_y + ah * 3),
    ], fill=(255, 255, 255, 200))

    # 7. Save full 1024 icon
    out_path = os.path.join(OUT_DIR, 'icon.png')
    result.save(out_path, 'PNG')
    print(f'Saved {out_path}')

    # 8. Also save a foreground-only version (no bg) for adaptive icon
    fg = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(fg)
    draw_fork(fg_draw, fork_cx, fork_cy, scale=SIZE / 512)
    draw_heart(fg_draw, heart_cx, heart_cy, heart_size)
    fg.save(os.path.join(OUT_DIR, 'icon_foreground.png'), 'PNG')
    print('Saved foreground layer.')


if __name__ == '__main__':
    main()
