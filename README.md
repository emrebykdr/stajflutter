# Staj Gorevi 1 - Flutter Loading, Video Player, Bildirim ve Google Maps

**Toplam Sure:** 3 Gun
**Hedef:** Flutter'da temel media, notification ve map/location entegrasyonlarini calisan bir demo olarak gelistirmek.

## Dosya Yapisi

```
lib/
├── main.dart                              # Uygulama giris noktasi
├── screens/
│   ├── loading_screen.dart                # Modul 1: 5sn loading → HomeScreen'e yonlendirme
│   ├── home_screen.dart                   # Ana menu - modullere navigasyon
│   ├── video_player_screen.dart           # Modul 2: URL giris alani + video player sayfasi
│   ├── reels_screen.dart                  # Modul 3: Instagram Reels tarzi grid gorunum
│   ├── reels_player_screen.dart           # Reels tam ekran dikey kaydirmali video oynatici
│   ├── notification_screen.dart           # Modul 4: 5sn sonra local bildirim demo
│   └── map_screen.dart                    # Modul 5: Harita + "Me" pin ile konum gosterimi
├── widgets/
│   └── video_player_widget.dart           # Reusable video player (YouTube/native otomatik ayrim)
└── services/
    ├── notification_service.dart           # Bildirim baslatma, izin isteme ve gonderme servisi
    └── location_service.dart              # Konum alma ve permission kontrolu servisi
```

## Moduller

| # | Modul | Aciklama |
|---|-------|----------|
| 1 | **Loading Sistemi** | Uygulama acildiginda 5sn `CircularProgressIndicator` + "Loading..." yazisi, sonra `pushReplacement` ile ana menuye gecis. `Future.delayed` kullanilir. |
| 2 | **Video Player Sayfasi** | Kullanicinin disaridan URL girebildigi veya hazir demo butonlariyla test edebildigi sayfa. Baslik, aciklama, player alani, loading ve error state yonetimi. |
| 3 | **Reusable Video Player Widget** | Disaridan `String videoUrl` alir. `youtube.com` / `youtu.be` iceriyorsa YouTube player, degilse native `video_player` ile calistirir. Dispose islemleri duzgun yapilir. |
| 4 | **Bildirim Sistemi** | Butona tiklaninca 5 saniye sonra telefona local notification gonderilir. Android 13+ icin runtime permission istenir. Bildirim title ve body iceriyor. |
| 5 | **Google Maps + Konum** | `flutter_map` ile OpenStreetMap haritasi. `geolocator` ile konum izni isteme, konum alma. Haritada sadece "Me" pin'i. Konum alinamazsa hata mesaji + "Tekrar Dene" butonu. |

## Kullanilan Paketler

| Paket | Kullanim Amaci |
|-------|---------------|
| `video_player` | Native video URL (.mp4 vb.) oynatma |
| `youtube_player_flutter` | YouTube URL oynatma |
| `flutter_local_notifications` | Telefona local notification gonderme |
| `timezone` | Bildirim zamanlama icin saat dilimi yonetimi |
| `flutter_map` + `latlong2` | OpenStreetMap harita gosterimi |
| `geolocator` | Telefon konumunu alma ve permission kontrolu |

## Calistirma

```bash
flutter pub get
flutter run
```

## Test Rehberi

1. **Loading Sistemi:** Uygulamayi baslat → 5sn loading ekrani gorunur → otomatik olarak ana menuye gecer
2. **Video Player:** "Video Player" kartina tikla → URL alanina YouTube veya .mp4 linki yapistir → Play'e bas. Hazir "Native Demo" ve "YouTube Demo" butonlari da mevcut
3. **Reels:** "Reels" kartina tikla → Grid'den bir thumbnail sec → Tam ekran dikey kaydirmali video player acilir
4. **Bildirim:** "Bildirim Sistemi" kartina tikla → "Bildirim Gonder" butonuna bas → 5 saniye sonra bildirim gelir
5. **Harita:** "Google Maps + Konum" kartina tikla → Konum izni ver → Haritada "Me" pin'i ile konumun gorunur

## Desteklenen URL Tipleri

```
https://www.youtube.com/watch?v=VIDEO_ID
https://youtu.be/VIDEO_ID
https://example.com/video.mp4
```

## Android/iOS Ayarlari

### Android
- `AndroidManifest.xml`: INTERNET, ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, SCHEDULE_EXACT_ALARM izinleri
- `build.gradle.kts`: Core library desugaring aktif (`flutter_local_notifications` icin)
- Android 13+ icin bildirim izni runtime'da isteniyor (`requestNotificationsPermission`)

### iOS
- Konum izni: `Info.plist` dosyasina `NSLocationWhenInUseUsageDescription` eklenmeli
- Bildirim izni: `DarwinInitializationSettings` ile alert, badge, sound izinleri uygulama icinden istenir

## Kontrol Listesi

- [x] Sayfa acildiginda 5 saniyelik loading calisiyor
- [x] Loading bittikten sonra icerik dogru gorunuyor
- [x] Video player sayfasi duzgun tasarlanmis (URL girisi + hazir demolar)
- [x] YouTube URL player icinde calisiyor
- [x] Native video URL player icinde calisiyor
- [x] Video controller dispose islemleri yapilmis
- [x] Bildirim izni isteniyor
- [x] Butona tiklaninca 5 saniye sonra bildirim geliyor
- [x] Google Maps ekranda duzgun gorunuyor
- [x] Telefon konumu dogru aliniyor
- [x] Konum izni reddedilirse hata mesaji gosteriliyor
- [x] Haritada sadece "Me" marker'i var
- [x] Kod okunabilir ve duzenli
- [x] Her modul ayri dosyada
- [x] Services katmani ayri (notification_service, location_service)
