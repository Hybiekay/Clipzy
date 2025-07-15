import 'dart:typed_data';
import 'dart:io';
import 'package:clipzy/views/screens/confirm_screen.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceVideoGalleryScreen extends StatefulWidget {
  const DeviceVideoGalleryScreen({Key? key}) : super(key: key);

  @override
  State<DeviceVideoGalleryScreen> createState() =>
      _DeviceVideoGalleryScreenState();
}

class _DeviceVideoGalleryScreenState extends State<DeviceVideoGalleryScreen> {
  List<AssetEntity> videos = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> checkPermissions() async {
    if (await Permission.videos.request().isGranted) {
      // Permission granted
    } else {
      openAppSettings(); // Or handle retry
    }
  }

  Future<void> _fetchVideos() async {
    checkPermissions();
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Request permissions
    final PermissionState permissionState =
        await PhotoManager.requestPermissionExtend();

    if (!mounted) return;
    print('Permission state: $permissionState');
    if (permissionState.isAuth) {
      try {
        // Fetch all video assets from all albums
        List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
          type: RequestType.video,
        );
        List<AssetEntity> allVideos = [];

        for (var path in paths) {
          final videoList = await path.getAssetListPaged(page: 0, size: 50);
          allVideos.addAll(videoList);
        }

        if (!mounted) return;

        setState(() {
          videos = allVideos;
          isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Failed to load videos: $e';
          isLoading = false;
        });
      }
    } else if (permissionState == PermissionState.limited) {
      // Handle limited access (iOS-specific, e.g., user selected specific photos)
      setState(() {
        isLoading = false;
        errorMessage =
            'Limited access granted. Some videos may not be available.';
      });
      // Optionally, still try to fetch available videos
      try {
        List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
          type: RequestType.video,
        );
        List<AssetEntity> allVideos = [];
        for (var path in paths) {
          final videoList = await path.getAssetListPaged(page: 0, size: 50);
          allVideos.addAll(videoList);
        }
        if (!mounted) return;
        setState(() {
          videos = allVideos;
          isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Failed to load videos: $e';
          isLoading = false;
        });
      }
    } else {
      // Permission denied
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage =
            'Permission denied. Please grant access to media in settings.';
      });

      // Show dialog to guide user
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'Please grant media access in your device settings to view videos.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await PhotoManager.openSetting();
                    // Recheck permissions after returning from settings
                    if (!mounted) return;
                    await _fetchVideos();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic thumbnail size based on screen width
    final double thumbnailSize = MediaQuery.of(context).size.width / 3 - 16;

    return Scaffold(
      appBar: AppBar(title: const Text('Device Videos')),
      backgroundColor: Colors.black,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchVideos,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : videos.isEmpty
              ? const Center(
                child: Text(
                  'No videos found',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];

                  return FutureBuilder<Uint8List?>(
                    future: video.thumbnailDataWithSize(
                      ThumbnailSize(
                        thumbnailSize.toInt(),
                        thumbnailSize.toInt(),
                      ),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data != null) {
                        return GestureDetector(
                          onTap: () async {
                            try {
                              final File? file = await video.file;
                              if (file != null && mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ConfirmScreen(
                                          videoFile: file,
                                          videoPath: file.path,
                                        ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to load video'),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                          ),
                        );
                      }

                      return Container(
                        color: Colors.grey[900],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  );
                },
              ),
    );
  }
}
