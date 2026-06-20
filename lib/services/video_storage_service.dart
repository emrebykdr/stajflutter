import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VideoItem {
  final String videoUrl;
  final String title;

  const VideoItem({required this.videoUrl, required this.title});

  bool get isYoutube =>
      videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be');

  String? get youtubeId {
    if (!isYoutube) return null;
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return uri.queryParameters['v'];
  }

  String get thumbnailUrl {
    final id = youtubeId;
    if (id != null) return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    return '';
  }

  Map<String, String> toMap() => {'url': videoUrl, 'title': title};

  factory VideoItem.fromMap(Map<String, dynamic> map) =>
      VideoItem(videoUrl: map['url'] as String, title: map['title'] as String);
}

const defaultVideos = [
  VideoItem(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    title: 'Kelebek',
  ),
  VideoItem(
    videoUrl: 'https://www.youtube.com/watch?v=YMx8Bbev6T4',
    title: 'Flutter Demo',
  ),
  VideoItem(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    title: 'Arı',
  ),
  VideoItem(
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    title: 'Never Gonna Give You Up',
  ),
  VideoItem(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    title: 'Doğa',
  ),
  VideoItem(
    videoUrl: 'https://www.youtube.com/watch?v=9bZkp7q19f0',
    title: 'Gangnam Style',
  ),
  VideoItem(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    title: 'Bahçe',
  ),
  VideoItem(
    videoUrl: 'https://www.youtube.com/watch?v=jNQXAC9IVRw',
    title: 'İlk YouTube Videosu',
  ),
  VideoItem(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    title: 'Orman',
  ),
];

class VideoStorageService {
  static const _key = 'saved_videos';

  static Future<List<VideoItem>> getVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);
    if (jsonList == null) return List.from(defaultVideos);
    return jsonList
        .map((e) => VideoItem.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveVideos(List<VideoItem> videos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        videos.map((v) => jsonEncode(v.toMap())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<void> addVideo(VideoItem video) async {
    final videos = await getVideos();
    videos.add(video);
    await saveVideos(videos);
  }

  static Future<void> removeVideo(int index) async {
    final videos = await getVideos();
    if (index >= 0 && index < videos.length) {
      videos.removeAt(index);
      await saveVideos(videos);
    }
  }

  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
