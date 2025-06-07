import '../../../models/vouchers/voucher_model.dart';

abstract class ListVoucherChoiceContract {
  void onWaitingProgressBar();
  void onPopContext();
  void onVoucherPressed(VoucherModel? voucher);
}