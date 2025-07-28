// controllers/search_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
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
    return firestore.collection('users').snapshots().map((query) {
      List<User> retVal = [];
      for (var elem in query.docs) {
        retVal.add(User.fromSnap(elem));
      }
      return retVal;
    });
  }

  void searchUser(String typedUser) {
    if (typedUser.isEmpty) {
      _searchedUsers.bindStream(getAllUsers()); // Reset to all users
    } else {
      _searchedUsers.bindStream(
        firestore
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: typedUser)
            .snapshots()
            .map((query) {
              List<User> retVal = [];
              for (var elem in query.docs) {
                retVal.add(User.fromSnap(elem));
              }
              return retVal;
            }),
      );
    }
  }
}
