import 'dart:developer';

import 'package:get/get.dart';
import '../models/user.dart';
import '../constants.dart';

class SearchController extends GetxController {
  final Rx<List<User>> _searchedUsers = Rx<List<User>>([]);

  List<User> get searchedUsers => _searchedUsers.value;

  @override
  void onInit() {
    super.onInit();
    // Load all users on startup
    _searchedUsers.bindStream(getAllUsers());
  }

  Stream<List<User>> getAllUsers() {
    final currentUserId = authController.user.uid;

    return firestore.collection('users').snapshots().map((query) {
      List<User> retVal = [];
      // log(query.docs);
      for (var elem in query.docs) {
        try {
          final user = User.fromSnap(elem);
          if (user.uid != currentUserId) {
            retVal.add(user);
          }
        } catch (e, stackTrace) {
          log("❌ Error mapping user: ${elem.id}, error: $e");
          log(stackTrace.toString());
        }
      }

      return retVal;
    });
  }

  void searchUser(String typedUser) {
    final currentUserId = authController.user.uid;

    if (typedUser.isEmpty) {
      _searchedUsers.bindStream(getAllUsers());
    } else {
      final endText =
          typedUser.substring(0, typedUser.length - 1) +
          String.fromCharCode(typedUser.codeUnitAt(typedUser.length - 1) + 1);

      _searchedUsers.bindStream(
        firestore
            .collection('users')
            .orderBy('name')
            .where('name', isGreaterThanOrEqualTo: typedUser)
            .where('name', isLessThan: endText)
            .snapshots()
            .map((query) {
              List<User> retVal = [];

              for (var elem in query.docs) {
                try {
                  final user = User.fromSnap(elem);
                  if (user.uid != currentUserId) {
                    retVal.add(user);
                  }
                } catch (e, stackTrace) {
                  log("❌ Error mapping searched user: ${elem.id}, error: $e");
                  log(stackTrace.toString());
                }
              }

              return retVal;
            }),
      );
    }
  }
}
