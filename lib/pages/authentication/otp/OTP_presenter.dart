import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import 'otp_contract.dart';

class OtpPresenter {
  final OtpViewContract? _view;
  OtpPresenter(this._view);

  String pinCode = "";
  String? email = "";
  bool firstInit = true;

  Future<void> initSendPinCode() async {
    pinCode = _generateRandomCode();
    debugPrint("pinCode firstInit: $pinCode");
    if (firstInit) {
      firstInit = false;
      await _sendConfirmationCode(pinCode);
    }
  }

  Future<void> pinCodeVerify(String? pinCode) async {
    debugPrint("pinCode 1213: ${this.pinCode}");
    debugPrint("pinCode 123456: $pinCode");
    if (this.pinCode == pinCode) {
      _view?.onVerifySucceeded();
    } else {
      _view?.onWrongPinCodeError();
    }
  }

  void resendConfirmationCode() {
    pinCode = _generateRandomCode();
    _sendConfirmationCode(pinCode);
    _view?.onResendPinCode();
  }

  String _generateRandomCode() {
    Random random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  Future<void> _sendConfirmationCode(String code) async {
    String username = "personalschedulemanager@gmail.com";
    String password = "myocgxvnvsdybuhr";

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username)
      ..recipients.add(email)
      ..subject = 'Confirmation Code'
      ..text = 'Your confirmation code is: $code';

    try {
      final sendReport = await send(message, smtpServer);
      if (kDebugMode) {
        print('Message sent to $email: $sendReport');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }
}
