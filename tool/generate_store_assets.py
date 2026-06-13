"""
CookSwipe Play Store asset generator.
Produces:
  1. store_icon.png        — 512x512  (Play Store icon)
  2. feature_graphic.png   — 1024x500 (Play Store feature banner)
"""

from PIL import Image, ImageDraw, ImageFont
import math, os

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'store')
os.makedirs(OUT, exist_ok=True)


def lerp(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def radial_gradient(w, h, inner, outer):
    img = Image.new('RGB', (w, h))
    cx, cy = w / 2, h / 2
    max_r = math.sqrt(cx**2 + cy**2)
    px = img.load()
    for y in range(h):
        for x in range(w):
            t = min(math.sqrt((x-cx)**2 + (y-cy)**2) / max_r, 1.0)
            px[x, y] = lerp(inner, outer, t)
    return img


def rounded_mask(w, h, r):
    m = Image.new('L', (w, h), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, w-1, h-1], radius=r, fill=255)
    return m


def draw_fork(draw, cx, cy, scale, color='white'):
    tw = int(5 * scale)
    th = int(80 * scale)
    gap = int(14 * scale)
    bh = int(22 * scale)
    hh = int(150 * scale)
    top = cy - int(70 * scale)

    for off in [-gap, 0, gap]:
        x = cx + off
        draw.rectangle([x - tw//2, top, x + tw//2, top + th], fill=color)
        draw.ellipse([x - tw//2, top - tw//2, x + tw//2, top + tw//2], fill=color)

    bridge_y = top + th
    draw.rectangle([cx - gap - tw//2, bridge_y,
                    cx + gap + tw//2, bridge_y + bh], fill=color)

    hw = int(8 * scale)
    hx = cx - hw // 2
    hy = bridge_y + bh
    draw.rounded_rectangle([hx, hy, hx + hw, hy + hh], radius=hw//2, fill=color)


def draw_heart(draw, cx, cy, size, color='white'):
    r = size // 2
    draw.ellipse([cx - size, cy - r, cx, cy + r], fill=color)
    draw.ellipse([cx, cy - r, cx + size, cy + r], fill=color)
    draw.polygon([
        (cx - size, cy + r // 2),
        (cx + size, cy + r // 2),
        (cx, cy + size + r // 2),
    ], fill=color)


def draw_arrow(draw, x, y, w, h, color=(255, 255, 255, 220)):
    draw.rectangle([x, y - h, x + w, y + h], fill=color)
    draw.polygon([
        (x + w, y - h*3),
        (x + w + int(h*2.2), y),
        (x + w, y + h*3),
    ], fill=color)


# ── 1. Store Icon 512×512 ─────────────────────────────────────────────────────
def make_store_icon():
    S = 512
    img = radial_gradient(S, S, (255, 165, 30), (210, 55, 15))
    mask = rounded_mask(S, S, int(S * 0.22))
    result = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    result.paste(img, mask=mask)

    # Glow
    for i in range(5, 0, -1):
        ov = Image.new('RGBA', (S, S), (0,0,0,0))
        r = int(S * 0.38)
        cx = cy = S//2
        ImageDraw.Draw(ov).ellipse(
            [cx-r-i*3, cy-r-i*3, cx+r+i*3, cy+r+i*3],
            fill=(255, 210, 80, int(25*(i/5)))
        )
        result = Image.alpha_composite(result, ov)

    draw = ImageDraw.Draw(result)
    cx = cy = S // 2

    draw_fork(draw, cx - int(S*0.07), cy + int(S*0.04), scale=S/512)
    draw_heart(draw, cx + int(S*0.16), cy + int(S*0.20), int(S*0.09))
    draw_arrow(draw,
               cx + int(S*0.18), cy - int(S*0.12),
               int(S*0.09), int(S*0.025))

    out = os.path.join(OUT, 'store_icon.png')
    result.save(out)
    print(f'Saved {out}')


# ── 2. Feature Graphic 1024×500 ───────────────────────────────────────────────
def make_feature_graphic():
    W, H = 1024, 500
    # Horizontal gradient: warm amber left → deep orange-red right
    img = Image.new('RGB', (W, H))
    px = img.load()
    for x in range(W):
        t = x / W
        c = lerp((255, 150, 20), (200, 45, 10), t)
        for y in range(H):
            px[x, y] = c

    # Diagonal light sweep
    sweep = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(sweep)
    for i in range(80):
        alpha = int(40 * (1 - i/80))
        sd.line([(i*4 - 80, 0), (i*4 + H, H)],
                fill=(255, 230, 150, alpha), width=6)
    base = Image.new('RGBA', (W, H), (0,0,0,0))
    base.paste(img)
    base = Image.alpha_composite(base, sweep)

    draw = ImageDraw.Draw(base)

    # Large decorative fork — left side
    draw_fork(draw, int(W*0.18), int(H*0.52), scale=1.9, color='white')

    # Small heart
    draw_heart(draw, int(W*0.30), int(H*0.68), int(H*0.10), color='white')

    # Swipe arrow
    draw_arrow(draw, int(W*0.31), int(H*0.35), int(W*0.07), int(H*0.025))

    # App name text
    try:
        font_lg = ImageFont.truetype("arial.ttf", 82)
        font_sm = ImageFont.truetype("arial.ttf", 36)
    except:
        font_lg = ImageFont.load_default()
        font_sm = font_lg

    # Shadow
    draw.text((int(W*0.46)+3, int(H*0.28)+3), "CookSwipe",
              font=font_lg, fill=(0, 0, 0, 60))
    draw.text((int(W*0.46), int(H*0.28)), "CookSwipe",
              font=font_lg, fill='white')

    draw.text((int(W*0.46)+2, int(H*0.58)+2),
              "Never wonder what to eat again.",
              font=font_sm, fill=(0, 0, 0, 50))
    draw.text((int(W*0.46), int(H*0.58)),
              "Never wonder what to eat again.",
              font=font_sm, fill=(255, 240, 200))

    draw.text((int(W*0.46), int(H*0.70)),
              "Swipe  •  Decide  •  Enjoy",
              font=font_sm, fill=(255, 220, 160))

    out = os.path.join(OUT, 'feature_graphic.png')
    base.convert('RGB').save(out)
    print(f'Saved {out}')


if __name__ == '__main__':
    make_store_icon()
    make_feature_graphic()
    print('\nAll store assets generated in assets/store/')
