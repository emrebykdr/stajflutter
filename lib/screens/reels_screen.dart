import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'reels_player_screen.dart';

class ReelData {
  final String videoUrl;
  final String title;

  const ReelData({
    required this.videoUrl,
    required this.title,
  });

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
}

const allVideos = [
  ReelData(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    title: 'Kelebek',
  ),
  ReelData(
    videoUrl: 'https://www.youtube.com/watch?v=YMx8Bbev6T4',
    title: 'Flutter Demo',
  ),
  ReelData(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    title: 'Arı',
  ),
  ReelData(
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    title: 'Never Gonna Give You Up',
  ),
  ReelData(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    title: 'Doğa',
  ),
  ReelData(
    videoUrl: 'https://www.youtube.com/watch?v=9bZkp7q19f0',
    title: 'Gangnam Style',
  ),
  ReelData(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    title: 'Bahçe',
  ),
  ReelData(
    videoUrl: 'https://www.youtube.com/watch?v=jNQXAC9IVRw',
    title: 'İlk YouTube Videosu',
  ),
  ReelData(
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    title: 'Orman',
  ),
];

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  int _selectedCategory = 0;

  final _categories = ['Tümü', 'Native', 'YouTube'];

  List<ReelData> get _filteredReels {
    if (_selectedCategory == 1) {
      return allVideos.where((r) => !r.isYoutube).toList();
    } else if (_selectedCategory == 2) {
      return allVideos.where((r) => r.isYoutube).toList();
    }
    return allVideos.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reels'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final selected = _selectedCategory == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = index),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _buildGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final reels = _filteredReels;
    const double gap = 2;
    final List<Widget> rows = [];

    int i = 0;
    bool patternA = true;

    while (i < reels.length) {
      if (patternA) {
        final topLeft = i < reels.length ? reels[i] : null;
        final bottomLeft = i + 1 < reels.length ? reels[i + 1] : null;
        final right = i + 2 < reels.length ? reels[i + 2] : null;

        rows.add(
          SizedBox(
            height: 260,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _buildThumbnail(topLeft, reels)),
                      const SizedBox(height: gap),
                      Expanded(child: _buildThumbnail(bottomLeft, reels)),
                    ],
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(child: _buildThumbnail(right, reels)),
              ],
            ),
          ),
        );
        i += 3;
      } else {
        final left = i < reels.length ? reels[i] : null;
        final topRight = i + 1 < reels.length ? reels[i + 1] : null;
        final bottomRight = i + 2 < reels.length ? reels[i + 2] : null;

        rows.add(
          SizedBox(
            height: 260,
            child: Row(
              children: [
                Expanded(child: _buildThumbnail(left, reels)),
                const SizedBox(width: gap),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _buildThumbnail(topRight, reels)),
                      const SizedBox(height: gap),
                      Expanded(child: _buildThumbnail(bottomRight, reels)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        i += 3;
      }

      rows.add(const SizedBox(height: 2));
      patternA = !patternA;
    }

    return Column(children: rows);
  }

  Widget _buildThumbnail(ReelData? reel, List<ReelData> reelsList) {
    if (reel == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReelsPlayerScreen(
            reels: reelsList,
            initialIndex: reelsList.indexOf(reel),
          ),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (reel.isYoutube)
            Image.network(
              reel.thumbnailUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stack) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            )
          else
            _NativeVideoThumbnail(videoUrl: reel.videoUrl),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                Icon(
                  reel.isYoutube ? Icons.play_circle : Icons.videocam,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    reel.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (reel.isYoutube)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'YT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NativeVideoThumbnail extends StatefulWidget {
  final String videoUrl;
  const _NativeVideoThumbnail({required this.videoUrl});

  @override
  State<_NativeVideoThumbnail> createState() => _NativeVideoThumbnailState();
}

class _NativeVideoThumbnailState extends State<_NativeVideoThumbnail> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller.initialize().then((_) {
      if (mounted) setState(() => _initialized = true);
    }).catchError((_) {
      if (mounted) setState(() => _hasError = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.videocam_off, color: Colors.grey)),
      );
    }

    if (!_initialized) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
