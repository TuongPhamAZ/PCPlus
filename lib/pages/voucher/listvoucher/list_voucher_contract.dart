import '../../../models/vouchers/voucher_model.dart';

abstract class ListVoucherContract {
  void onWaitingProgressBar();
  void onPopContext();
  void onVoucherPressed(VoucherModel voucher);
  void onVoucherEdit(VoucherModel voucher);
  void onVoucherDelete(VoucherModel voucher);
}