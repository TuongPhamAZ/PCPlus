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
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Kiểm tra dữ liệu đầu vào
      if (tokens.isEmpty) {
        debugPrint('❌ Không có token nào để gửi thông báo');
        return false;
      }

      if (title.isEmpty || body.isEmpty) {
        debugPrint('❌ Title hoặc body không được để trống');
        return false;
      }

      // Sử dụng server FCM tùy chỉnh
      const String fcmServerUrl =
          'https://fcm-server-ylrh.onrender.com/send-fcm';

      final Map<String, dynamic> requestBody = {
        'tokens': tokens,
        'title': title,
        'body': body,
        'data': data ?? {},
      };

      debugPrint('📤 Đang gửi thông báo đến ${tokens.length} thiết bị...');

      final http.Response response = await http
          .post(
        Uri.parse(fcmServerUrl),
        headers: {
          'Content-Type': 'application/json',
        },
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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final successCount = responseData['successCount'] ?? 0;
        final failureCount = responseData['failureCount'] ?? 0;

        if (failureCount > 0) {
          final failures = responseData['failure'] as List;
          for (var failure in failures) {
            debugPrint(
                '❌ Lỗi gửi đến token ${failure['token']}: ${failure['error']}');
          }
        }

        debugPrint(
            '📊 Kết quả gửi thông báo: ${successCount} thành công, ${failureCount} thất bại');

        // Trả về true nếu có ít nhất một thông báo được gửi thành công
        return successCount > 0;
      } else if (response.statusCode == 400) {
        debugPrint('❌ Lỗi 400: Dữ liệu gửi đi không hợp lệ');
        return false;
      } else if (response.statusCode == 404) {
        debugPrint('❌ Lỗi 404: Không tìm thấy địa chỉ server FCM');
        return false;
      } else if (response.statusCode == 500) {
        debugPrint('❌ Lỗi 500: Lỗi server FCM');
        return false;
      } else {
        debugPrint(
            '❌ Lỗi không xác định (${response.statusCode}): ${response.body}');
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
