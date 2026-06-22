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
  bool _overlayVisible = false;
  int? _seekIndicator;
  int _seekAnimKey = 0;

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

  void _seekRelative(int seconds) {
    if (_nativeController == null) return;
    final pos = _nativeController!.value.position;
    final dur = _nativeController!.value.duration;
    var newPos = pos + Duration(seconds: seconds);
    if (newPos < Duration.zero) newPos = Duration.zero;
    if (newPos > dur) newPos = dur;
    _nativeController!.seekTo(newPos);

    setState(() {
      _seekIndicator = seconds;
      _seekAnimKey++;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _seekIndicator = null);
    });
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(_nativeController!),
            if (widget.showControls)
              _overlayVisible
                  ? _NativeOverlayControls(
                      controller: _nativeController!,
                      onHide: () => setState(() => _overlayVisible = false),
                      onSeek: _seekRelative,
                    )
                  : _VideoTapLayer(
                      onTap: () => setState(() => _overlayVisible = true),
                      onSeek: _seekRelative,
                    ),
            if (_seekIndicator != null)
              IgnorePointer(
                child: Align(
                  alignment: _seekIndicator! < 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: _SeekIndicator(
                    key: ValueKey(_seekAnimKey),
                    seconds: _seekIndicator!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SeekIndicator extends StatefulWidget {
  final int seconds;
  const _SeekIndicator({super.key, required this.seconds});

  @override
  State<_SeekIndicator> createState() => _SeekIndicatorState();
}

class _SeekIndicatorState extends State<_SeekIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_anim);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isForward = widget.seconds > 0;
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 110,
        height: 110,
        margin: EdgeInsets.only(
          left: isForward ? 0 : 20,
          right: isForward ? 20 : 0,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isForward ? Icons.fast_forward : Icons.fast_rewind,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.seconds.abs()} saniye',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoTapLayer extends StatelessWidget {
  final VoidCallback onTap;
  final void Function(int seconds) onSeek;

  const _VideoTapLayer({required this.onTap, required this.onSeek});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            onDoubleTap: () => onSeek(-5),
            child: const SizedBox.expand(),
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            onDoubleTap: () => onSeek(5),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _NativeOverlayControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onHide;
  final void Function(int seconds) onSeek;

  const _NativeOverlayControls({
    required this.controller,
    required this.onHide,
    required this.onSeek,
  });

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

    return Stack(
      fit: StackFit.expand,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onHide,
                onDoubleTap: () => widget.onSeek(-5),
                child: Container(color: Colors.black.withValues(alpha: 0.4)),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onHide,
                onDoubleTap: () => widget.onSeek(5),
                child: Container(color: Colors.black.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ),
        Center(
          child: IconButton(
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
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: 4,
          child: Row(
            children: [
              Text(_fmt(pos),
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 3,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
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
              Text(_fmt(dur),
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
