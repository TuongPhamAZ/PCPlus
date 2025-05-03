import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pcplus/pages/shop_information/shop_information_contract.dart';

class ShopInformationPresenter {
  final ShopInformationContract _view;
  ShopInformationPresenter(this._view);

  XFile? pickedImage;
}
