import '../../../controller/session_controller.dart';
import '../../../models/shops/shop_model.dart';
import '../../../models/vouchers/voucher_model.dart';
import '../../../models/vouchers/voucher_repo.dart';
import 'list_voucher_contract.dart';

class ListVoucherPresenter {
  final ListVoucherContract _view;
  ListVoucherPresenter(this._view);
  final VoucherRepository _voucherRepo = VoucherRepository();
  final SessionController _sessionController = SessionController.getInstance();

  ShopModel? shopModel;

  Stream<List<VoucherModel>>? voucherStream;

  Future<void> getData() async {
    voucherStream = _voucherRepo.getShopVouchersStream(shopModel!.shopID!);

    // _view.onLoadDataSucceeded();
  }

  // TODO: Voucher
  void handleEditVoucher(VoucherModel model) {
    _view.onVoucherEdit(model);
  }

  Future<void> handleDeleteVoucher(VoucherModel model) async {
    _view.onWaitingProgressBar();
    await _voucherRepo.deleteVoucherById(shopModel!.shopID!, model.voucherID!);
    _view.onVoucherDelete(model);
  }

  void handleViewVoucher(VoucherModel model) {
    _view.onVoucherPressed(model);
  }
}