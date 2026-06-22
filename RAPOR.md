# Staj Gorevi - Proje Raporu

**Proje:** Flutter Demo Uygulamasi — Video Player, Reels, Bildirim, Google Maps
**Hedef:** Flutter'da media, notification, map/location entegrasyonlarini ve web uyumlulugunu calisan bir demo olarak gelistirmek.

---

## 1. Proje Yapisi

```
lib/
├── main.dart                              # Giris noktasi, tema (dark/light), ValueNotifier
├── screens/
│   ├── loading_screen.dart                # 5sn loading → ana menuye gecis
│   ├── home_screen.dart                   # Ana menu - renkli kartlar, tema gecis butonu
│   ├── video_player_screen.dart           # Video player - URL girisi, video listesi, ekleme/silme
│   ├── reels_screen.dart                  # Reels grid - YouTube/Native karisik, ekleme/silme
│   ├── reels_player_screen.dart           # Tam ekran dikey kaydirmali reels oynatici
│   ├── notification_screen.dart           # Bildirim demo - mobil + web destegi
│   ├── map_screen.dart                    # Harita + konum
│   └── test_screen.dart                   # Loading deneme ekrani
├── widgets/
│   └── video_player_widget.dart           # Platform bazli video player (web/mobil)
└── services/
    ├── notification_service.dart           # Mobil bildirim servisi
    ├── web_notification_stub.dart          # Web bildirim stub (mobil icin)
    ├── web_notification_web.dart           # Browser Notification API (web icin)
    ├── video_storage_service.dart          # Lokal video kayit servisi (SharedPreferences)
    └── location_service.dart              # Konum servisi
```

---

## 2. Uygulama Akisi

```
Uygulama acilir
    │
    ▼
LoadingScreen (5sn loading)
    │ Navigator.pushReplacement
    ▼
HomeScreen (ana menu — dark/light mod gecis butonu)
    ├── 1. Video Player Sayfasi (ekleme/silme, YouTube + Native)
    ├── 2. Reels Sayfasi → ReelsPlayerScreen (tam ekran, overlay kontroller)
    ├── 3. Bildirim Sistemi (mobil: local notification, web: browser notification)
    ├── 4. Google Maps + Konum
    └── 5. Loading Deneme
```

---

## 3. main.dart — Tema Yonetimi ve Dark Mode

| Ozellik | Aciklama |
|---------|----------|
| `ValueNotifier<ThemeMode>` | Global tema durumu, tum uygulama anlik guncellenir |
| `ValueListenableBuilder` | MaterialApp tema degisikligini dinler |
| `theme:` | Light mode — `ColorScheme.fromSeed` ile cyan tonu |
| `darkTheme:` | Dark mode — ayni seed renk, `brightness: Brightness.dark` |
| `themeMode:` | `ThemeMode.system` (varsayilan), kullanici butonla degistirebilir |

### Dark/Light Mod Gecisi
- `home_screen.dart` AppBar'da gunes/ay ikonu
- Tiklaninca `themeNotifier.value` degisiyor → tum uygulama anlik gecis yapiyor
- Material 3 sayesinde tum widget'lar otomatik uyum sagliyor

---

## 4. Home Ekrani — Sade Kartlar

| Ozellik | Aciklama |
|---------|----------|
| `_ModuleCard` | Her modul icin renkli ikon + beyaz/koyu arka plan |
| Renk sistemi | Her module ozel renk (mor, pembe, mavi, pembe, yesil) — `color.withValues(alpha: 0.15)` ikon arka plani |
| `InkWell` | Material ripple efekti |
| `Theme.of(context).colorScheme.onSurfaceVariant` | Tema uyumlu alt baslik rengi |
| Tema gecis butonu | AppBar'da `Icons.dark_mode` / `Icons.light_mode` — anlik gecis |

---

## 5. Modul 1: Loading Sistemi

**Dosya:** `lib/screens/loading_screen.dart`

| Beklenti | Karsiligi |
|----------|-----------|
| 5sn loading | `Future.delayed(const Duration(seconds: 5))` — initState icinde |
| Loader gorunmeli | `CircularProgressIndicator()` |
| Loading sonrasi gecis | `Navigator.pushReplacement` ile HomeScreen'e |
| mounted kontrolu | Kullanici erken cikarsa crash onlenir |

**Test Ekrani:** `test_screen.dart` — HomeScreen'den "5. Loading Deneme" karti ile erisim, loading akisini test eder.

---

## 6. Modul 2: Video Player ve Reels

### 6a. Video Player Widget (video_player_widget.dart)

