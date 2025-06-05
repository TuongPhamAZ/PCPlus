import 'package:flutter/material.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../models/bills/bill_model.dart';
import '../../models/bills/bill_of_shop_model.dart';
import '../../models/bills/bill_shop_model.dart';
import '../widgets/util_widgets.dart';
import 'history_order_contract.dart';
import 'history_order_presenter.dart';

class HistoryOrder extends StatefulWidget {
  final String orderType;
  const HistoryOrder({super.key, required this.orderType});
  static const String routeName = 'history_order';

  @override
  State<HistoryOrder> createState() => _HistoryOrderState();
}

class _HistoryOrderState extends State<HistoryOrder>
    implements HistoryOrderContract {
  HistoryOrderPresenter? _presenter;

  List<Widget> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    _presenter = HistoryOrderPresenter(this, orderType: widget.orderType);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    await _presenter?.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History Order',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.5),
          ),
          child: (_presenter!.isShop)
              ? StreamBuilder<List<BillOfShopModel>>(
                  stream: _presenter!.billsOfShopStream,
                  builder: (context, snapshot) {
                    Widget? result = UtilWidgets.createSnapshotResultWidget(
                        context, snapshot);
                    if (result != null) {
                      return result;
                    }

                    var orders = snapshot.data ?? [];

                    // Filter order
                    if (widget.orderType.isNotEmpty) {
                      orders = orders
                          .where((v) => v.status == _presenter!.orderType)
                          .toList();
                    }

                    if (orders.isEmpty) {
                      return const Center(child: Text(''));
                    }

                    return ListView.builder(
                      itemCount: orders.length,
                      shrinkWrap: true,
                      // physics: const Scroas(),
                      itemBuilder: (context, index) {
                        return _presenter!
                            .createHistoryOrderItemForShop(orders[index]);
                      },
                    );
                  },
                )
              : StreamBuilder<List<BillModel>>(
                  stream: _presenter!.billStream,
                  builder: (context, snapshot) {
                    Widget? result = UtilWidgets.createSnapshotResultWidget(
                        context, snapshot);
                    if (result != null) {
                      return result;
                    }

                    final orders = snapshot.data ?? [];

                    if (orders.isEmpty) {
                      return const Center(child: Text(''));
                    }

                    Map<BillShopModel, BillModel> billsAndShopsMap = {};

                    for (BillModel bill in orders) {
                      for (BillShopModel billShop in bill.shops!) {
                        if (widget.orderType.isNotEmpty &&
                            billShop.status != widget.orderType) {
                          continue;
                        }
                        billsAndShopsMap[billShop] = bill;
                      }
                    }

                    return ListView.builder(
                      itemCount: billsAndShopsMap.keys.length,
                      shrinkWrap: true,
                      // physics: const Scroas(),
                      itemBuilder: (context, index) {
                        BillShopModel billShopModel =
                            billsAndShopsMap.keys.elementAt(index);
                        BillModel? billModel = billsAndShopsMap[billShopModel];

                        return _presenter!.createHistoryOrderItemForUser(
                          billModel!,
                          billShopModel.shopID!,
                        );
                      },
                    );
                  },
                )),
    );
  }

  @override
  void onItemPressed() {
    // TODO: implement onItemPressed
  }

  @override
  void onLoadDataSucceeded() {
    if (!mounted) {
      return;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }

  @override
  void onError(String message) {
    UtilWidgets.createSnackBar(context, message);
  }
}
