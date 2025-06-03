import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_zalopay_sdk/flutter_zalopay_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/services/zaplo_pay_order_response.dart';

class ZaloPayService {
  // ZaloPay sandbox configuration
  final String appId = "2553";
  final String key1 = "PcY4iZIKFCIdgZvA6ueMcMHHUbRLYjPL";
  final String key2 = "kLtgPl8HHhfvMuDHPwKfgfsY4Ydm9eIz";
  final String endpoint = "https://sb-openapi.zalopay.vn/v2/create";

  Future<ZaloPayCreateOrderResponse?> createZaloPayOrder(int amount, ZaloResult zaloResult) async {
    try {
      // Generate unique transaction ID
      final now = DateTime.now();
      final appTransId =
          "${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.millisecondsSinceEpoch}";

      // Prepare order data
      final embedData = json.encode({"merchantinfo": "ZaloPay Flutter Demo"});
      final items = json.encode([
        {
          "itemid": "demo_item",
          "itemname": "Demo Item",
          "itemprice": amount,
          "itemquantity": 1
        }
      ]);

      final orderData = {
        "app_id": int.parse(appId),
        "app_user": "ZaloPay_Demo_User",
        "app_time": now.millisecondsSinceEpoch,
        "amount": amount,
        "app_trans_id": appTransId,
        "bank_code": "zalopayapp",
        "embed_data": embedData,
        "item": items,
        "description":
        "PC Plus - Thanh toán cho đơn hàng #$appTransId",
      };

      // Create MAC for authentication
      final data =
          "${orderData['app_id']}|${orderData['app_trans_id']}|${orderData['app_user']}|${orderData['amount']}|${orderData['app_time']}|${orderData['embed_data']}|${orderData['item']}";
      final mac = _generateMac(data, key1);
      orderData['mac'] = mac;

      debugPrint("Calling ZaloPay API with data: $orderData");

      // Make HTTP request to ZaloPay API
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: orderData.map((key, value) => MapEntry(key, value.toString())),
      );

      debugPrint("ZaloPay API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final zaloPayResponse =
        ZaloPayCreateOrderResponse.fromJson(responseData);

        if (zaloPayResponse.returnCode == 1) {
          return zaloPayResponse;
        } else {
          debugPrint("ZaloPay Error: ${zaloPayResponse.returnMessage}");
          zaloResult.errorText = ("Lỗi tạo đơn hàng: ${zaloPayResponse.returnMessage}");
          return null;
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
        zaloResult.errorText = ("Lỗi kết nối: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Exception: $e");
      zaloResult.errorText = ("Lỗi: $e");
      return null;
    }
  }

  String _generateMac(String data, String key) {
    var hmacSha256 = Hmac(sha256, utf8.encode(key));
    var digest = hmacSha256.convert(utf8.encode(data));
    return digest.toString();
  }

  Future<ZaloStatus?> handleZaloPayOrder(ZaloPayCreateOrderResponse orderResult, int amount) async {
    ZaloStatus? status;

    await FlutterZaloPaySdk.payOrder(zpToken: orderResult.zptranstoken).then((event) {
          String title = "";
          String message = "";
          bool isSuccess = false;

          switch (event) {
            case FlutterZaloPayStatus.cancelled:
              title = "Đã hủy";
              message = "Bạn đã hủy thanh toán";
              isSuccess = false;
              break;
            case FlutterZaloPayStatus.success:
              title = "Thành công";
              message =
              "Thanh toán thành công!\nSố tiền: ${Utility.formatCurrency(amount)}";
              isSuccess = true;
              break;
            case FlutterZaloPayStatus.failed:
              title = "Thất bại";
              message = "Thanh toán thất bại. Vui lòng thử lại";
              isSuccess = false;
              break;
            default:
              title = "Thất bại";
              message = "Thanh toán thất bại. Vui lòng thử lại";
              isSuccess = false;
              break;
          }

          status = ZaloStatus(
              title: title,
              message: message,
              isSuccess: isSuccess
          );
    });
    
    return status;
  }
}

class ZaloResult {
  String errorText = "";
}

class ZaloStatus {
    final String title;
    final String message;
    final bool isSuccess;

    ZaloStatus({
      required this.title,
      required this.message,
      required this.isSuccess,
    });
}