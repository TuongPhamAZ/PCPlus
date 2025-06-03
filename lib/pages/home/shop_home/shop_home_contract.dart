
import 'package:pcplus/models/items/item_with_seller.dart';

import '../../../models/vouchers/voucher_model.dart';

abstract class ShopHomeContract {
  void onLoadDataSucceeded();
  // void onFetchDataSucceeded();
  void onWaitingProgressBar();
  void onPopContext();
  void onItemEdit(ItemWithSeller item);
  void onItemDelete();
  void onItemPressed(ItemWithSeller item);
  void onBack();
  void onVoucherPressed(VoucherModel voucher);
  void onVoucherEdit(VoucherModel voucher);
  void onVoucherDelete(VoucherModel voucher);
}