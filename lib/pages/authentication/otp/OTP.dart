

// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:flutter/foundation.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/pages/authentication/account_type/account_type_screen.dart';
import 'package:pcplus/pages/authentication/otp/otp_contract.dart';
import 'package:pcplus/controller/register_controller.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../component/register_component.dart';
import '../../widgets/profile/button_profile.dart';
import '../../widgets/util_widgets.dart';
import 'OTP_presenter.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});
  static const String routeName = 'otp';

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> implements OtpViewContract {
  OtpPresenter? _otpPresenter;
  // ignore: unused_field
  final RegisterController _registerController =
      RegisterController.getInstance();
  final _formKey = GlobalKey<FormState>();
  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();
  TextEditingController textEditingController = TextEditingController();

  String currentText = "";

  @override
  void initState() {
    _otpPresenter = OtpPresenter(this);
    _otpPresenter!.initSendPinCode();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as RegisterArgument;

    _otpPresenter?.email = args.email;
    
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height - 115,
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Gap(5),
                  Image.asset(
                    AssetHelper.logo,
                    width: 150,
                    height: 150,
                  ),
                  const Gap(20),
                  Text(
                    'OTP',
                    style: TextDecor.profileTitle,
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'OTP code has been sent to:',
                    style: TextDecor.profileButtonText,
                  ),
                  Text(
                    _otpPresenter!.email!,
                    style: TextDecor.otpEmailText,
                  ),
                  const Gap(20),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Input code here:',
                      style: TextDecor.otpIntroText,
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 0),
                      child: PinCodeTextField(
                        appContext: context,
                        pastedTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        length: 6,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        validator: (v) {
                          if (v!.length < 6) {
                            return ""; // nothing to show
                          } else {
                            return null;
                          }
                        },
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(20),
                          fieldHeight: 50,
                          fieldWidth: 50,
                          activeColor: Palette.primaryColor,
                          activeFillColor: Palette.main3,
                          selectedColor: Palette.primaryColor,
                          selectedFillColor: Palette.main3,
                          inactiveColor: Palette.main3.withOpacity(0.44),
                          inactiveFillColor:
                              Palette.primaryColor.withOpacity(0.44),
                        ),
                        cursorColor: Colors.black,
                        animationDuration: const Duration(milliseconds: 300),
                        textStyle: const TextStyle(fontSize: 20, height: 1.6),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        errorAnimationController: errorController,
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        onCompleted: (value) {
                          setState(() {
                            currentText = value;
                          });
                        },
                        beforeTextPaste: (text) {
                          if (kDebugMode) {
                            print("Allowing to paste $text");
                          }
                          return true;
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Didn\'t receive the code?',
                        style: TextDecor.profileIntroText,
                      ),
                      InkWell(
                        onTap: () {
                          _otpPresenter!.resendConfirmationCode();
                        },
                        child: Text(
                          'Resend',
                          style: TextDecor.profileTextButton.copyWith(
                            color: Palette.main1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(35),
              ButtonProfile(
                name: 'NEXT',
                onPressed: () {
                  _otpPresenter!.pinCodeVerify(currentText);
                },
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onResendPinCode() {
    UtilWidgets.createSnackBar(context, "OTP code has been resent.");
  }

  @override
  void onVerifySucceeded() {
    Navigator.of(context).pushNamed(AccountTypeScreen.routeName,
        arguments: ModalRoute.of(context)!.settings.arguments);
  }

  @override
  void onWrongPinCodeError() {
    UtilWidgets.createDismissibleDialog(
        context, UtilWidgets.NOTIFICATION, "Input code is incorrect", () {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }
}
