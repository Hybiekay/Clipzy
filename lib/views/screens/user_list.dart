import 'dart:async';
import 'dart:developer';
import 'package:clipzy/constants.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../controllers/search_controller.dart';
// ignore: unused_import
import '../../../models/user.dart';
import 'chat_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final SearchController searchController = Get.put(SearchController());
  final TextEditingController _searchTextController = TextEditingController();
  final currentUserId = fb.FirebaseAuth.instance.currentUser!.uid;

  bool _isSearching = false;
  Timer? _debounce;

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchController.searchUser(val.trim());
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchTextController.clear();
        searchController.searchUser('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder:
              (child, animation) => SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: child,
              ),
          child:
              _isSearching
                  ? TextField(
                    key: const ValueKey('search'),
                    controller: _searchTextController,
                    autofocus: true,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search users...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  )
                  : const Text("Start a Chat", key: ValueKey('title')),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
        centerTitle: true,
      ),
      body: Obx(() {
        final users = searchController.searchedUsers;

        if (users.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        return ListView.builder(
          itemCount: users.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemBuilder: (context, index) {
            final user = users[index];

            log(users.length.toString());
            // if (user.uid == currentUserId) return const SizedBox();

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePhoto),
                  radius: 26,
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final chatId = generateChatId(currentUserId, user.uid);
                    Get.to(
                      () => ChatDetailScreen(
                        chatId: chatId,
                        userId: currentUserId,
                        receiverId: user.uid,
                        userName: user.name,
                      ),
                    );
                  },
                  child: const Icon(
                    Ionicons.chatbubble_outline, // Messages icon
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String generateChatId(String id1, String id2) {
    return (id1.compareTo(id2) < 0) ? "$id1\_$id2" : "$id2\_$id1";
  }
}
