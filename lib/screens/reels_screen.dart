import 'package:flutter/material.dart';
import 'reels_player_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  int _selectedCategory = 0;

  final _categories = ['Tümü', 'Doğa', 'Teknoloji', 'Eğitim'];

  final _reels = const [
    ReelData(
      thumbnailUrl: 'https://picsum.photos/seed/r1/400/400',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      title: 'Butterfly',
    ),
    ReelData(
      thumbnailUrl: 'https://picsum.photos/seed/r2/400/600',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      title: 'Bee',
    ),
    ReelData(
      thumbnailUrl: 'https://picsum.photos/seed/r3/400/400',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      title: 'Nature',
    ),
    ReelData(
      thumbnailUrl: 'https://picsum.photos/seed/r4/400/600',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      title: 'Garden',
    ),
    ReelData(
      thumbnailUrl: 'https://picsum.photos/seed/r5/400/400',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      title: 'Sky',
    ),
    ReelData(
      thumbnailUrl: 'https://picsum.photos/seed/r6/400/400',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      title: 'Ocean',
    ),
    ReelData(
      thumbnailUrl: 'https://picsum.photos/seed/r7/400/400',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      title: 'Forest',
    ),
    ReelData(
      thumbnailUrl: 'https://picsum.photos/seed/r8/400/600',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      title: 'Mountain',
    ),
    ReelData(
      thumbnailUrl: 'https://picsum.photos/seed/r9/400/400',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      title: 'River',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reels'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Kategori chipleri
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
          // Grid
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
    const double gap = 2;
    final List<Widget> rows = [];

    int i = 0;
    bool patternA = true;

    while (i < _reels.length) {
      if (patternA) {
        // Pattern A: sol 2 küçük kare | sağ 1 büyük dikdörtgen
        final topLeft = i < _reels.length ? _reels[i] : null;
        final bottomLeft = i + 1 < _reels.length ? _reels[i + 1] : null;
        final right = i + 2 < _reels.length ? _reels[i + 2] : null;

        rows.add(
          SizedBox(
            height: 260,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _buildThumbnail(topLeft)),
                      const SizedBox(height: gap),
                      Expanded(child: _buildThumbnail(bottomLeft)),
                    ],
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(child: _buildThumbnail(right)),
              ],
            ),
          ),
        );
        i += 3;
      } else {
        // Pattern B: sol 1 büyük dikdörtgen | sağ 2 küçük kare
        final left = i < _reels.length ? _reels[i] : null;
        final topRight = i + 1 < _reels.length ? _reels[i + 1] : null;
        final bottomRight = i + 2 < _reels.length ? _reels[i + 2] : null;

        rows.add(
          SizedBox(
            height: 260,
            child: Row(
              children: [
                Expanded(child: _buildThumbnail(left)),
                const SizedBox(width: gap),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _buildThumbnail(topRight)),
                      const SizedBox(height: gap),
                      Expanded(child: _buildThumbnail(bottomRight)),
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

  Widget _buildThumbnail(ReelData? reel) {
    if (reel == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReelsPlayerScreen(
            reels: _reels,
            initialIndex: _reels.indexOf(reel),
          ),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
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
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  reel.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReelData {
  final String thumbnailUrl;
  final String videoUrl;
  final String title;

  const ReelData({
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.title,
  });
}