**Platform bazli YouTube player:**

| Platform | Kullanilan Paket | Neden |
|----------|-----------------|-------|
| Android/iOS | `youtube_player_flutter` | InAppWebView tabanli, mobilde sorunsuz |
| Web | `youtube_player_iframe` | iframe tabanli, tarayicida calisir |

```dart
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt_mobile;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt_web;
```

- `kIsWeb` ile platform tespiti
- Mobilde `yt_mobile.YoutubePlayerController` + `yt_mobile.YoutubePlayer`
- Web'de `yt_web.YoutubePlayerController.fromVideoId` + `yt_web.YoutubePlayer`

**Native Video Overlay Kontrolleri:**

| Kontrol | Aciklama |
|---------|----------|
| 10sn geri sarma | `Icons.replay_10` — `seekTo(position - 10s)` |
| Oynat/Durdur | `Icons.pause_circle_filled` / `Icons.play_circle_filled` |
| 10sn ileri sarma | `Icons.forward_10` — `seekTo(position + 10s)` |
| Progress bar | `Slider` ile surukleme, anlik konum guncelleme |
| Sure gosterimi | `00:00 / 00:30` formati |
| Overlay gorunurluk | Videoya dokunarak goster/gizle, `AnimatedOpacity` ile gecis |

Kontroller videonun **icinde overlay** olarak gosterilir (YouTube player tarzi). `IgnorePointer` ile gizlendiginde tiklama engellenir.

### 6b. Video Player Sayfasi (video_player_screen.dart)

| Ozellik | Aciklama |
|---------|----------|
| URL girisi | `TextField` ile YouTube veya .mp4 URL |
| Hazir demolar | "Native Demo" ve "YouTube Demo" chipleri |
| Video listesi | `VideoStorageService`'den yuklenir |
| Video ekleme | AppBar'da "+" butonu → baslik + URL dialog |
| Video silme | Her kartta silme butonu → onay dialog |
| Responsive | Web'de `ConstrainedBox(maxWidth: 800)` |

### 6c. Reels Sayfasi (reels_screen.dart)

| Ozellik | Aciklama |
|---------|----------|
| Grid layout | Alternating pattern (2 kucuk + 1 buyuk, tekrar) |
| Kategori filtreleri | Tumu / Native / YouTube chipleri |
| YouTube thumbnail | `img.youtube.com/vi/{ID}/hqdefault.jpg` API |
| Native thumbnail | `_NativeVideoThumbnail` — videonun ilk karesi |
| Video ekleme | AppBar'da "+" butonu |
| Video silme | Thumbnail'e uzun basma → onay dialog |
| YT etiketi | YouTube videolarinda kirmizi "YT" badge |

### 6d. Reels Player (reels_player_screen.dart)

| Ozellik | Aciklama |
|---------|----------|
| Tam ekran | `backgroundColor: Colors.black` + `StackFit.expand` |
| Dikey kaydirma | `PageView.builder(scrollDirection: Axis.vertical)` |
| Geri butonu | Sol ustte yari saydam daire icinde `Icons.arrow_back` |
| Overlay kontroller | `showControls: true` — videoya dokunarak goster/gizle |
| YouTube etiketi | YouTube videolarinda kirmizi "YouTube" badge |

---

## 7. Modul 3: Lokal Video Yonetimi

**Dosya:** `lib/services/video_storage_service.dart`

| Ozellik | Aciklama |
|---------|----------|
| `SharedPreferences` | Video listesi JSON olarak cihazda saklanir |
| `getVideos()` | Kayitli videolari yukler, yoksa varsayilan listeyi doner |
| `addVideo()` | Yeni video ekler ve kaydeder |
| `removeVideo()` | Belirtilen indeksteki videoyu siler |
| `resetToDefaults()` | Varsayilan listeye sifirlar |
| `VideoItem` modeli | `videoUrl`, `title`, `isYoutube`, `youtubeId`, `thumbnailUrl` |

**Varsayilan video listesi:** 9 video (5 native .mp4 + 4 YouTube)

---

## 8. Modul 4: Bildirim Sistemi

### Mobil (Android/iOS)

**Dosyalar:** `notification_screen.dart` + `notification_service.dart`

| Ozellik | Aciklama |
|---------|----------|
| Permission | Android 13+ icin `requestNotificationsPermission()` |
| Channel | `AndroidNotificationDetails('staj_demo_channel', ...)` |
| 5sn gecikme | `Future.delayed(const Duration(seconds: 5))` |
| State takibi | "Hazir" → "Bekleniyor... 5 saniye" → "Bildirim gonderildi!" |

