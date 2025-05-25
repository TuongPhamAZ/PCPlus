import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcplus/component/dependency_injection.dart';
import 'package:pcplus/firebase_options.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product.dart';
import 'package:pcplus/pages/splash/splash.dart';
import 'package:pcplus/route.dart';
import 'package:pcplus/sample/FCM_notification/thongbao.dart';
import 'package:pcplus/sample/zalopay/zalo_test.dart';
// import 'package:pcplus/pages/splash/splash.dart';
import 'package:pcplus/services/fcm_noti.dart';
import 'package:pcplus/services/nav_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pcplus/component/item_argument.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/models/shops/shop_model.dart';
import 'package:pcplus/models/items/color_model.dart';

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
      home: Dashboard(title: 'PC Plus', version: '1.0.0'),
      routes: routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
