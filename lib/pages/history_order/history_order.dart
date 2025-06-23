import 'package:flutter/material.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../models/bills/bill_model.dart';
import '../../models/bills/bill_of_shop_model.dart';
import '../../models/bills/bill_shop_model.dart';
import '../widgets/paginated_list_view.dart';
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

  bool _isFirstLoad = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _presenter = HistoryOrderPresenter(this, orderType: widget.orderType);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      loadData();
      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _presenter?.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (mounted) {
      await _presenter?.getData();
    }
  }

  void _goToTop() {
    // scroll to top
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lịch sử đơn hàng',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.0),
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

                    List<BillOfShopModel> orders = [...(snapshot.data ?? [])];

                    // Filter order
                    if (widget.orderType.isNotEmpty) {
                      orders = orders
                          .where((v) => v.status == _presenter!.orderType)
                          .toList();
                    }

                    if (orders.isEmpty) {
                      return const Center(child: Text(''));
                    }

                    int index = 0;
                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: PaginatedListView<BillOfShopModel>(
                        items: orders,
                        itemsPerPage: 10,
                        onPageChanged: (value) {
                          _goToTop();
                        },
                        itemBuilder: (context, item) {
                          final order = item;
                          index ++;
                          return KeyedSubtree(
                            key: ValueKey(
                                "$index${order.status!}"), // <-- ép Flutter hiểu phần tử này là khác
                            child:
                            _presenter!.createHistoryOrderItemForShop(order)!,
                          );
                        },
                      ),
                    );

                    // return ListView.builder(
                    //   itemCount: orders.length,
                    //   shrinkWrap: true,
                    //   // physics: const Scroas(),
                    //   itemBuilder: (context, index) {
                    //     final order = orders[index];
                    //     return KeyedSubtree(
                    //       key: ValueKey(
                    //           "$index${order.status!}"), // <-- ép Flutter hiểu phần tử này là khác
                    //       child:
                    //           _presenter!.createHistoryOrderItemForShop(order)!,
                    //     );
                    //   },
                    // );
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

                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: PaginatedListView<BillShopModel>(
                          items: billsAndShopsMap.keys.toList(),
                          itemsPerPage: 10,
                          onPageChanged: (value) {
                            _goToTop();
                          },
                          itemBuilder: (context, item) {
                            BillShopModel billShopModel = item;
                            BillModel? billModel = billsAndShopsMap[billShopModel];
                            return _presenter!.createHistoryOrderItemForUser(
                              billModel!,
                              billShopModel.shopID!,
                            )!;
                          },
                      )
                    );

                    // return ListView.builder(
                    //   itemCount: billsAndShopsMap.keys.length,
                    //   shrinkWrap: true,
                    //   // physics: const Scroas(),
                    //   itemBuilder: (context, index) {
                    //     BillShopModel billShopModel =
                    //         billsAndShopsMap.keys.elementAt(index);
                    //     BillModel? billModel = billsAndShopsMap[billShopModel];
                    //
                    //     return _presenter!.createHistoryOrderItemForUser(
                    //       billModel!,
                    //       billShopModel.shopID!,
                    //     );
                    //   },
                    // );
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
