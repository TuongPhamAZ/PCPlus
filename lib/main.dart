import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcplus/component/dependency_injection.dart';
import 'package:pcplus/firebase_options.dart';
import 'package:pcplus/pages/splash/splash.dart';
import 'package:pcplus/route.dart';
// import 'package:pcplus/pages/splash/splash.dart';
import 'package:pcplus/services/fcm_noti.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DependencyInjection.init();
  // Khởi tạo FCM service
  await initializeFCM();

  runApp(const MyApp());
}

Future<void> initializeFCM() async {
  final FCMNotificationService fcmService = FCMNotificationService();
  await fcmService.initialize();

  // Kiểm tra xem đã yêu cầu quyền thông báo chưa
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool hasRequestedPermission =
      prefs.getBool('notification_permission_requested') ?? false;
  // await FirebaseMessaging.instance.subscribeToTopic('test_topic');

  if (!hasRequestedPermission) {
    // Nếu chưa yêu cầu quyền, thực hiện yêu cầu và lưu trạng thái
    await fcmService.requestPermission();
    await prefs.setBool('notification_permission_requested', true);
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? currentToken = await messaging.getToken();
    debugPrint("currentToken PTT: $currentToken");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PC Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: Dashboard(title: 'PC Plus', version: '1.0.0'),
      home: const SplashScreen(),
      routes: routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
