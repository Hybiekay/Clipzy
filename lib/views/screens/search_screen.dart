import 'package:flutter/material.dart';
import 'package:clipzy/controllers/search_controller.dart' as mine;
import 'package:get/get.dart';
import 'package:clipzy/models/user.dart';
import 'package:clipzy/views/screens/profile_screen.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final mine.SearchController searchController = Get.put(
    mine.SearchController(),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.white54),
                hintText: 'Search users',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onFieldSubmitted: (value) => searchController.searchUser(value),
            ),
          ),
        ),
        body:
            searchController.searchedUsers.isEmpty
                ? const Center(
                  child: Text(
                    'Search for users!',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: searchController.searchedUsers.length,
                  separatorBuilder:
                      (context, index) => Divider(
                        color: Colors.white10,
                        indent: 16,
                        endIndent: 16,
                      ),
                  itemBuilder: (context, index) {
                    User user = searchController.searchedUsers[index];
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(uid: user.uid),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.profilePhoto),
                        radius: 24,
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
      );
    });
  }
}
