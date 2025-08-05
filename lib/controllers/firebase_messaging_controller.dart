// controllers/firebase_messaging_controller.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseMessagingController extends GetxController {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    await _requestPermission();
    await _saveDeviceToken();
    _initLocalNotifications();
    _setupForegroundListener();
    _setupNotificationTapListener();
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('🔔 Notification permission granted.');
    } else {
      debugPrint('❌ Notification permission denied.');
    }
  }

  Future<void> _saveDeviceToken() async {
    String? token = await _messaging.getToken();
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (token != null && uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': token,
      });
      debugPrint("📬 FCM Token saved: $token");
    }
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null && Platform.isAndroid) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'chat_channel',
              'Chat Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  void _setupNotificationTapListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;

      if (data.containsKey('chatId')) {
        Get.toNamed(
          '/chat',
          arguments: {
            'chatId': data['chatId'],
            'receiverId': data['receiverId'],
            'userName': data['userName'],
          },
        );
      }
    });
  }

  void _initLocalNotifications() {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    _localNotificationsPlugin.initialize(initSettings);
  }
}
