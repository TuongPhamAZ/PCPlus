

import 'package:pcplus/models/vouchers/voucher_repo.dart';
import 'package:pcplus/pages/bill/list_voucher/list_voucher_choice_contract.dart';

import '../../../models/shops/shop_model.dart';
import '../../../models/vouchers/voucher_model.dart';

class ListVoucherChoicePresenter {
  final ListVoucherChoiceContract _view;

  ListVoucherChoicePresenter(this._view);

  final VoucherRepository _voucherRepo = VoucherRepository();

  String? shopID;

  Stream<List<VoucherModel>>? voucherStream;

  Future<void> getData() async {
    voucherStream = _voucherRepo.getShopVouchersStream(shopID!);
  }

  void handleSelectVoucher(VoucherModel? voucher) {
    _view.onVoucherPressed(voucher);
  }
}