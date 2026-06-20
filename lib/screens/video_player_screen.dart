import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';
import '../services/video_storage_service.dart';
import 'reels_screen.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? _currentUrl;
  int _playerKey = 0;
  List<VideoItem> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final videos = await VideoStorageService.getVideos();
    if (mounted) setState(() { _videos = videos; _loading = false; });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _playUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() { _currentUrl = url; _playerKey++; });
    FocusScope.of(context).unfocus();
  }

  void _playPreset(String url) {
    _urlController.text = url;
    setState(() { _currentUrl = url; _playerKey++; });
  }

  void _showAddDialog() {
    final urlCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Video Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Baslik', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'Video URL',
                hintText: 'YouTube veya .mp4 linki',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Iptal')),
          FilledButton(
            onPressed: () async {
              final url = urlCtrl.text.trim();
              final title = titleCtrl.text.trim();
              if (url.isEmpty || title.isEmpty) return;
              await VideoStorageService.addVideo(VideoItem(videoUrl: url, title: title));
              if (ctx.mounted) Navigator.pop(ctx);
              _loadVideos();
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
    final video = _videos[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Video Sil'),
        content: Text('"${video.title}" silinsin mi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Iptal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await VideoStorageService.removeVideo(index);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadVideos();
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.add), tooltip: 'Video Ekle', onPressed: _showAddDialog),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Video URL girin',
                  hintText: 'https://www.youtube.com/watch?v=... veya .mp4 linki',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: const Icon(Icons.play_arrow), onPressed: _playUrl),
                ),
                onSubmitted: (_) => _playUrl(),
              ),
              const SizedBox(height: 12),
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
                    onPressed: () => _playPreset('https://www.youtube.com/watch?v=YMx8Bbev6T4'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_currentUrl == null)
                const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('URL girin veya asagidan bir video secin',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else ...[
                Text(
                  _currentUrl!.contains('youtube.com') || _currentUrl!.contains('youtu.be')
                      ? 'YouTube Video' : 'Native Video',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(_currentUrl!, style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                VideoPlayerWidget(key: ValueKey(_playerKey), videoUrl: _currentUrl!),
              ],
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tüm Videolar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const ReelsScreen()),
                    ),
                    icon: const Icon(Icons.video_library, size: 18),
                    label: const Text('Reels\'de Gör'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                ..._videos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final video = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 80, height: 50,
                          child: video.isYoutube
                              ? Image.network(video.thumbnailUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.play_circle, color: Colors.grey),
                                  ))
                              : Container(
                                  color: Colors.grey.shade800,
                                  child: const Icon(Icons.videocam, color: Colors.white, size: 24),
                                ),
                        ),
                      ),
                      title: Text(video.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(video.isYoutube ? 'YouTube' : 'Native Video',
                          style: TextStyle(fontSize: 12,
                              color: video.isYoutube ? Colors.red : Colors.green.shade700)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () => _playPreset(video.videoUrl),
                            tooltip: 'Oynat',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDelete(index),
                            tooltip: 'Sil',
                            color: Colors.red.shade300,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
