import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clipzy/controllers/upload_video_controller.dart';
import 'package:clipzy/views/widgets/text_input_field.dart';
import 'package:video_player/video_player.dart';

class ConfirmScreen extends StatefulWidget {
  final File videoFile;
  final String videoPath;

  const ConfirmScreen({
    super.key,
    required this.videoFile,
    required this.videoPath,
  });

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  late VideoPlayerController _controller;
  final TextEditingController _songController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();

  final UploadVideoController _uploadVideoController = Get.put(
    UploadVideoController(),
  );

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {}); // Refresh once video is initialized
        _controller.play();
        _controller.setVolume(1);
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _controller.value.isInitialized
              ? Stack(
                children: [
                  /// Fullscreen Video Player
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                  if (_uploadVideoController.isUploading.value) ...[
                    Positioned(
                      top: 30,
                      child: LinearProgressIndicator(
                        value: _uploadVideoController.uploadProgress.value,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.purpleAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_uploadVideoController.uploadProgress.value * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                  ],

                  /// Overlay with gradient and form
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black87,
                            Colors.black,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextInputField(
                            controller: _songController,
                            labelText: 'Song Name',
                            icon: Icons.music_note,
                          ),
                          const SizedBox(height: 12),
                          TextInputField(
                            controller: _captionController,
                            labelText: 'Caption',
                            icon: Icons.closed_caption,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_songController.text.isEmpty ||
                                    _captionController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill in all fields',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                _uploadVideoController.uploadVideo(
                                  _songController.text.trim(),
                                  _captionController.text.trim(),
                                  widget.videoPath,
                                  widget.videoFile,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purpleAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Share!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
    );
  }
}
