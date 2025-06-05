import 'package:flutter/material.dart';
import 'package:pcplus/pages/authentication/account_type/account_type_screen.dart';
import 'package:pcplus/pages/authentication/otp/OTP.dart';
import 'package:pcplus/pages/authentication/shop_information/shop_information_screen.dart';
import 'package:pcplus/pages/authentication/user_information/user_information.dart';
import 'package:pcplus/pages/history_order/history_order.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product.dart';
import 'package:pcplus/pages/bill/bill_product/bill_product.dart';
import 'package:pcplus/pages/bill/delivery_choice/delivery_choice.dart';
import 'package:pcplus/pages/bill/payment_choice/payment_choice.dart';
import 'package:pcplus/pages/bill/list_voucher/list_voucher_choice.dart';
import 'package:pcplus/pages/cart/cart_shopping.dart';
import 'package:pcplus/pages/user/change_password/change_password.dart';
import 'package:pcplus/pages/delivery/delivery_infor.dart';
import 'package:pcplus/pages/manage_product/edit_product/edit_product.dart';
import 'package:pcplus/pages/user/edit_profile/edit_profile.dart';
import 'package:pcplus/pages/authentication/forgot_password/forgot_password.dart';
import 'package:pcplus/pages/home/user_home/home.dart';
import 'package:pcplus/pages/authentication/login/login.dart';
import 'package:pcplus/pages/no_network/no_network.dart';
import 'package:pcplus/pages/notification/notification.dart';
import 'package:pcplus/pages/rating/rating.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product.dart';
import 'package:pcplus/pages/user/profile/profile.dart';
import 'package:pcplus/pages/authentication/register/register.dart';
import 'package:pcplus/pages/search/search_screen.dart';
import 'package:pcplus/pages/home/shop_home/shop_home.dart';
import 'package:pcplus/pages/splash/splash.dart';
import 'package:pcplus/pages/statistic/statistic.dart';
import 'package:pcplus/pages/voucher/addvoucher/add_voucher.dart';
import 'package:pcplus/pages/voucher/editvoucher/edit_voucher.dart';
import 'package:pcplus/pages/voucher/listvoucher/list_voucher.dart';
import 'package:pcplus/pages/voucher/voucherDetail/voucher_detail.dart';
import 'package:pcplus/pages/conversations/conversations.dart';
import 'package:pcplus/pages/chat_detail/chat_detail.dart';
import 'package:pcplus/sample/comment.dart';
import 'package:pcplus/sample/voice_search.dart';

import 'models/users/ship_infor_model.dart';
import 'models/chat/message_model.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  RegisterScreen.routeName: (context) => const RegisterScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  OTPScreen.routeName: (context) => const OTPScreen(),
  AccountTypeScreen.routeName: (context) => const AccountTypeScreen(),
  UserInformation.routeName: (context) => const UserInformation(),
  ShopInformationScreen.routeName: (context) => const ShopInformationScreen(),
  NoNetworkScreen.routeName: (context) => const NoNetworkScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  CartShoppingScreen.routeName: (context) => const CartShoppingScreen(),
  NotificationScreen.routeName: (context) => const NotificationScreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  EditProfileScreen.routeName: (context) => const EditProfileScreen(),
  ChangePasswordScreen.routeName: (context) => const ChangePasswordScreen(),
  DetailProduct.routeName: (context) => const DetailProduct(),
  BillProduct.routeName: (context) => const BillProduct(),
  DeliveryChoice.routeName: (context) => const DeliveryChoice(),
  PaymentChoice.routeName: (context) => const PaymentChoice(),
  ListVoucherChoice.routeName: (context) => const ListVoucherChoice(
        shopId: '',
        orderAmount: 0,
      ),
  DeliveryInfor.routeName: (context) =>
      DeliveryInfor(currentAddress: ShipInformationModel.emptyAddress),
  SearchScreen.routeName: (context) => const SearchScreen(),
  HistoryOrder.routeName: (context) => const HistoryOrder(
        orderType: '',
      ),
  RatingScreen.routeName: (context) => const RatingScreen(),
  ShopHome.routeName: (context) => const ShopHome(),
  Statistic.routeName: (context) => const Statistic(),
  AddProduct.routeName: (context) => const AddProduct(),
  EditProduct.routeName: (context) => const EditProduct(),
  AddVoucher.routeName: (context) => const AddVoucher(),
  EditVoucher.routeName: (context) => const EditVoucher(),
  ListVoucher.routeName: (context) => const ListVoucher(),
  VoucherDetail.routeName: (context) => const VoucherDetail(),
  ConversationsScreen.routeName: (context) => const ConversationsScreen(),
  ChatDetailScreen.routeName: (context) {
    final conversation =
        ModalRoute.of(context)!.settings.arguments as ConversationModel;
    return ChatDetailScreen(conversation: conversation);
  },
  SampleComment.routeName: (context) => const SampleComment(),
  VoiceSearchSample.routeName: (context) => const VoiceSearchSample(),
};
