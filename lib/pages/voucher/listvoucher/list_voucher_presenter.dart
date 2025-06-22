import '../../../controller/session_controller.dart';
import '../../../models/shops/shop_model.dart';
import '../../../models/vouchers/voucher_model.dart';
import '../../../models/vouchers/voucher_repo.dart';
import 'list_voucher_contract.dart';
import 'dart:async';

class ListVoucherPresenter {
  final ListVoucherContract _view;
  ListVoucherPresenter(this._view);
  final VoucherRepository _voucherRepo = VoucherRepository();
  final SessionController _sessionController = SessionController.getInstance();

  ShopModel? shopModel;

  // StreamController để quản lý lifecycle
  StreamController<List<VoucherModel>>? _voucherController;
  StreamSubscription<List<VoucherModel>>? _voucherSubscription;

  // Getter cho stream
  Stream<List<VoucherModel>>? get voucherStream => _voucherController?.stream;

  bool _isDisposed = false;

  Future<void> getData() async {
    if (_isDisposed) return;

    // Khởi tạo controller nếu chưa có
    _voucherController ??= StreamController<List<VoucherModel>>();

    // Lắng nghe stream từ repository
    _voucherSubscription =
        _voucherRepo.getShopVouchersStream(shopModel!.shopID!).listen(
      (data) {
        if (!_isDisposed && !_voucherController!.isClosed) {
          _voucherController!.add(data);
        }
      },
      onError: (error) {
        if (!_isDisposed && !_voucherController!.isClosed) {
          _voucherController!.addError(error);
        }
      },
    );

    // _view.onLoadDataSucceeded();
  }

  // TODO: Voucher
  void handleEditVoucher(VoucherModel model) {
    _view.onVoucherEdit(model);
  }

  Future<void> handleDeleteVoucher(VoucherModel model) async {
    if (_isDisposed) return;

    _view.onWaitingProgressBar();
    await _voucherRepo.deleteVoucherById(shopModel!.shopID!, model.voucherID!);
    _view.onVoucherDelete(model);
  }

  void handleViewVoucher(VoucherModel model) {
    _view.onVoucherPressed(model);
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _disposeStreams();
  }

  Future<void> _disposeStreams() async {
    await _voucherSubscription?.cancel();
    _voucherSubscription = null;

    if (_voucherController != null && !_voucherController!.isClosed) {
      await _voucherController!.close();
    }
    _voucherController = null;
  }
}
