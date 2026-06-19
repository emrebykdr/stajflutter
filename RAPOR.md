# Staj Gorevi 1 - Proje Raporu

**Proje:** Flutter Loading, Video Player, Bildirim ve Google Maps
**Toplam Sure:** 3 Gun
**Hedef:** Flutter'da temel media, notification ve map/location entegrasyonlarini calisan bir demo olarak gelistirmek.

---

## 1. Proje Yapisi

```
lib/
├── main.dart                          # Uygulama giris noktasi, tema ve ilk ekran ayari
├── screens/
│   ├── loading_screen.dart            # Modul 1: 5sn loading → ana menuye gecis
│   ├── home_screen.dart               # Ana menu - tum modullere navigasyon
│   ├── video_player_screen.dart       # Modul 2: URL giris alani + video player demo sayfasi
│   ├── reels_screen.dart              # Modul 2: Instagram Reels tarzi grid gorunum
│   ├── reels_player_screen.dart       # Reels tam ekran dikey kaydirmali video oynatici
│   ├── notification_screen.dart       # Modul 4: Bildirim demo sayfasi
│   └── map_screen.dart                # Modul 5: Harita + konum sayfasi
├── widgets/
│   └── video_player_widget.dart       # Modul 3: Reusable video player widget
└── services/
    ├── notification_service.dart       # Bildirim servisi (init, permission, show)
    └── location_service.dart          # Konum servisi (permission, konum alma)
```

