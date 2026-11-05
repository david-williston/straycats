# StrayCats brand kit (Saibo)

The StrayCats identity is a portrait of Saibo: charcoal-grey fur, white chest and paws, golden
eyes and a white marking beside the nose, resting his paws on the lettering against a sunset
skyline. Beneath it sits the wordmark "Straycats" (with a paw print in the "a") followed by
".love" in white inside a red glossy heart. The artwork was generated with ChatGPT and exists
only as raster images (no vector version).

The same files can be downloaded one at a time from the Press page:
https://straycats.love/press/

## Two versions of the logo

| Version | What it is |
| --- | --- |
| `with-underline` | Exactly the original design, including the thin red swoosh under the lettering. |
| `no-underline` | The same image with only the red swoosh removed. **Recommended**: it is cleaner, especially at small sizes. |

Nothing else differs. The cat, the lettering and the heart are untouched in both.

## Folders

| Folder | Contents |
| --- | --- |
| `01_Artwork/` | The logo (cat, "Straycats" and ".love" heart) in both versions: transparent with a white sticker outline (1385×1152 px), transparent without the outline (`-no-outline`), and on white (1425×1192 px). Also the untouched source cutout. |
| `02_Web/` | `favicon.ico` (16, 32, 48, 64 px), favicon PNGs at those sizes, the logo as WebP, a 1400×1100 hero image, and a 1200×630 link-preview card, each in both versions. |
| `03_App_Icons/` | Square app icons, 72–1024 px, for the home screen (PWA), iOS and Android, and maskable 192 and 512 px icons for Android. |
| `04_Print/` | The logo on white as a 300 dpi TIFF, in both versions. |

## Suggested use

- Browser tab: `02_Web/favicon.ico`, with `favicon-32.png` as a PNG fallback.
- iOS home screen: `03_App_Icons/straycats-app-icon-180.png` (`apple-touch-icon`).
- Web app manifest: `straycats-app-icon-192.png` and `-512.png`, plus the maskable 192 and 512.
- Site header and pages: `02_Web/straycats-logo-no-underline-transparent.webp`, or the PNG in `01_Artwork/`.
- Dark backgrounds: use the `-transparent` files (with the white sticker outline). The
  `-no-outline` files have black lettering and vanish on dark backgrounds; use them on light ones only.
- Android adaptive icon background: sunset orange `#F6B24E`.

## About the transparent files

The source cutout has a transparent background, but no outline around the lettering, and the
counters of the letters and the paw print in the "a" are see-through. The `-transparent` files add
a white sticker outline around the whole logo and fill those counters white, so the logo looks the
same on any background as it does on white. The `-no-outline` files are the plain cutout.

## Icons and favicons

The full logo is unreadable at icon sizes, so the app icons and favicons use Saibo's face alone, on
sunset orange, with rounded corners (the maskable icons are full-bleed squares). The white marking beside his nose is left clear. The face is cropped from the
artwork and set on the orange; no part of it was redrawn.

## Size limits

The artwork's native size is 1376×1143 px, with no vector version. The hero and social card are
scaled down from the logo and are sharp. The 300 dpi TIFF is the same pixels as the on-white logo
with print metadata, so it prints well only up to about 12 × 10 cm. Large-format print would need
the artwork redrawn at a higher resolution.

The icon artwork is 512 px. The favicons (16–64 px), the 180 and 192 px app icons and the maskable
icons come straight from the icon set; the other sizes (72–167 px, 256 and 384 px) are scaled from
the 512 px icon. The 1024 px app icon is an enlargement of the 512 px icon, so it has no more real
detail than the 512 px one.

The 16 and 32 px favicons are scaled down from the portrait. At those sizes the portrait is only a
rough shape; that is expected.

## Colours

| Name | Hex |
| --- | --- |
| Midnight charcoal | `#17212A` |
| Dark background | `#10161F` |
| Warm sunrise | `#FFD987` |
| Sunset amber | `#F8AD50` |
| Deep sunset | `#E77645` |
| Saibo white | `#F7F5EF` |
| Golden eyes | `#E8BD64` |
| Heart red | `#D02425` |
