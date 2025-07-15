import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({super.key, required this.videoUrl});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadCachedVideo();
  }

  Future<void> _loadCachedVideo() async {
    final url = widget.videoUrl.replaceAll("http://", "https://");
    final cacheManager = DefaultCacheManager();

    try {
      // Check if file is already cached
      final fileInfo = await cacheManager.getFileFromCache(url);
      if (fileInfo != null && fileInfo.file.existsSync()) {
        // Use cached file
        _controller = VideoPlayerController.file(fileInfo.file);
      } else {
        // Fallback to network
        _controller = VideoPlayerController.network(url);
      }

      await _controller.initialize();
      setState(() {
        _isInitialized = true;
        _controller.play();
        _controller.setLooping(true);
        _controller.setVolume(1);
      });
    } catch (e) {
      print("Video loading error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    if (!_isInitialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _togglePlayback,
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
        child:
            _isInitialized
                ? Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if (!_isPlaying)
                      const Icon(
                        Icons.play_arrow_rounded,
                        size: 80,
                        color: Colors.white70,
                      ),
                  ],
                )
                : const Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                ),
      ),
    );
  }
}
