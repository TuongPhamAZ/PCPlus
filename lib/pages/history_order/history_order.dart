import 'package:flutter/material.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../models/orders/order_model.dart';
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
          color: Colors.grey.withOpacity(0.5),
        ),
        child:
          StreamBuilder<List<OrderModel>>(
            stream: _presenter!.orderStream,
            builder: (context, snapshot) {
              Widget? result = UtilWidgets.createSnapshotResultWidget(context, snapshot);
              if (result != null) {
              return result;
              }

              final orders = snapshot.data ?? [];

              if (orders.isEmpty) {
              return const Center(child: Text('No data'));
              }

              return ListView.builder(
                itemCount: orders.length,
                shrinkWrap: true,
                // physics: const Scroas(),
                itemBuilder: (context, index) {
                  return _presenter!.createHistoryOrderItem(orders[index]);
                },
              );
            },
          )
        ),
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
}
