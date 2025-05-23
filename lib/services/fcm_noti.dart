import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pcplus/pages/notification/notification.dart';

class FCMNotificationService {
  static final FCMNotificationService _instance =
      FCMNotificationService._internal();
  factory FCMNotificationService() => _instance;
  FCMNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  // Khởi tạo service
  Future<void> initialize() async {
    // Cấu hình các thông số cần thiết cho local notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Đăng ký channel cho Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Đăng ký handlers cho FCM messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Xử lý thông báo ban đầu khi app được mở từ terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  // Yêu cầu quyền thông báo
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  // Xử lý khi nhận được thông báo khi app đang chạy
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: 'launch_background',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  // Xử lý khi người dùng nhấn vào thông báo để mở app từ background
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    Get.to(() => const NotificationScreen());
  }

  // Xử lý khi nhấn vào thông báo local
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notification clicked with payload: ${response.payload}');
    if (response.payload != null) {
      Get.to(() => const NotificationScreen());
    }
  }

  // Gửi thông báo FCM đến danh sách token
  Future<bool> sendNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // 1) Validate input
      if (topic.isEmpty) {
        debugPrint('❌ Topic không được để trống');
        return false;
      }
      if (title.isEmpty || body.isEmpty) {
        debugPrint('❌ Title hoặc body không được để trống');
        return false;
      }

      // 2) Prepare request
      const String fcmServerUrl =
          'https://fcm-server-ylrh.onrender.com/send-fcm';
      final Map<String, dynamic> requestBody = {
        'topic': topic,
        'title': title,
        'body': body,
        'data': data ?? {},
      };

      debugPrint('📤 Đang gửi thông báo đến topic: $topic');

      // 3) Send
      final http.Response response = await http
          .post(
        Uri.parse(fcmServerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('⏰ Timeout khi kết nối đến server FCM');
        },
      );

      debugPrint("📥 Response status: ${response.statusCode}");
      debugPrint("📥 Response body: ${response.body}");

      // 4) Handle server’s format:
      if (response.statusCode == 200) {
        // server returns { success: true, topic, messageId } on success
        final Map<String, dynamic> resp = jsonDecode(response.body);
        if (resp['success'] == true) {
          final String messageId = resp['messageId'] as String? ?? '';
          debugPrint('✅ Gửi thành công đến topic $topic, messageId=$messageId');
          return true;
        } else {
          // (theoretically shouldn't happen with your code, but just in case)
          debugPrint('❌ Server trả về success=false');
          return false;
        }
      } else {
        // non-200: error body has { error: '...' }
        String errorMessage = 'Không xác định';
        try {
          final Map<String, dynamic> err = jsonDecode(response.body);
          errorMessage = err['error'] as String? ?? errorMessage;
        } catch (_) {}
        debugPrint('❌ Lỗi ${response.statusCode}: $errorMessage');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Lỗi gửi thông báo: $e');
      return false;
    }
  }

  // Huỷ đăng ký FCM token
  Future<void> unsubscribe() async {
    await _firebaseMessaging.deleteToken();
  }
}

// Hàm xử lý thông báo khi app ở trạng thái background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
}
