import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/bills/bill_of_shop_model.dart';
import 'package:pcplus/models/bills/bill_of_shop_repo.dart';
import 'package:pcplus/pages/statistic/statistic_contract.dart';
import 'dart:async';

class StatisticPresenter {
  final StatisticContract _view;
  StatisticPresenter(this._view);

  final BillOfShopRepository _billOfShopRepo = BillOfShopRepository();

  // StreamController để quản lý lifecycle
  StreamController<List<BillOfShopModel>>? _billsController;
  StreamSubscription<List<BillOfShopModel>>? _billsSubscription;

  // Getter cho stream
  Stream<List<BillOfShopModel>>? get billsStream => _billsController?.stream;

  bool _isDisposed = false;

  Future<void> getData() async {
    if (_isDisposed) return;

    // Khởi tạo controller nếu chưa có
    _billsController ??= StreamController<List<BillOfShopModel>>();

    // Lắng nghe stream từ repository
    _billsSubscription = _billOfShopRepo
        .getAllBillsOfShopFromShopStream(
            SessionController.getInstance().userID!)
        .listen(
      (data) {
        if (!_isDisposed && !_billsController!.isClosed) {
          _billsController!.add(data);
        }
      },
      onError: (error) {
        if (!_isDisposed && !_billsController!.isClosed) {
          _billsController!.addError(error);
        }
      },
    );
  }

  void onChangeItemType(String itemType) {
    _view.onChangeItemType(itemType);
  }

  void onChangeStatisticFilter(String mode) {
    _view.onChangeStatisticMode(mode);
  }

  void onChangeYear(String? value) {
    _view.onChangeYear(value!);
  }

  void onChangeMonth(String? value) {
    _view.onChangeMonth(value!);
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _disposeStreams();
  }

  Future<void> _disposeStreams() async {
    await _billsSubscription?.cancel();
    _billsSubscription = null;

    if (_billsController != null && !_billsController!.isClosed) {
      await _billsController!.close();
    }
    _billsController = null;
  }
}
