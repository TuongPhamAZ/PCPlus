// ignore_for_file: constant_identifier_names

abstract class OrderStatus {
  // Cho xac nhan
  static const PENDING_CONFIRMATION = "PendingConfirmation";
  // Cho lay hang
  static const AWAIT_PICKUP = "AwaitPickup";
  // Cho giao hang
  static const AWAIT_DELIVERY = "AwaitDelivery";
  // Cho danh gia
  static const AWAIT_RATING = "AwaitRating";
  // Hoan thanh
  static const COMPLETED = "Completed";
  // Huy
  static const CANCELLED = "Cancelled";
}