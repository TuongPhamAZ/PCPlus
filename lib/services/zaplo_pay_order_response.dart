class ZaloPayCreateOrderResponse {
  final int returnCode;
  final String returnMessage;
  final int subReturnCode;
  final String subReturnMessage;
  final String zptranstoken;
  final String orderUrl;
  final String orderToken;
  final String qrCode;

  ZaloPayCreateOrderResponse({
    required this.returnCode,
    required this.returnMessage,
    required this.subReturnCode,
    required this.subReturnMessage,
    required this.zptranstoken,
    required this.orderUrl,
    required this.orderToken,
    required this.qrCode,
  });

  factory ZaloPayCreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return ZaloPayCreateOrderResponse(
      returnCode: json['return_code'] ?? 0,
      returnMessage: json['return_message'] ?? '',
      subReturnCode: json['sub_return_code'] ?? 0,
      subReturnMessage: json['sub_return_message'] ?? '',
      zptranstoken: json['zp_trans_token'] ?? '',
      orderUrl: json['order_url'] ?? '',
      orderToken: json['order_token'] ?? '',
      qrCode: json['qr_code'] ?? '',
    );
  }
}
