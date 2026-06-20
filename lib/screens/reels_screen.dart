import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/video_storage_service.dart';
import 'reels_player_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  int _selectedCategory = 0;
  List<VideoItem> _videos = [];
  bool _loading = true;

  final _categories = ['Tümü', 'Native', 'YouTube'];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final videos = await VideoStorageService.getVideos();
    if (mounted) setState(() { _videos = videos; _loading = false; });
  }

  List<VideoItem> get _filteredVideos {
    if (_selectedCategory == 1) return _videos.where((v) => !v.isYoutube).toList();
    if (_selectedCategory == 2) return _videos.where((v) => v.isYoutube).toList();
    return _videos;
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
              decoration: const InputDecoration(
                labelText: 'Baslik',
                border: OutlineInputBorder(),
              ),
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Iptal'),
          ),
          FilledButton(
            onPressed: () async {
              final url = urlCtrl.text.trim();
              final title = titleCtrl.text.trim();
              if (url.isEmpty || title.isEmpty) return;
              await VideoStorageService.addVideo(
                VideoItem(videoUrl: url, title: title),
              );
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Iptal'),
          ),
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
        title: const Text('Reels'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Video Ekle',
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(_categories[index]),
                              selected: _selectedCategory == index,
                              onSelected: (_) => setState(() => _selectedCategory = index),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _filteredVideos.isEmpty
                          ? const Center(child: Text('Video bulunamadi'))
                          : SingleChildScrollView(child: _buildGrid()),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGrid() {
    final reels = _filteredVideos;
    const double gap = 2;
    final List<Widget> rows = [];
    int i = 0;
    bool patternA = true;

    while (i < reels.length) {
      if (patternA) {
        final topLeft = i < reels.length ? reels[i] : null;
        final bottomLeft = i + 1 < reels.length ? reels[i + 1] : null;
        final right = i + 2 < reels.length ? reels[i + 2] : null;
        rows.add(SizedBox(
          height: 260,
          child: Row(children: [
            Expanded(child: Column(children: [
              Expanded(child: _buildThumbnail(topLeft, reels)),
              const SizedBox(height: gap),
              Expanded(child: _buildThumbnail(bottomLeft, reels)),
            ])),
            const SizedBox(width: gap),
            Expanded(child: _buildThumbnail(right, reels)),
          ]),
        ));
        i += 3;
      } else {
        final left = i < reels.length ? reels[i] : null;
        final topRight = i + 1 < reels.length ? reels[i + 1] : null;
        final bottomRight = i + 2 < reels.length ? reels[i + 2] : null;
        rows.add(SizedBox(
          height: 260,
          child: Row(children: [
            Expanded(child: _buildThumbnail(left, reels)),
            const SizedBox(width: gap),
            Expanded(child: Column(children: [
              Expanded(child: _buildThumbnail(topRight, reels)),
              const SizedBox(height: gap),
              Expanded(child: _buildThumbnail(bottomRight, reels)),
            ])),
          ]),
        ));
        i += 3;
      }
      rows.add(const SizedBox(height: 2));
      patternA = !patternA;
    }

    return Column(children: rows);
  }

  Widget _buildThumbnail(VideoItem? video, List<VideoItem> videoList) {
    if (video == null) return const SizedBox.shrink();
    final globalIndex = _videos.indexOf(video);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReelsPlayerScreen(
            videos: videoList,
            initialIndex: videoList.indexOf(video),
          ),
        ),
      ),
      onLongPress: () => _confirmDelete(globalIndex),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (video.isYoutube)
            Image.network(
              video.thumbnailUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
              errorBuilder: (context, error, stack) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            )
          else
            _NativeVideoThumbnail(videoUrl: video.videoUrl),
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
            left: 8, bottom: 8, right: 8,
            child: Row(children: [
              Icon(
                video.isYoutube ? Icons.play_circle : Icons.videocam,
                color: Colors.white, size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  video.title,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
          if (video.isYoutube)
            Positioned(
              top: 6, right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text('YT',
                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
