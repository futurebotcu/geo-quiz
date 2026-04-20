# App Icon Specification

**App:** Geo Quiz: Flags, Capitals & Foods
**Primary Color:** Indigo #4F46E5
**Background:** White #FFFFFF (adaptive) / Dark variant: #1A1A2E

---

## Android Adaptive Icon

Flutter uses `flutter_launcher_icons` (already configured in pubspec.yaml).

### Required Source Files
| File | Path | Spec |
|------|------|------|
| Foreground layer | `assets/brand/app_icon_foreground.png` | 1024×1024 px, PNG with transparency |
| Background color | `#FFFFFF` (set in pubspec.yaml) | Solid color (no file needed) |
| Monochrome | `assets/brand/app_icon_mono.png` | 1024×1024 px, single-color silhouette |

### Safe Zone Rules
```
1024×1024 px total canvas
├── Outer boundary (may be cropped to circle/squircle/square)
│   ├── Full bleed zone: 0–1024px — background only, no important content
│   └── Safe zone: 133–891px (center 66% of canvas width/height)
│       └── Place all icon marks within this zone
└── Foreground PNG must have transparency outside the icon mark
```

Key dimensions:
- Safe zone inner diameter: ~840px (on a 1024px canvas, 18% bleed each side)
- For a circular mask: content must fit inside a 660px diameter circle

### Adaptive Icon Shapes by Launcher
| Launcher | Shape |
|----------|-------|
| Pixel / AOSP | Circle |
| Samsung One UI | Rounded square |
| MIUI / Xiaomi | Squircle |
| OnePlus | Rounded square |
| Stock Android | Squircle |

**Recommendation:** Design foreground mark at ~500px diameter, centered on 1024px canvas.

### Monochrome (Android 13+ Themed Icons)
- Single-color silhouette of the icon mark
- No gradients; flat white/black shape on transparent background
- System applies the color based on user's wallpaper theme

---

## iOS App Icon

No transparency allowed on iOS icons. Flutter's `flutter_launcher_icons` generates
all sizes from the 1024×1024 source.

### Required Sizes (generated automatically)
| Usage | Size |
|-------|------|
| App Store listing | 1024×1024 |
| iPhone app icon | 60×60 (2x: 120px, 3x: 180px) |
| iPad app icon | 76×76 (2x: 152px) |
| iPad Pro app icon | 83.5×83.5 (2x: 167px) |
| Spotlight | 40×40 (2x: 80px, 3x: 120px) |
| Settings | 29×29 (2x: 58px, 3x: 87px) |

### iOS Icon Rules
- No transparency (alpha channel)
- No rounded corners (iOS applies corner radius automatically)
- Background must be a solid color or gradient (no cut-outs)
- No text overlay (icon must be readable at 29×29 px)

---

## Commands to Regenerate Icons

After updating source image files:

```bash
# From project root:
dart run flutter_launcher_icons

# Verify output:
ls android/app/src/main/res/mipmap-*/
ls ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

---

## Current Status

The mipmap-* files in `android/app/src/main/res/` show as modified in git status,
suggesting icons were recently regenerated. Verify the source files at
`assets/brand/` are finalized before the next store submission.
