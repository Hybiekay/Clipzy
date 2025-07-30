import 'dart:typed_data';
import 'package:clipzy/views/screens/confirm_screen.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceVideoGalleryScreen extends StatefulWidget {
  const DeviceVideoGalleryScreen({super.key});

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

  Future<void> _fetchVideos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    if (!mounted) return;

    if (await Permission.videos.request().isGranted) {
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

        /// 👇 Show the bottom sheet once loading is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showBottomSheet(context);
        });
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to load videos: $e';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Permission denied. Please grant access in settings.';
      });
      await PhotoManager.openSetting();
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      context: context,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.7,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Open Video Camera'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        videos.isEmpty
                            ? const Center(
                              child: Text(
                                'No videos found',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                            : GridView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: videos.length,
                              itemBuilder: (context, index) {
                                final video = videos[index];
                                return FutureBuilder<Uint8List?>(
                                  future: video.thumbnailDataWithSize(
                                    const ThumbnailSize(200, 200),
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData &&
                                        snapshot.data != null) {
                                      return GestureDetector(
                                        onTap: () async {
                                          final file = await video.file;
                                          if (file != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => ConfirmScreen(
                                                      videoFile: file,
                                                      videoPath: file.path,
                                                    ),
                                              ),
                                            );
                                          }
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // title: const Text('Pick a Video'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => _showBottomSheet(context),
          ),
        ],
      ),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pick Your Video',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The best app to receive and engage your content creatively.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
      ),
    );
  }
}
