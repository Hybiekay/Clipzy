import 'package:clipzy/views/screens/messages_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:clipzy/controllers/auth_controller.dart';
import 'package:clipzy/views/screens/add_video_screen.dart';
import 'package:clipzy/views/screens/profile_screen.dart';
import 'package:clipzy/views/screens/search_screen.dart';
import 'package:clipzy/views/screens/video_screen.dart';

List pages = [
  VideoScreen(),
  SearchScreen(),
  // const AddVideoScreen(),
  DeviceVideoGalleryScreen(),
  MessagesScreen(),
  ProfileScreen(uid: authController.user.uid),
];

// COLORS
const backgroundColor = Colors.black;
var buttonColor = Colors.purple;
const borderColor = Colors.grey;

// FIREBASE
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

// CONTROLLER
var authController = AuthController.instance;