### Web (Browser Notification API)

**Dosyalar:** `web_notification_web.dart` + `web_notification_stub.dart`

| Ozellik | Aciklama |
|---------|----------|
| JS Interop | `dart:js_interop` ile `Notification` API'sine erisim |
| Conditional import | `if (dart.library.html)` ile web/mobil ayirimi |
| Permission | `Notification.requestPermission()` — tarayici izin dialog |
| Bildirim gonderme | `new Notification(title, {body: body})` — masaustu bildirimi |

```dart
// Conditional import pattern
import '../services/web_notification_stub.dart'
    if (dart.library.html) '../services/web_notification_web.dart';
```

- `kIsWeb == true` → Browser Notification API kullanilir
- `kIsWeb == false` → `flutter_local_notifications` kullanilir

---

## 9. Modul 5: Google Maps ve Konum

**Dosyalar:** `map_screen.dart` + `location_service.dart`

| Ozellik | Aciklama |
|---------|----------|
| Harita | `FlutterMap` + OpenStreetMap tile layer |
| Konum | `Geolocator.getCurrentPosition(accuracy: high)` |
| Permission | `checkPermission()` → `requestPermission()` akisi |
| Marker | Tek "Me" marker'i, mavi baslik + kirmizi pin |
| Hata durumu | Kirmizi ikon + mesaj + "Tekrar Dene" butonu |
| Konum bulunamadi | `LocationException` ozel sinifi |

---

## 10. Kullanilan Paketler

| Paket | Kullanim Amaci |
|-------|---------------|
| `video_player` | Native video (.mp4) oynatma |
| `youtube_player_flutter` | YouTube oynatma (mobil) |
| `youtube_player_iframe` | YouTube oynatma (web) |
| `shared_preferences` | Lokal video listesi kaydi |
| `flutter_local_notifications` | Mobil bildirim gonderme |
| `timezone` | Saat dilimi yonetimi |
| `flutter_map` | OpenStreetMap harita |
| `latlong2` | Koordinat sistemi |
| `geolocator` | Konum alma ve permission |

---

## 11. Web Uyumlulugu

| Sorun | Cozum |
|-------|-------|
| `youtube_player_flutter` web'de calismaz | `kIsWeb` ile platform tespiti, web'de `youtube_player_iframe` kullanilir |
| `flutter_local_notifications` web destegi yok | Browser Notification API (`dart:js_interop`) ile web bildirimi |
| Widget boyutlari web'de cok genis | `ConstrainedBox(maxWidth: 600-900)` ile responsive sinir |
| Conditional import | `if (dart.library.html)` ile web-only kod ayirimi |

---

## 12. Kontrol Listesi

| # | Kontrol | Durum |
|---|---------|-------|
| 1 | 5sn loading calisiyor mu? | TAMAM |
| 2 | Loading sonrasi HomeScreen aciliyor mu? | TAMAM |
| 3 | Dark/Light mod gecisi calisiyor mu? | TAMAM |
| 4 | Native video overlay kontrolleri calisiyor mu? | TAMAM |
| 5 | YouTube video calisiyor mu? (mobil) | TAMAM |
| 6 | YouTube video calisiyor mu? (web) | TAMAM |
| 7 | Video ekleme/silme calisiyor mu? | TAMAM |
| 8 | Reels grid duzgun gorunuyor mu? | TAMAM |
| 9 | Reels player overlay kontrolleri calisiyor mu? | TAMAM |
| 10 | Reels'te geri butonu sol ustte mi? | TAMAM |
| 11 | Thumbnail'lar gercek video onizlemesi mi? | TAMAM |
| 12 | Bildirim mobilde calisiyor mu? | TAMAM |
| 13 | Bildirim web'de calisiyor mu? | TAMAM |
| 14 | Google Maps gorunuyor mu? | TAMAM |
| 15 | Konum izni ve hata durumu calisiyor mu? | TAMAM |
| 16 | Web'de responsive layout calisiyor mu? | TAMAM |
| 17 | Controller dispose islemleri yapilmis mi? | TAMAM |

---

## 13. Commit Gecmisi

| Commit | Aciklama |
|--------|----------|
| Staj Gorevi 1 | Flutter Loading, Video Player, Bildirim ve Google Maps |
| Staj Gorevi 2 | Native player kontrolleri, Reels iyilestirmeleri ve Loading deneme ekrani |
| Staj Gorevi 3 | Web uyumlulugu, dark mode, bildirim ve UI iyilestirmeleri |
