import 'package:pcplus/models/notification/notification_repo.dart';
import 'package:pcplus/models/users/user_repo.dart';

import '../models/bills/bill_of_shop_model.dart';
import '../models/notification/notification_model.dart';
import '../models/users/user_model.dart';
import 'fcm_noti.dart';

class NotificationService {
  final NotificationRepository _notificationRepo = NotificationRepository();
  // TODO: Thong bao duoc tao ra tu nguoi dung

  Future<void> createOrderingNotification(String sellerID, BillOfShopModel order) async {
    NotificationModel notification = NotificationModel(
      title: "Đơn hàng mới",
      content: "${order.shipInformation!.receiverName} đã đặt hàng từ bạn. Mã đơn hàng: ${order.billID!}",
      isRead: false,
      date: DateTime.now(),
      productImage: order.items!.first.color!.image ?? "",
    );
    await _notificationRepo.addNotificationToFirestore(
        sellerID,
        notification
    );
    UserRepository userRepository = UserRepository();
    UserModel? userModel = await userRepository.getUserById(sellerID);
    await sendFcmNotification(userModel!, notification);
  }

  Future<void> createCancelOrderingNotification(String sellerID, BillOfShopModel order, String reason) async {
    NotificationModel notification = NotificationModel(
      title: "Đơn hàng đã bị hủy",
      content: "${order.shipInformation!.receiverName} đã hủy đơn (Mã đơn hàng: ${order.billID!}) với lý do: $reason",
      isRead: false,
      date: DateTime.now(),
      productImage: order.items!.first.color!.image ?? "",
    );
    _notificationRepo.addNotificationToFirestore(
        sellerID,
        notification
    );
    UserRepository userRepository = UserRepository();
    UserModel? userModel = await userRepository.getUserById(sellerID);
    await sendFcmNotification(userModel!, notification);
  }

  Future<void> createReceivedOrderNotification(String sellerID, BillOfShopModel order) async {
    NotificationModel notification = NotificationModel(
      title: "Khách hàng đã nhận đơn",
      content: "${order.shipInformation!.receiverName} đã nhận được đơn hàng. Mã đơn hàng: ${order.billID!}",
      isRead: false,
      date: DateTime.now(),
      productImage: order.items!.first.color!.image ?? "",
    );
    _notificationRepo.addNotificationToFirestore(
        sellerID,
        notification
    );
    UserRepository userRepository = UserRepository();
    UserModel? userModel = await userRepository.getUserById(sellerID);
    await sendFcmNotification(userModel!, notification);
  }

  // TODO: Thong bao duoc tao ra tu shop

  Future<void> createShopCancelOrderingNotification(BillOfShopModel order, String shopName, String reason) async {
    NotificationModel notification = NotificationModel(
      title: "Đơn hàng đã bị hủy",
      content: "$shopName đã hủy đơn (Mã đơn hàng: ${order.billID!}) với lý do: $reason",
      isRead: false,
      date: DateTime.now(),
      productImage: order.items!.first.image!,
    );
    await _notificationRepo.addNotificationToFirestore(
        order.userID!,
        notification
    );
    UserRepository userRepository = UserRepository();
    UserModel? userModel = await userRepository.getUserById(order.userID!);
    await sendFcmNotification(userModel!, notification);
  }

  Future<void> createShopConfirmOrderNotification(BillOfShopModel order, String shopName) async {
    NotificationModel notification = NotificationModel(
      title: "Shop đã nhận đơn",
      content: "$shopName đã đồng ý đơn hàng của bạn. Mã đơn hàng: ${order.billID!}",
      isRead: false,
      date: DateTime.now(),
      productImage: order.items!.first.image!,
    );
    await _notificationRepo.addNotificationToFirestore(
        order.userID!,
        notification
    );
    UserRepository userRepository = UserRepository();
    UserModel? userModel = await userRepository.getUserById(order.userID!);
    await sendFcmNotification(userModel!, notification);
  }

  Future<void> createShopSentOrderNotification(BillOfShopModel order, String shopName) async {
    NotificationModel notification = NotificationModel(
      title: "Đơn hàng đang được giao",
      content: "$shopName đã gửi đơn hàng đến bạn. Mã đơn hàng: ${order.billID!}",
      isRead: false,
      date: DateTime.now(),
      productImage: order.items!.first.image!,
    );
    await _notificationRepo.addNotificationToFirestore(
        order.userID!,
        notification
    );
    UserRepository userRepository = UserRepository();
    UserModel? userModel = await userRepository.getUserById(order.userID!);
    await sendFcmNotification(userModel!, notification);
  }

  // TODO: Tạo FCM Notification
  Future<void> sendFcmNotification(UserModel user, NotificationModel notification) async {
    try {
      await FCMNotificationService().sendNotification(
        topic: user.userID!,
        title: notification.title!,
        body: notification.content!,
        data: {
          'type': 'test_notification',
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
    } catch (e) {
      print("Error at FCM Notification: ${e.toString()}");
    }
  }

}