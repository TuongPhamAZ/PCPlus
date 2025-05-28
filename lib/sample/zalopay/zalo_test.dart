import 'package:flutter/material.dart';
import 'package:flutter_zalopay_sdk/flutter_zalopay_sdk.dart';
import 'package:pcplus/services/zalo_pay_service.dart';

class Dashboard extends StatefulWidget {
  final String title;
  final String version;
  Dashboard({required this.title, required this.version});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          // backgroundColor: Colors.transparent,
          leading: Center(
            child: Text(widget.version),
          ),
          title: Text(
            widget.title,
          ),
        ),
        body: SafeArea(
          child: HomeZaloPay(widget.title),
        ),
      ),
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
    );
  }
}

class HomeZaloPay extends StatefulWidget {
  final String title;

  HomeZaloPay(this.title);

  @override
  _HomeZaloPayState createState() => _HomeZaloPayState();
}

class _HomeZaloPayState extends State<HomeZaloPay> {
  final textStyle = TextStyle(color: Colors.black54);
  final valueStyle = TextStyle(
      color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w400);
  String payAmount = "10000";
  bool isProcessing = false;

  ZaloPayService zaloPayService = ZaloPayService();

  @override
  void initState() {
    super.initState();
  }

  // Button Pay - tự động tạo order và thực hiện payment
  Widget _btnPay(String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: GestureDetector(
          onTap: isProcessing
              ? null
              : () async {
                  int amount = int.parse(value);
                  if (amount < 1000 || amount > 1000000) {
                    _showResultDialog(
                        "Lỗi",
                        "Số tiền không hợp lệ. Vui lòng nhập từ 1,000 đến 1,000,000 VND",
                        false);
                    return;
                  }

                  setState(() {
                    isProcessing = true;
                  });

                  // Hiển thị loading dialog
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Đang xử lý thanh toán..."),
                              ],
                            ),
                          ),
                        );
                      });

                  try {
                    // Tạo order
                    var orderResult = await createOrder(amount);
                    if (orderResult != null &&
                        orderResult.zptranstoken.isNotEmpty) {
                      // Thực hiện payment
                      FlutterZaloPaySdk.payOrder(
                              zpToken: orderResult.zptranstoken)
                          .then((event) {
                        Navigator.pop(context); // Đóng loading dialog
                        setState(() {
                          isProcessing = false;
                        });

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
                                "Thanh toán thành công!\nSố tiền: ${_formatCurrency(amount)} VND";
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

                        _showResultDialog(title, message, isSuccess);
                      });
                    } else {
                      Navigator.pop(context); // Đóng loading dialog
                      setState(() {
                        isProcessing = false;
                      });
                      _showResultDialog("Lỗi",
                          "Không thể tạo đơn hàng. Vui lòng thử lại", false);
                    }
                  } catch (e) {
                    Navigator.pop(context); // Đóng loading dialog
                    setState(() {
                      isProcessing = false;
                    });
                    _showResultDialog("Lỗi", "Có lỗi xảy ra: $e", false);
                  }
                },
          child: Container(
              height: 50.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isProcessing ? Colors.grey : Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text("Đang xử lý...",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0))
                      ],
                    )
                  : Text("Thanh toán",
                      style: TextStyle(color: Colors.white, fontSize: 20.0))),
        ),
      );

  // Hiển thị dialog kết quả
  void _showResultDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Format số tiền
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _quickConfig,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Nhập số tiền (VND)',
                icon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
                enabled: true,
              ),
              initialValue: payAmount,
              onChanged: (value) {
                setState(() {
                  payAmount = value;
                });
              },
              keyboardType: TextInputType.number,
              enabled: !isProcessing,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Số tiền: ${_formatCurrency(int.tryParse(payAmount) ?? 0)} VND",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          _btnPay(payAmount),
          SizedBox(height: 20),
          Text(
            "Bấm nút 'Thanh toán' để thực hiện giao dịch",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  createOrder(int amount) {
    ZaloResult zaloResult = ZaloResult();
    return zaloPayService.createZaloPayOrder(amount, zaloResult);
  }

  // ZaloPay sandbox configuration
  final String appId = "2553";
  final String key1 = "PcY4iZIKFCIdgZvA6ueMcMHHUbRLYjPL";
  final String key2 = "kLtgPl8HHhfvMuDHPwKfgfsY4Ydm9eIz";
  final String endpoint = "https://sb-openapi.zalopay.vn/v2/create";



  void _showError(String message) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    setState(() {
      isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// Build Info App
Widget _quickConfig = Container(
  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text("AppID: 2553"),
          ),
        ],
      ),
      // _btnQuickEdit,
    ],
  ),
);
