import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/bills/bill_of_shop_model.dart';
import 'package:pcplus/models/bills/bill_of_shop_repo.dart';
import 'package:pcplus/pages/statistic/statistic_contract.dart';

class StatisticPresenter {
  final StatisticContract _view;
  StatisticPresenter(this._view);

  final BillOfShopRepository _billOfShopRepo = BillOfShopRepository();

  Stream<List<BillOfShopModel>>? billsStream;

  Future<void> getData() async {
    billsStream = _billOfShopRepo.getAllBillsOfShopFromShopStream(SessionController().userID!);
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
}