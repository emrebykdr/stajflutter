import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';
import 'reels_screen.dart';

class ReelsPlayerScreen extends StatefulWidget {
  final List<ReelData> reels;
  final int initialIndex;

  const ReelsPlayerScreen({
    super.key,
    required this.reels,
    required this.initialIndex,
  });

  @override
  State<ReelsPlayerScreen> createState() => _ReelsPlayerScreenState();
}

class _ReelsPlayerScreenState extends State<ReelsPlayerScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.reels.length,
        itemBuilder: (context, index) {
          final reel = widget.reels[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayerWidget(
                videoUrl: reel.videoUrl,
                autoPlay: true,
                showControls: false,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Reels',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 120,
                child: Column(
                  children: [
                    _ActionButton(icon: Icons.favorite_border, label: '1.2K'),
                    const SizedBox(height: 20),
                    _ActionButton(icon: Icons.comment_outlined, label: '48'),
                    const SizedBox(height: 20),
                    _ActionButton(icon: Icons.send_outlined, label: 'Share'),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 72,
                bottom: 40,
                child: Text(
                  reel.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
