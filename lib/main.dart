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

// Tạo mock data cho màn hình DetailProduct
ItemArgument createMockItemArgument() {
  // Tạo mock ItemModel
  final mockItem = ItemModel(
    itemID: "mock_id_123",
    name: "Laptop Gaming Asus ROG Strix G15",
    description:
        "Laptop gaming mạnh mẽ với hiệu năng vượt trội, thiết kế hiện đại, tản nhiệt hiệu quả. Phù hợp cho việc chơi game, đồ họa và các tác vụ nặng.",
    detail:
        "CPU: AMD Ryzen 7 5800H (8 nhân, 16 luồng, xung nhịp tối đa 4.4GHz)\nGPU: NVIDIA GeForce RTX 3060 6GB GDDR6\nRAM: 16GB DDR4 3200MHz\nỔ cứng: 512GB NVMe SSD\nMàn hình: 15.6 inch Full HD IPS, 144Hz, 100% sRGB\nHệ điều hành: Windows 11 Home\nPin: 90Wh, sạc nhanh 100W\nKết nối: Wi-Fi 6, Bluetooth 5.2, USB-C, HDMI 2.0\nBàn phím: RGB tùy chỉnh, hành trình phím 1.9mm\nTrọng lượng: 2.1kg",
    price: 25990000,
    discountPrice: 20990000, // Thêm giá giảm giá
    stock: 10,
    sold: 156,
    itemType: "Khác",
    sellerID: "seller_123",
    addDate: DateTime.now(),
    status: "active",
    rating: 4.5,
    ratingCount: 24,
    colors: [
      ColorModel(
          name: "Đen",
          image:
              "https://product.hstatic.net/200000420363/product/tai-nghe-rkx_46ecba7822eb413eb5c889d7ed92dc0b_master.jpg"),
      ColorModel(
          name: "Bạc",
          image:
              "https://pos.nvncdn.com/cba2a3-7534/ps/20220928_Q4OroOtai5szcgGlz76Io2Og.jpg"),
              ColorModel(
          name: "Xanh",
          image:
              "https://pos.nvncdn.com/cba2a3-7534/ps/20220928_Q4OroOtai5szcgGlz76Io2Og.jpg"),
              ColorModel(
          name: "Đỏ",
          image:
              "https://pos.nvncdn.com/cba2a3-7534/ps/20220928_Q4OroOtai5szcgGlz76Io2Og.jpg"),
              ColorModel(
          name: "Vàng",
          image:
              "https://pos.nvncdn.com/cba2a3-7534/ps/20220928_Q4OroOtai5szcgGlz76Io2Og.jpg"),
    ],
    reviewImages: [
      "https://soundpeatsvietnam.com/wp-content/uploads/2023/05/gofree.jpg",
      "https://bachlongstore.vn/vnt_upload/product/01_2024/54638.png",
      "https://gomhang.vn/wp-content/uploads/2023/10/tai-nghe-bluetooth-gaming-m10-Artboard-1.jpg",
    ],
  );

  // Tạo mock ShopModel
  final mockShop = ShopModel(
      shopID: "seller_123",
      name: "PCPlus Official Store",
      location: "TP. Hồ Chí Minh",
      phone: "0123456789",
      rating: 4.8,
      image:
          "https://tokyocamera.vn/wp-content/uploads/2022/08/drone_2_scaled_1_1536x864.jpg");

  // Tạo ItemWithSeller
  final mockItemWithSeller = ItemWithSeller(item: mockItem, seller: mockShop);

  // Tạo ItemArgument
  return ItemArgument(data: mockItemWithSeller);
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
      navigatorKey: NavService.key,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => DetailProduct(),
            settings: RouteSettings(
              name: DetailProduct.routeName,
              arguments: createMockItemArgument(),
            ),
          );
        },
      ),
      routes: routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
