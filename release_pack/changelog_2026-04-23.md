# Değişiklik Kaydı — 2026-04-23

Bu oturumda yapılan tüm işlemlerin maddeler halinde özeti.

---

## 1) Gizlilik Politikası (Privacy Policy) için URL hazırlığı

- `docs/` klasörü oluşturuldu (GitHub Pages için).
- `docs/privacy.html` oluşturuldu — İngilizce gizlilik politikası, responsive + dark mode + dil değiştirici.
- `docs/privacy-tr.html` oluşturuldu — Türkçe gizlilik politikası, aynı tasarım.
- `docs/index.html` oluşturuldu — basit landing sayfası, iki dile yönlendirme.
- Commit: `6a953ec — docs: add GitHub Pages privacy policy site (EN + TR)`
- Push: `origin/main` üzerine yapıldı.

**Sonuç:** GitHub Pages açıldıktan sonra (Settings → Pages → main /docs) Play Store'a yapıştırılacak URL:
- `https://futurebotcu.github.io/geo-quiz/privacy.html` (EN)
- `https://futurebotcu.github.io/geo-quiz/privacy-tr.html` (TR)

---

## 2) Yeni Uygulama İkonu (2026-04-23) Yerleştirme

### Kaynak
- Yeni ikon dosyası bulundu: `ChatGPT Image 23 Nis 2026 13_41_46.png` (1254×1254, opak, alpha yok).
- `assets/app_icon_source_2026-04-23.png` adıyla `assets/` klasörüne taşındı (yeni "source of truth").
- Eski kaynak silindi: `assets/premium_sophisticated_app_icon_..._.png`
- Root'tan `ChatGPT Image 23 Nis...` dosyası temizlendi.

### Yedekleme
- Mevcut nisan-20 brand dosyaları yedeklendi: `assets/brand/__backup_pre_2026-04-23/`
  - `app_icon_foreground.png`, `app_icon_mono.png`, `icon_512.png`, `splash_logo.png`
- Yedek `.gitignore`'a eklendi (lokal kalır, repo'ya gitmez).

### Brand Türevleri (ImageMagick ile yeniden üretildi)
- `assets/brand/app_icon_foreground.png` → 1024×1024 (Lanczos filtre)
- `assets/brand/splash_logo.png` → 1024×1024
- `assets/brand/icon_512.png` → 512×512 (Play Store store-listing icon)
- `assets/brand/app_icon_mono.png` → 1024×1024 grayscale (Android 13+ themed icons)

### Platform İkonları (Otomatik üretim)
- `dart run flutter_launcher_icons` çalıştırıldı:
  - Android mipmap (5 yoğunluk: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi) → `ic_launcher.png`
  - Android adaptive icon foreground + monochrome (5 yoğunluk drawable klasörlerinde)
  - Android `mipmap-anydpi-v26/ic_launcher.xml` güncellendi
  - iOS `AppIcon.appiconset/` içinde ~25 farklı boyut (20×20'den 1024×1024'e)
- `dart run flutter_native_splash:create` çalıştırıldı:
  - Android splash (light + dark, normal + Android 12, 5 yoğunluk)
  - iOS LaunchImage (1x/2x/3x light + dark)

### Konfigürasyon
- `pubspec.yaml`'daki `flutter_launcher_icons` config olduğu gibi kalmaya devam ediyor (kaynak yolu sabit: `assets/brand/app_icon_foreground.png`).
- Adaptive icon background: `#26282F` (koyu lacivert) — yeni ikonun açık zeminini güzel çerçeveliyor.

### Commit + Push
- `ab5e4ea — chore(icon): replace launcher icon with new 2026-04-23 cartoon globe`
- 69 dosya değişti, push tamamlandı.

---

## 3) Memory (Hafıza) Güncellemesi

- `~/.claude/projects/.../memory/project_icon_source.md` güncellendi:
  - Eski: "Premium icon is source of truth (2026-04-20)"
  - Yeni: "Icon source of truth (2026-04-23)" — yeni dosya yolunu ve regenerasyon komutlarını içeriyor.
- `MEMORY.md` index satırı güncellendi.

---

## Doğrulama Adımları (Sen yapacaksın)

1. **GitHub Pages aç:**
   - https://github.com/futurebotcu/geo-quiz/settings/pages
   - Source: `Deploy from a branch`, Branch: `main`, Folder: `/docs` → Save
2. **Yerel uygulamada ikonu gör:**
   - `flutter clean && flutter run`
3. **Release build (Play Store yüklemesi için):**
   - `flutter build appbundle --release --target-platform android-arm64,android-x64`
   - `versionCode`'u artırmayı unutma (şu an `1.0.0+2`).
4. **Play Console'a yükle:**
   - Privacy Policy URL: `https://futurebotcu.github.io/geo-quiz/privacy.html`
   - Store icon: `assets/brand/icon_512.png`

---

## Notlar

- Yeni ikon opak (alpha kanalı yok) → iOS için flatten gerekmedi, doğrudan kullanılabilir.
- Mono ikon basit grayscale + level ayarı — Android 13+ themed icon için "yeterli" seviyede; mükemmel silüet için elle tasarım gerekir.
- Eski 2026-04-20 yedekler `assets/brand/__backup_pre_2026-04-23/` altında lokal duruyor (geri dönüş için).
