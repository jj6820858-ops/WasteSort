"""Generate the original Guixu leaf mark, including all Windows ICO sizes."""
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parents[1] / "assets"
root.mkdir(exist_ok=True)
scale = 4
im = Image.new("RGBA", (512 * scale, 512 * scale))
draw = ImageDraw.Draw(im)
def points(coords):
    return [(int(x * scale), int(y * scale)) for x, y in coords]
def bezier(a, b, c, d, count=64):
    return [((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*d[0],
             (1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*d[1])
            for t in [i/count for i in range(count+1)]]

draw.rounded_rectangle((16*scale, 16*scale, 496*scale, 496*scale), radius=116*scale, fill="#10251E")
draw.rounded_rectangle((27*scale, 27*scale, 485*scale, 485*scale), radius=106*scale, outline="#365E4B", width=3*scale)
leaf = bezier((150,357), (64,196), (226,113), (387,110))
leaf += bezier((387,110), (391,290), (304,421), (150,357))
draw.polygon(points(leaf), fill="#9BE5BC")
stem = bezier((123,393), (189,302), (241,254), (322,183))
draw.line(points(stem), fill="#10251E", width=19*scale)
draw.ellipse((113*scale,383*scale,133*scale,403*scale), fill="#9BE5BC")
im = im.resize((512, 512), Image.Resampling.LANCZOS)
im.save(root / "guixu.png")
im.save(root / "guixu.ico", sizes=[(n,n) for n in (16,24,32,48,64,128,256)])
print("Created assets/guixu.png and guixu.ico")
