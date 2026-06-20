import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt_mobile;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt_web;

String? extractYoutubeId(String url) {
  final id = yt_mobile.YoutubePlayer.convertUrlToId(url);
  if (id != null) return id;
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }
  return uri.queryParameters['v'];
}

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
  yt_mobile.YoutubePlayerController? _mobileYtController;
  yt_web.YoutubePlayerController? _webYtController;
  bool _isYoutube = false;
  bool _isLoading = true;
  String? _error;
  bool _overlayVisible = true;

  @override
  void initState() {
    super.initState();
    _isYoutube = widget.videoUrl.contains('youtube.com') ||
        widget.videoUrl.contains('youtu.be');
    _isYoutube ? _initYoutube() : _initNative();
  }

  void _initYoutube() {
    final videoId = extractYoutubeId(widget.videoUrl);
    if (videoId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Gecersiz YouTube URL';
        });
      }
      return;
    }

    if (kIsWeb) {
      _webYtController = yt_web.YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: widget.autoPlay,
        params: const yt_web.YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          playsInline: true,
        ),
      );
    } else {
      _mobileYtController = yt_mobile.YoutubePlayerController(
        initialVideoId: videoId,
        flags: yt_mobile.YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          mute: false,
        ),
      );
    }
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
    _mobileYtController?.dispose();
    _webYtController?.close();
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
        child: kIsWeb
            ? yt_web.YoutubePlayer(controller: _webYtController!)
            : yt_mobile.YoutubePlayer(
                controller: _mobileYtController!,
                showVideoProgressIndicator: true,
              ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: _nativeController!.value.aspectRatio,
        child: GestureDetector(
          onTap: () {
            if (widget.showControls) {
              setState(() => _overlayVisible = !_overlayVisible);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayer(_nativeController!),
              if (widget.showControls)
                AnimatedOpacity(
                  opacity: _overlayVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_overlayVisible,
                    child: _NativeOverlayControls(
                      controller: _nativeController!,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NativeOverlayControls extends StatefulWidget {
  final VideoPlayerController controller;

  const _NativeOverlayControls({required this.controller});

  @override
  State<_NativeOverlayControls> createState() => _NativeOverlayControlsState();
}

class _NativeOverlayControlsState extends State<_NativeOverlayControls> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) return '${d.inHours}:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.controller.value.position;
    final dur = widget.controller.value.duration;

    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Column(
        children: [
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () {
                  final np = pos - const Duration(seconds: 10);
                  widget.controller
                      .seekTo(np < Duration.zero ? Duration.zero : np);
                },
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 56,
                icon: Icon(
                  widget.controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                ),
                onPressed: () {
                  widget.controller.value.isPlaying
                      ? widget.controller.pause()
                      : widget.controller.play();
                },
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () {
                  final np = pos + const Duration(seconds: 10);
                  widget.controller.seekTo(np > dur ? dur : np);
                },
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
            child: Row(
              children: [
                Text(
                  _fmt(pos),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Expanded(
                  child: SliderTheme(
                    data: const SliderThemeData(
                      trackHeight: 3,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white30,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: dur.inMilliseconds > 0
                          ? pos.inMilliseconds
                              .toDouble()
                              .clamp(0, dur.inMilliseconds.toDouble())
                          : 0,
                      max: dur.inMilliseconds > 0
                          ? dur.inMilliseconds.toDouble()
                          : 1,
                      onChanged: (v) {
                        widget.controller
                            .seekTo(Duration(milliseconds: v.toInt()));
                      },
                    ),
                  ),
                ),
                Text(
                  _fmt(dur),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
