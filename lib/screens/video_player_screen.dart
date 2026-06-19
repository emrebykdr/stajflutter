import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? _currentUrl;
  int _playerKey = 0;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _playUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _currentUrl = url;
      _playerKey++;
    });
    FocusScope.of(context).unfocus();
  }

  void _playPreset(String url) {
    _urlController.text = url;
    setState(() {
      _currentUrl = url;
      _playerKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // URL giris alani
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Video URL girin',
              hintText: 'https://www.youtube.com/watch?v=... veya .mp4 linki',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: _playUrl,
              ),
            ),
            onSubmitted: (_) => _playUrl(),
          ),
          const SizedBox(height: 12),

          // Hazir URL butonlari
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.videocam, size: 18),
                label: const Text('Native Demo'),
                onPressed: () => _playPreset(
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
                ),
              ),
              ActionChip(
                avatar: const Icon(Icons.play_circle, size: 18),
                label: const Text('YouTube Demo'),
                onPressed: () => _playPreset(
                  'https://www.youtube.com/watch?v=YMx8Bbev6T4',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Video player alani
          if (_currentUrl == null)
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'URL girin veya hazir demolardan birini secin',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Text(
              _currentUrl!.contains('youtube.com') || _currentUrl!.contains('youtu.be')
                  ? 'YouTube Video'
                  : 'Native Video',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _currentUrl!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            VideoPlayerWidget(
              key: ValueKey(_playerKey),
              videoUrl: _currentUrl!,
            ),
          ],
        ],
      ),
    );
  }
}