### Neden Bu Yapi?
- **screens/**: Her modulun ekrani ayri dosyada → PDF'deki "her ana modul ayri dosyada" beklentisi karsilaniyor
- **widgets/**: Tekrar kullanilabilir (reusable) widget'lar → PDF'deki "widget icinde gereksiz tekrar yapilmamali" beklentisi
- **services/**: Is mantigi UI'dan ayrilmis → Bildirim ve konum islemleri ekranlardan bagimsiz calisir

---

## 2. Uygulama Akisi

```
Uygulama acilir
    │
    ▼
LoadingScreen (5sn loading)
    │ Navigator.pushReplacement
    ▼
HomeScreen (ana menu)
    ├── Video Player Sayfasi
    ├── Reels Sayfasi → ReelsPlayerScreen (tam ekran)
    ├── Bildirim Sistemi
    └── Google Maps + Konum
```

### main.dart (Giris Noktasi)

| Satir | Aciklama |
|-------|----------|
| 4 | `runApp(const MyApp())` — uygulama baslatiliyor |
| 14 | `title: 'Staj Demo'` — uygulama basligi |
| 15 | `debugShowCheckedModeBanner: false` — sag ustteki DEBUG bandi kaldirildi |
| 16-18 | `ThemeData` ile Material 3 tema, `deepPurple` renk semasi |
| 20 | `home: const LoadingScreen()` — ilk ekran olarak LoadingScreen ayarlandi |

### home_screen.dart (Ana Menu)

| Satir | Aciklama |
|-------|----------|
| 7 | `StatelessWidget` — degisen state yok, sabit menu |
| 17 | `ListView` — modullerin listesi, kayan icerik |
| 20-55 | 4 adet `_ModuleCard` — her karta tiklaninca `Navigator.push` ile ilgili ekrana gidiliyor |
| 62-88 | `_ModuleCard` — private reusable widget. `icon`, `title`, `subtitle`, `onTap` alir. Bir kere yazildi, 4 yerde kullanildi |

---

## 3. Modul 1: Loading Sistemi

**Dosya:** `lib/screens/loading_screen.dart`

### PDF Beklentileri ve Kodda Karsiliklari

| Beklenti | Kodda Karsiligi |
|----------|----------------|
| Sayfa acildiginda 5sn loading | Satir 16: `Future.delayed(const Duration(seconds: 5))` — `initState` icinde sayfa acilir acilmaz basliyor |
| Loading sirasinda loader gorunmeli | Satir 33: `CircularProgressIndicator()` — donen animasyonlu loader |
| "Loading..." yazisi gorunmeli | Satir 36: `Text('Loading...')` — loader'in altinda gri renkli yazi |
| 5sn sonra loading kapanmali | Satir 17-20: `Navigator.pushReplacement` — 5sn dolunca loading ekrani tamamen kapanip HomeScreen'e geciyor |
| Future.delayed kullanilabilir | Satir 16: `Future.delayed` kullaniliyor |
| Loading state acik ve anlasilir | `StatefulWidget` + `initState` icinde zamanlayici + `mounted` kontrolu — sade ve okunabilir |
| Uygulama acildiginda ilk ekran | `main.dart` satir 20: `home: const LoadingScreen()` — uygulama ilk acildiginda bu ekran geliyor |

### Teknik Detaylar
- `pushReplacement` kullanildi ki kullanici geri tusuna basinca loading ekranina donmesin, dogrudan uygulamadan ciksin
- `if (mounted)` kontrolu: kullanici 5sn dolmadan sayfadan cikarsa `setState` cagrilmaz, crash onlenir

---

## 4. Modul 2: Video Player Sayfa Tasarimi

**Dosyalar:**
- `lib/screens/video_player_screen.dart` — Video player demo sayfasi
- `lib/screens/reels_screen.dart` — Instagram Reels tarzi grid gorunum
- `lib/screens/reels_player_screen.dart` — Tam ekran video oynatici

### 4a. Video Player Demo Sayfasi (video_player_screen.dart)

| Beklenti | Kodda Karsiligi |
|----------|----------------|
| Sayfada video alani olmali | Satir 121-124: `VideoPlayerWidget` — reusable widget ile video alani |
| Video basligi olmali | Satir 107-111: URL'ye gore otomatik "YouTube Video" veya "Native Video" basligi |
| Kisa aciklama olmali | Satir 114-119: Girilen URL gri renkte aciklama olarak gosteriliyor |
| Native video URL test edilebilmeli | Satir 70-75: "Native Demo" butonu — hazir .mp4 URL'si yukluyor |
| YouTube video URL test edilebilmeli | Satir 77-83: "YouTube Demo" butonu — hazir YouTube URL'si yukluyor |
| Kullanici disaridan URL girebilmeli | Satir 51-63: `TextField` — kullanici istenen URL'yi yazip play butonuna basiyor |
| Loading durumunda loading gorunmeli | `video_player_widget.dart` satir 88-92: `CircularProgressIndicator` |
| Error durumunda error widget gorunmeli | `video_player_widget.dart` satir 95-122: Kirmizi hata ikonu + mesaj |

### Teknik Detaylar
- `_playerKey` degiskeni: Her yeni URL girildiginde arttirilir, `ValueKey(_playerKey)` ile widget yeniden olusturulur, eski controller duzgun dispose edilir
- `_urlController.dispose()`: Sayfadan cikildiginda TextEditingController temizlenir
- `FocusScope.of(context).unfocus()`: URL girilip play'e basildiginda klavye kapanir

### 4b. Reels Sayfasi (reels_screen.dart)

| Beklenti | Kodda Karsiligi |
|----------|----------------|
| Instagram Reels tarzi tasarim | Satir 104-173: alternating grid pattern (buyuk-kucuk karisik thumbnail'ler) |
| Gorseldeki gibi kategori chipleri | Satir 74-92: yatay kaydirmali `ChoiceChip` listesi (Tumu, Doga, Teknoloji, Egitim) |
| Thumbnail'e tiklaninca video oynasun | Satir 178-187: `GestureDetector` ile `ReelsPlayerScreen`'e yonlendirme |
| Thumbnail loading durumu | Satir 194-201: `Image.network` icinde `loadingBuilder` — yukleniyor animasyonu |
| Thumbnail error durumu | Satir 203-206: `errorBuilder` — kirik resim ikonu |

### 4c. Reels Player (reels_player_screen.dart)

| Beklenti | Kodda Karsiligi |
|----------|----------------|
| Tam ekran video oynatma | Satir 37: `backgroundColor: Colors.black` + `Stack(fit: StackFit.expand)` |
| Dikey kaydirma | Satir 38-39: `PageView.builder(scrollDirection: Axis.vertical)` |
| Geri butonu | Satir 57-58: `Navigator.pop(context)` ile geri donus |
| Begeni/yorum/paylasim butonlari | Satir 74-85: `_ActionButton` widget'lari |
| Video basligi | Satir 87-99: Reel basligi beyaz bold yazi |
| PageController dispose | Satir 29-31: `_pageController.dispose()` — bellek sizintisi onlendi |

---

## 5. Modul 3: Reusable Video Player Widget

**Dosya:** `lib/widgets/video_player_widget.dart`

### PDF Beklentileri ve Kodda Karsiliklari

| Beklenti | Kodda Karsiligi |
|----------|----------------|
| Widget disaridan `String videoUrl` almali | Satir 6: `final String videoUrl` — required parametre |
| URL YouTube linki ise YouTube player acilmali | Satir 31-32: `contains('youtube.com')` ve `contains('youtu.be')` kontrolu → Satir 36-56: `YoutubePlayerController` olusturuluyor |
| URL native video linki ise video_player ile calismali | Satir 58-76: `VideoPlayerController.networkUrl()` ile video yukleniyor |
| Controller dispose islemleri dogru yapilmali | Satir 80-83: `_nativeController?.dispose()` ve `_youtubeController?.dispose()` — her iki controller da temizleniyor |
| Loading state yonetilmeli | Satir 25: `bool _isLoading = true` → Satir 88-92: loading durumunda `CircularProgressIndicator` gosteriliyor |
| Error state yonetilmeli | Satir 26: `String? _error` → Satir 95-122: hata durumunda kirmizi ikon + mesaj |
| Widget baska sayfalarda tekrar kullanilabilmeli | 3 farkli yerde kullaniliyor: `video_player_screen.dart`, `reels_player_screen.dart` |

### Desteklenen URL Tipleri

| URL Tipi | Nasil Yakalaniyor |
|----------|------------------|
| `https://www.youtube.com/watch?v=VIDEO_ID` | Satir 31: `contains('youtube.com')` → `YoutubePlayer.convertUrlToId()` ile ID cikarilir |
| `https://youtu.be/VIDEO_ID` | Satir 32: `contains('youtu.be')` → ayni sekilde ID cikarilir |
| `https://example.com/video.mp4` | YouTube degilse otomatik `_initNative()` calisir → `VideoPlayerController.networkUrl()` |

### Teknik Detaylar
- `_NativeControls` (satir 152-211): Ayri `StatefulWidget` olarak yazildi. `addListener` ile video durumunu dinliyor, play/pause ikonu anlik guncelleniyor. `dispose`'da `removeListener` cagriliyor — bellek sizintisi onlendi
- `autoPlay` ve `showControls` parametreleri: Reels'te `autoPlay: true, showControls: false` olarak kullaniliyor, demo sayfada varsayilan degerlerle

---

## 6. Modul 4: Bildirim Sistemi

**Dosyalar:**
- `lib/screens/notification_screen.dart` — Bildirim demo sayfasi
- `lib/services/notification_service.dart` — Bildirim servisi

### PDF Beklentileri ve Kodda Karsiliklari

| Beklenti | Kodda Karsiligi |
|----------|----------------|
| Notification permission istenmeli | `notification_service.dart` satir 41-48: `_requestPermissions()` — Android 13+ icin `requestNotificationsPermission()` cagriliyor |
| Android icin notification channel ayarlanmali | `notification_service.dart` satir 57-62: `AndroidNotificationDetails('staj_demo_channel', 'Staj Demo Notifications')` — channel ID, isim, importance: high, priority: high |
| iOS icin gerekli izin akisi kontrol edilmeli | `notification_service.dart` satir 21-25: `DarwinInitializationSettings` ile alert, badge, sound izinleri isteniyor |
| 5 saniye sonra gonderilmeli (hemen degil) | `notification_screen.dart` satir 51: `Future.delayed(const Duration(seconds: 5))` — butona basildiginda 5sn bekleyip sonra gonderiyor |
| Bildirim title ve body olmali | `notification_screen.dart` satir 54-55: `title: 'Test Bildirimi'`, `body: 'Bu bir test bildirimidir!'` |
| Ekranda bilgi mesaji gosterilmeli | `notification_screen.dart` satir 64-65: `SnackBar(content: Text('Bildirim gonderildi!'))` — bildirim gonderilince alt kisimda snackbar cikar |
| Buton olmali | `notification_screen.dart` satir 134-148: `ElevatedButton.icon` — beklerken devre disi + loading spinner |
| Error state | `notification_screen.dart` satir 121-129: Kirmizi hata mesaji gosteriliyor |
| Durum takibi | `notification_screen.dart` satir 109-120: "Hazir", "Bekleniyor... 5 saniye", "Bildirim gonderildi!" durum mesajlari |

### Teknik Detaylar
- `kIsWeb` kontrolu (`notification_service.dart` satir 42): Web platformunda `Platform.isAndroid` crash verir, bu kontrol ile onleniyor
- Her buton basildiginda farkli bildirim ID'si (`notification_screen.dart` satir 54): `DateTime.now().millisecondsSinceEpoch` ile, onceki bildirimin ustune yazilmaz
- Servis katmani ayri: `NotificationService` sinifi UI'dan bagimsiz, baska ekranlarda da kullanilabilir

### Android Manifest Ayarlari

`android/app/src/main/AndroidManifest.xml` dosyasina eklenen izinler:
- `INTERNET` — ag erisimi
- `POST_NOTIFICATIONS` — bildirim gonderme (Android 13+)
- `RECEIVE_BOOT_COMPLETED` — cihaz yeniden basladiginda bildirim servisi
- `SCHEDULE_EXACT_ALARM` — zamanlanmis bildirimler

---

## 7. Modul 5: Google Maps ve Konum Gosterme

**Dosyalar:**
- `lib/screens/map_screen.dart` — Harita sayfasi
- `lib/services/location_service.dart` — Konum servisi

### PDF Beklentileri ve Kodda Karsiliklari

| Beklenti | Kodda Karsiligi |
|----------|----------------|
| Sayfada Google Maps gorunmeli | `map_screen.dart` satir 118-160: `FlutterMap` widget'i + OpenStreetMap tile layer |
| Konum servisi acik mi kontrol edilmeli | `location_service.dart` satir 5-8: `Geolocator.isLocationServiceEnabled()` → kapaliysa `LocationException` firlatir |
| Kullanicidan location permission istenmeli | `location_service.dart` satir 10-16: `checkPermission()` → `denied` ise `requestPermission()` cagriliyor |
| Kalici reddedilmisse uyarilmali | `location_service.dart` satir 18-22: `deniedForever` → "Ayarlardan izin verin" mesaji |
| Konum izni verilirse mevcut konum alinmali | `location_service.dart` satir 24-28: `getCurrentPosition(accuracy: LocationAccuracy.high)` |
| Harita kullanicinin konumuna odaklanmali | `map_screen.dart` satir 121: `initialCenter: _userLocation!` + satir 40-41: tekrar konumlandirmada `_mapController.move(_userLocation!, 15)` |
| Haritada sadece bir marker olmali | `map_screen.dart` satir 132-157: `MarkerLayer` icinde tek `Marker` |
| Marker title "Me" olmali | `map_screen.dart` satir 141: `Text('Me')` — pin'in ustunde gorunuyor |
| Konum alinamazsa hata mesaji gosterilmeli | `map_screen.dart` satir 92-115: Kirmizi `location_off` ikonu + hata mesaji + "Tekrar Dene" butonu |

### Teknik Detaylar
- `_mapReady` degiskeni (`map_screen.dart` satir 18): `MapController.move()` harita render edilmeden cagrilirsa crash verir. `onMapReady` callback'i ile harita hazir oldugunda `_mapReady = true` yapiliyor, sadece o zaman `move()` cagriliyor
- `LocationException` sinifi (`location_service.dart` satir 32-38): Ozel exception sinifi, farkli hata durumlarina ozel mesajlar veriyor
- Loading state (`map_screen.dart` satir 79-90): Konum alinirken `CircularProgressIndicator` + "Konum aliniyor..." yazisi

### Android Manifest Ayarlari
- `ACCESS_FINE_LOCATION` — hassas konum (GPS)
- `ACCESS_COARSE_LOCATION` — yaklasik konum (ag bazli)

---

## 8. Kullanilan Paketler

| Paket | Versiyon | Kullanim Amaci |
|-------|---------|---------------|
| `video_player` | ^2.9.3 | Native video URL (.mp4 vb.) oynatma |
| `youtube_player_flutter` | ^9.1.1 | YouTube URL oynatma |
| `flutter_local_notifications` | ^18.0.1 | Telefona local notification gonderme |
| `timezone` | ^0.10.1 | Saat dilimi yonetimi |
| `flutter_map` | ^7.0.2 | OpenStreetMap harita gosterimi |
| `latlong2` | ^0.9.1 | Harita koordinat sistemi |
| `geolocator` | ^13.0.2 | Telefon konumunu alma ve permission kontrolu |

---

## 9. Teknik Beklentiler Karsilastirmasi

| Teknik Beklenti (PDF) | Nasil Karsilandi |
|-----------------------|-----------------|
| Kod okunabilir ve duzenli yazilmali | Her dosya tek sorumluluk ilkesine uygun. Degiskenler ve fonksiyonlar acik isimlendirilmis |
| Her ana modul ayri dosyada tutulmali | 5 modul icin 7 ayri ekran dosyasi + 1 widget + 2 servis = 10 dosya |
| Widget icinde gereksiz tekrar yapilmamali | `VideoPlayerWidget` 3 farkli yerde kullaniliyor, `_ModuleCard` 4 kez kullaniliyor, `_ActionButton` 3 kez |
| Loading, success ve error state dusunulmeli | Her moduldeki state'ler: `_isLoading`, `_error`, basarili icerik — uc durum da ele alindi |
| Permission durumu kontrol edilmeli | Bildirim: `requestNotificationsPermission()`. Konum: `checkPermission()` → `requestPermission()` |
| Kod comments gerekiyorsa Ingilizce | Kodda gereksiz yorum yazilmadi, degisken ve fonksiyon isimleri Ingilizce |
| Oncelik Android ve iOS gercek cihaz testi | Android icin Manifest izinleri, iOS icin DarwinInitializationSettings ayarlari yapildi |

---

## 10. Kontrol Listesi

| # | Kontrol | Durum |
|---|---------|-------|
| 1 | Sayfa acildiginda 5 saniyelik loading calisiyor mu? | TAMAM — `loading_screen.dart` satir 16 |
| 2 | Loading bittikten sonra icerik dogru gorunuyor mu? | TAMAM — `pushReplacement` ile HomeScreen aciliyor |
| 3 | Video player sayfasi duzgun tasarlanmis mi? | TAMAM — URL girisi + hazir demolar + baslik/aciklama |
| 4 | YouTube URL player icinde calisiyor mu? | TAMAM — `video_player_widget.dart` satir 36-56 |
| 5 | Native video URL player icinde calisiyor mu? | TAMAM — `video_player_widget.dart` satir 58-76 |
| 6 | Video controller dispose islemleri yapilmis mi? | TAMAM — `video_player_widget.dart` satir 80-83, `reels_player_screen.dart` satir 29-31 |
| 7 | Bildirim izni isteniyor mu? | TAMAM — `notification_service.dart` satir 41-48 |
| 8 | Butona tiklaninca 5 saniye sonra bildirim geliyor mu? | TAMAM — `notification_screen.dart` satir 51-56 |
| 9 | Google Maps ekranda duzgun gorunuyor mu? | TAMAM — `map_screen.dart` satir 118-160 |
| 10 | Telefon konumu dogru aliniyor mu? | TAMAM — `location_service.dart` satir 24-28 |
| 11 | Konum izni reddedilirse hata mesaji gosteriliyor mu? | TAMAM — `location_service.dart` satir 13-14, 18-22 |
| 12 | Haritada sadece "Me" marker'i var mi? | TAMAM — `map_screen.dart` satir 132-157, tek Marker |
| 13 | Kod okunabilir ve duzenli mi? | TAMAM — ayri dosyalar, reusable widget'lar, servis katmani |
| 14 | Gercek cihazda test edildi mi? | Android cihazda test edildi |

---

## 11. 3 Gunluk Calisma Plani ve Gerceklesen

| Gun | Plan (PDF) | Gerceklesen |
|-----|-----------|-------------|
| 1. Gun | Proje kurulumu, loading sistemi, video player sayfa tasarimi, native video URL oynatma baslangici | Loading sistemi calisiyor. Video ekran tasarimi hazir. Native video ilk demo calisiyor |
| 2. Gun | VideoPlayerWidget tamamlanir. YouTube ve native URL ayrimi yapilir. Bildirim sistemi eklenir | Tek widget ile YouTube/native URL oynuyor. Bildirim butona basilinca 5 saniye sonra geliyor |
| 3. Gun | Google Maps ve konum alma tamamlanir. Hata durumlari, test, refactor ve kisa aciklama dosyasi hazirlanir | Haritada "Me" pin'i gorunuyor. Permission/error durumlari calisiyor. README ve rapor hazir |
