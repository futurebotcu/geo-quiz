# Geo Quiz

A geography quiz application with capital city photos and country flags, built for both Flutter and React Native/Expo platforms.

## 🎮 Modlar (Quiz Modes)

Geo Quiz uygulaması iki farklı quiz modunu destekler:

### 1. 📍 Başkent Modu (Capital Mode)
Sadece başkent şehri fotoğraflarını kullanır. Bayrak görselleri hiç kullanılmaz.

**Görsel Öncelik Sırası:**
1. **WebP** → En optimize format (varsa)
2. **Fotoğraf** → Orijinal JPG fotoğrafı
3. **Placeholder** → Generic görsel (son çare)

**Özellikler:**
- ✅ Yüksek kaliteli şehir fotoğrafları
- ✅ WebP optimize desteği
- ✅ 183/195 başkent kapsaması (%93.8)
- ❌ Bayrak fallback yok

**Veri Kaynağı:** `data/assets_manifest.json`

### 2. 🏳️ Bayrak Modu (Flag Mode)
Ülke bayraklarını kullanır, PNG dosyası yoksa emoji fallback.

**Fallback Mantığı:**
1. **PNG Dosyası** → `assets/flags/{iso2}.png` (varsa)
2. **Emoji Fallback** → Unicode bayrak emojisi (🇹🇷, 🇺🇸, vs.)

**Özellikler:**
- ✅ 13 adet PNG bayrak dosyası mevcut
- ✅ 182 ülke için emoji fallback
- ✅ %100 kapsama garanti
- ✅ Tüm platformlarda çalışır

**Veri Kaynağı:** `data/flags_manifest.json`

## 🛠️ Teknik Implementasyon

### Flutter
```dart
import 'package:geo_quiz/utils/image_picker.dart';

// Başkent Modu
final capitals = await loadCapitalManifest();
final image = pickCapitalImage(capitals.first);

// Bayrak Modu
final flags = await loadFlagManifest();
Widget flagWidget = buildFlagDisplay(flags.first);

// Emoji helper
String emoji = flagEmoji('tr'); // 🇹🇷
```

### React Native/Expo
```typescript
import {
  getCapitalItems,
  getFlagItems,
  pickCapitalSource,
  renderFlag,
  flagEmoji
} from './src/utils/imagePicker';

// Başkent Modu
const capitals = getCapitalItems();
const imageSource = pickCapitalSource(capitals[0]);

// Bayrak Modu
const flags = getFlagItems();
const flagDisplay = renderFlag(flags[0]);

// Emoji helper
const emoji = flagEmoji('tr'); // 🇹🇷
```

## 📁 Dosya Yapısı

```
geo_quiz/
├── data/
│   ├── assets_manifest.json     # Başkent modu manifest
│   ├── flags_manifest.json      # Bayrak modu manifest
│   ├── countries.json           # Referans ülke verisi
│   └── review_log.csv           # İşlem kayıtları
├── assets/
│   ├── capital_photos/          # Başkent fotoğrafları (183 adet)
│   ├── flags/                   # PNG bayrak dosyaları (13 adet)
│   └── placeholders/            # Placeholder görseller
├── lib/utils/
│   └── image_picker.dart        # Flutter utility kodları
└── src/utils/
    └── imagePicker.ts           # React Native utility kodları
```

## 🚀 Kurulum ve Kullanım

### Flutter Uygulaması

#### Gereksinimler
- Flutter SDK (3.0+)
- Dart (3.0+)
- Android Studio / VS Code

#### Kurulum
```bash
# Repository'yi klonlayın
git clone <repo-url>
cd geo_quiz

# Flutter bağımlılıklarını yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

#### pubspec.yaml Konfigürasyonu
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  shared_preferences: ^2.0.18

flutter:
  assets:
    - data/assets_manifest.json
    - data/flags_manifest.json
    - assets/capital_photos/
    - assets/flags/
    - assets/placeholders/
```

#### Test Çalıştırma
```bash
# Unit testleri çalıştır
flutter test

# Widget testleri çalıştır
flutter test test/widget_test.dart
```

