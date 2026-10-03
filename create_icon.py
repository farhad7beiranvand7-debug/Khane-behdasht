from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parents[1]
source = root / 'tool' / 'icon.png'
size = 1024
img = Image.new('RGBA', (size, size), (0, 105, 92, 255))
d = ImageDraw.Draw(img)
# White home/health mark: roof + house + medical cross.
d.polygon([(180, 470), (512, 190), (844, 470)], fill=(255, 255, 255, 255))
d.rounded_rectangle((270, 430, 754, 820), radius=60, fill=(255, 255, 255, 255))
d.rectangle((450, 505, 574, 745), fill=(0, 105, 92, 255))
d.rectangle((390, 565, 634, 685), fill=(0, 105, 92, 255))
img.save(source)

res_root = root / 'android' / 'app' / 'src' / 'main' / 'res'
if res_root.exists():
    for density, scale in [('mdpi',1),('hdpi',1.5),('xhdpi',2),('xxhdpi',3),('xxxhdpi',4)]:
        out = res_root / f'mipmap-{density}'
        out.mkdir(parents=True, exist_ok=True)
        s = int(48 * scale)
        img.resize((s,s), Image.Resampling.LANCZOS).save(out / 'ic_launcher.png')
        img.resize((s,s), Image.Resampling.LANCZOS).save(out / 'ic_launcher_round.png')
print(source)
