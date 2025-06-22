import 'package:pcplus/models/vouchers/voucher_repo.dart';
import 'package:pcplus/pages/bill/list_voucher/list_voucher_choice_contract.dart';
import 'dart:async';

import '../../../models/shops/shop_model.dart';
import '../../../models/vouchers/voucher_model.dart';

class ListVoucherChoicePresenter {
  final ListVoucherChoiceContract _view;

  ListVoucherChoicePresenter(this._view);

  final VoucherRepository _voucherRepo = VoucherRepository();

  String? shopID;

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
    _voucherSubscription = _voucherRepo.getShopVouchersStream(shopID!).listen(
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
  }

  void handleSelectVoucher(VoucherModel? voucher) {
    _view.onVoucherPressed(voucher);
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