### React Native (Expo) Uygulaması

#### Gereksinimler
- Node.js (16+)
- npm veya yarn
- Expo CLI
- Android Studio / Xcode (fiziksel cihaz testleri için)

#### Kurulum
```bash
# Repository'yi klonlayın
git clone <repo-url>
cd geo_quiz

# Node.js bağımlılıklarını yükleyin
npm install
# veya
yarn install

# Expo development server'ı başlatın
npx expo start
```

#### package.json Bağımlılıkları
```json
{
  "dependencies": {
    "expo": "~49.0.0",
    "react": "18.2.0",
    "react-native": "0.72.4",
    "@react-navigation/native": "^6.1.7",
    "@react-navigation/native-stack": "^6.9.13",
    "@react-native-async-storage/async-storage": "1.19.1",
    "@react-native-picker/picker": "2.4.10",
    "expo-linear-gradient": "~12.3.0"
  }
}
```

#### Expo Konfigürasyonu (app.json)
```json
{
  "expo": {
    "name": "Geo Quiz",
    "slug": "geo-quiz",
    "version": "1.0.0",
    "assetBundlePatterns": [
      "assets/capital_photos/*",
      "assets/flags/*",
      "assets/placeholders/*",
      "data/assets_manifest.json",
      "data/flags_manifest.json"
    ]
  }
}
```

#### Test Çalıştırma
```bash
# Jest testlerini çalıştır
npm test
# veya
yarn test

# Test coverage raporu
npm run test:coverage
```

## 📊 İstatistikler

### Başkent Modu
- **Toplam:** 195 başkent
- **Fotoğrafı olan:** 183 (%93.8)
- **Eksik:** 12 başkent

### Bayrak Modu
- **Toplam:** 195 ülke
- **PNG dosyası:** 13 (%6.7)
- **Emoji fallback:** 182 (%93.3)
- **Kapsama:** %100

### Eksik Başkent Fotoğrafları
Öncelikli tamamlanması gerekenler:
- 🇦🇬 Antigua and Barbuda (Saint John's)
- 🇧🇷 Brazil (Brasília)
- 🇨🇷 Costa Rica (San José)
- 🇱🇰 Sri Lanka (Sri Jayawardenepura Kotte)
- 🇲🇩 Moldova (Chișinău)
- 🇲🇻 Maldives (Malé)
- 🇵🇾 Paraguay (Asunción)
- 🇸🇹 São Tomé and Príncipe (São Tomé)
- 🇹🇩 Chad (N'Djamena)
- 🇹🇬 Togo (Lomé)
- 🇹🇴 Tonga (Nuku'alofa)
- 🇺🇸 United States (Washington, D.C.)

## 🔧 Geliştirme Araçları

### Analiz Scripts
```bash
# Başkent fotoğrafları analizi
python analyze_capital_photos.py

# Mod ayrımı işlemi
python mode_separation.py

# Bayrak fallback analizi
python flag_fallback_analysis.py --dry-run
```

### Manifest Validation
```bash
# Başkent manifest doğrulama
python -c "import json; json.load(open('data/assets_manifest.json'))"

# Bayrak manifest doğrulama
python -c "import json; json.load(open('data/flags_manifest.json'))"
```

## 📝 Notlar

- Tüm işlemler `data/review_log.csv` dosyasında kayıt altına alınır
- Mod ayrımı tamamen temiz - başkent ve bayrak sistemleri birbirinden bağımsız
- Emoji support tüm platformlarda çalışır (iOS, Android, Web)
- PNG bayrak dosyaları `assets/flags/{iso2}.png` formatında olmalı
- Missing fotoğraflar için placeholder görsel kullanılır

## 🎯 Performans

- **Başkent Modu:** Optimize WebP desteği ile hızlı yüklenme
- **Bayrak Modu:** Emoji fallback ile minimum dosya boyutu
- **Hybrid Yaklaşım:** Mükemmel performans ve %100 kapsama dengesi

---

*Generated with Geo Quiz visual management system* 🚀