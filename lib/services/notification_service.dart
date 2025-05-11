import 'package:pcplus/models/notification/notification_repo.dart';

import '../models/bills/bill_model.dart';
import '../models/bills/bill_of_shop_model.dart';
import '../models/notification/notification_model.dart';
import '../models/orders/order_model.dart';
import '../models/users/user_model.dart';

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
    _notificationRepo.addNotificationToFirestore(
        sellerID,
        notification
    );
  }

  Future<void> createCancelOrderingNotification(OrderModel order, String reason) async {
    NotificationModel notification = NotificationModel(
      title: "Đơn hàng đã bị hủy",
      content: "${order.receiverName} đã hủy đơn (Mã history_order: ${order.orderID!}) với lý do: $reason",
      isRead: false,
      date: DateTime.now(),
      productImage: order.itemModel!.image,
    );
    _notificationRepo.addNotificationToFirestore(
        order.itemModel!.sellerID!,
        notification
    );
  }

  Future<void> createReceivedOrderNotification(OrderModel order) async {
    NotificationModel notification = NotificationModel(
      title: "Khách hàng đã nhận đơn",
      content: "${order.receiverName} đã nhận được đơn hàng. Mã history_order: ${order.orderID!}",
      isRead: false,
      date: DateTime.now(),
      productImage: order.itemModel!.image,
    );
    _notificationRepo.addNotificationToFirestore(
        order.itemModel!.sellerID!,
        notification
    );
  }

  // TODO: Thong bao duoc tao ra tu shop

  Future<void> createShopCancelOrderingNotification(OrderModel order, String reason) async {
    NotificationModel notification = NotificationModel(
      title: "Đơn hàng đã bị hủy",
      content: "${order.shopName} đã hủy đơn (Mã history_order: ${order.orderID!}) với lý do: $reason",
      isRead: false,
      date: DateTime.now(),
      productImage: order.itemModel!.image,
    );
    _notificationRepo.addNotificationToFirestore(
        order.receiverID!,
        notification
    );
  }

  Future<void> createShopConfirmOrderNotification(OrderModel order) async {
    NotificationModel notification = NotificationModel(
      title: "Shop đã nhận đơn",
      content: "${order.shopName} đã đồng ý đơn hàng của bạn. Mã history_order: ${order.orderID!}",
      isRead: false,
      date: DateTime.now(),
      productImage: order.itemModel!.image,
    );
    _notificationRepo.addNotificationToFirestore(
        order.receiverID!,
        notification
    );
  }

  Future<void> createShopSentOrderNotification(OrderModel order) async {
    NotificationModel notification = NotificationModel(
      title: "Đơn hàng đang được giao",
      content: "${order.shopName} đã gửi đơn hàng đến bạn. Mã history_order: ${order.orderID!}",
      isRead: false,
      date: DateTime.now(),
      productImage: order.itemModel!.image,
    );
    _notificationRepo.addNotificationToFirestore(
        order.receiverID!,
        notification
    );
  }
}