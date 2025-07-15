import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clipzy/constants.dart';
import 'package:clipzy/controllers/profile_controller.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    profileController.updateUserId(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        if (controller.user.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Feather.user_plus, color: Colors.white),
              onPressed: () {},
            ),
            actions: [
              IconButton(
                icon: const Icon(Feather.more_vertical, color: Colors.white),
                onPressed: () {},
              ),
            ],
            title: Text(
              controller.user['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // Profile picture
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: CachedNetworkImageProvider(
                          controller.user['profilePhoto'],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Stats
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatWithIcon(
                              Feather.user_check,
                              'Following',
                              controller.user['following'],
                            ),
                            _buildStatWithIcon(
                              Feather.users,
                              'Followers',
                              controller.user['followers'],
                            ),
                            _buildStatWithIcon(
                              Feather.heart,
                              'Likes',
                              controller.user['likes'],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Follow / Sign Out Button
                  SizedBox(
                    width: 160,
                    height: 45,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        widget.uid == authController.user.uid
                            ? Feather.log_out
                            : controller.user['isFollowing']
                            ? Feather.user_minus
                            : Feather.user_plus,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        widget.uid == authController.user.uid
                            ? 'Sign Out'
                            : controller.user['isFollowing']
                            ? 'Unfollow'
                            : 'Follow',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        if (widget.uid == authController.user.uid) {
                          authController.signOut();
                        } else {
                          controller.followUser();
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Video Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.user['thumbnails'].length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 9 / 16,
                        ),
                    itemBuilder: (context, index) {
                      final thumbnail = controller.user['thumbnails'][index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: thumbnail,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatWithIcon(IconData icon, String label, String count) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              count,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
      ],
    );
  }
}
