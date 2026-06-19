import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool showControls;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.showControls = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _nativeController;
  YoutubePlayerController? _youtubeController;
  bool _isYoutube = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isYoutube = widget.videoUrl.contains('youtube.com') ||
        widget.videoUrl.contains('youtu.be');
    _isYoutube ? _initYoutube() : _initNative();
  }

  void _initYoutube() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Gecersiz YouTube URL';
        });
      }
      return;
    }

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: false,
      ),
    );
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _initNative() async {
    try {
      _nativeController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _nativeController!.initialize();
      if (widget.autoPlay) {
        await _nativeController!.play();
        await _nativeController!.setLooping(true);
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Video yuklenemedi: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _nativeController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isYoutube) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: widget.showControls,
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: _nativeController!.value.aspectRatio,
            child: VideoPlayer(_nativeController!),
          ),
        ),
        if (widget.showControls) ...[
          const SizedBox(height: 8),
          _NativeControls(controller: _nativeController!),
        ],
      ],
    );
  }
}

class _NativeControls extends StatefulWidget {
  final VideoPlayerController controller;

  const _NativeControls({required this.controller});

  @override
  State<_NativeControls> createState() => _NativeControlsState();
}

class _NativeControlsState extends State<_NativeControls> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onVideoChanged);
  }

  void _onVideoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 36,
          icon: Icon(
            widget.controller.value.isPlaying
                ? Icons.pause_circle
                : Icons.play_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            widget.controller.value.isPlaying
                ? widget.controller.pause()
                : widget.controller.play();
          },
        ),
        IconButton(
          iconSize: 36,
          icon: Icon(
            Icons.replay,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            widget.controller.seekTo(Duration.zero);
            widget.controller.play();
          },
        ),
      ],
    );
  }
}
