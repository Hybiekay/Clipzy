import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:clipzy/constants.dart';
import 'package:clipzy/controllers/video_controller.dart';
import 'package:clipzy/views/screens/comment_screen.dart';
import 'package:clipzy/views/widgets/circle_animation.dart';
import 'package:clipzy/views/widgets/video_player_item.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoScreen extends StatefulWidget {
  VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final VideoController videoController = Get.put(VideoController());
  final Map<int, bool> profileToggles = {};

  void toggleProfile(int index) {
    setState(() {
      profileToggles[index] = !(profileToggles[index] ?? false);
    });
  }

  Widget buildProfile(String profilePhoto) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
        ],
      ),
      child: ClipOval(child: Image.network(profilePhoto, fit: BoxFit.cover)),
    );
  }

  Widget buildMusicAlbum(String profilePhoto) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Colors.grey, buttonColor]),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ClipOval(child: Image.network(profilePhoto, fit: BoxFit.cover)),
      ),
    );
  }

  Future<void> cacheNextVideos(int currentIndex, List videoList) async {
    final manager = DefaultCacheManager();
    for (
      int i = currentIndex + 1;
      i <= currentIndex + 5 && i < videoList.length;
      i++
    ) {
      final videoUrl = videoList[i].videoUrl.replaceAll("http://", "https://");
      await manager.downloadFile(videoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return PageView.builder(
          itemCount: videoController.videoList.length,
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            final data = videoController.videoList[index];
            cacheNextVideos(index, videoController.videoList);

            return Stack(
              children: [
                VideoPlayerItem(videoUrl: data.videoUrl),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 100,
                  right: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "@${data.username}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.caption,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            MaterialCommunityIcons.music_note,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              data.songName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// Right Side Buttons
                Positioned(
                  right: 10,
                  bottom: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /// Like
                      // if (toggledProfiles.contains(index)) ...[
                      //   InkWell(
                      //     onTap: () => videoController.likeVideo(data.id),
                      //     child: Column(
                      //       children: [
                      //         Icon(
                      //           data.likes.contains(authController.user.uid)
                      //               ? MaterialCommunityIcons.heart
                      //               : MaterialCommunityIcons.heart_outline,
                      //           color:
                      //               data.likes.contains(authController.user.uid)
                      //                   ? Colors.red
                      //                   : Colors.white,
                      //           size: 35,
                      //         ),
                      //         const SizedBox(height: 6),
                      //         Text(
                      //           data.likes.length.toString(),
                      //           style: const TextStyle(color: Colors.white),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      //   const SizedBox(height: 20),

                      //   /// Comment
                      //   InkWell(
                      //     onTap:
                      //         () => Navigator.of(context).push(
                      //           MaterialPageRoute(
                      //             builder:
                      //                 (context) => CommentScreen(id: data.id),
                      //           ),
                      //         ),
                      //     child: Column(
                      //       children: const [
                      //         Icon(
                      //           MaterialCommunityIcons.comment_text_outline,
                      //           size: 35,
                      //           color: Colors.white,
                      //         ),
                      //         SizedBox(height: 6),
                      //       ],
                      //     ),
                      //   ),
                      //   Text(
                      //     data.commentCount.toString(),
                      //     style: const TextStyle(color: Colors.white),
                      //   ),
                      //   const SizedBox(height: 20),

                      //   /// Share
                      //   InkWell(
                      //     onTap: () {
                      //       // TODO: implement share
                      //     },
                      //     child: Column(
                      //       children: [
                      //         const Icon(
                      //           MaterialCommunityIcons.share_variant,
                      //           size: 30,
                      //           color: Colors.white,
                      //         ),
                      //         const SizedBox(height: 6),
                      //         Text(
                      //           data.shareCount.toString(),
                      //           style: const TextStyle(color: Colors.white),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      //   const SizedBox(height: 20),

                      //   /// Rotating music
                      //   CircleAnimation(
                      //     child: buildMusicAlbum(data.profilePhoto),
                      //   ),
                      // ],
                      AnimatedSlide(
                        offset:
                            (profileToggles[index] ?? false)
                                ? Offset.zero
                                : const Offset(0, 0.2),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          opacity: (profileToggles[index] ?? false) ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => videoController.likeVideo(data.id),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      child: buildProfile(data.profilePhoto),
                                    ),
                                    const SizedBox(height: 20),

                                    Icon(
                                      data.likes.contains(
                                            authController.user.uid,
                                          )
                                          ? MaterialCommunityIcons.heart
                                          : MaterialCommunityIcons
                                              .heart_outline,
                                      color:
                                          data.likes.contains(
                                                authController.user.uid,
                                              )
                                              ? Colors.red
                                              : Colors.white,
                                      size: 35,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      data.likes.length.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              /// Comment
                              InkWell(
                                onTap:
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                CommentScreen(id: data.id),
                                      ),
                                    ),
                                child: Column(
                                  children: const [
                                    Icon(
                                      Ionicons
                                          .chatbubble_outline, // Messages icon

                                      size: 35,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 6),
                                  ],
                                ),
                              ),
                              Text(
                                data.commentCount.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 20),

                              /// Share
                              InkWell(
                                onTap: () {
                                  // TODO: implement share
                                },
                                child: Column(
                                  children: [
                                    const Icon(
                                      Ionicons.s,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      data.shareCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      /// Rotating music
                      GestureDetector(
                        onTap: () => toggleProfile(index),
                        child: CircleAnimation(
                          child: buildMusicAlbum(data.profilePhoto),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
