import 'package:flutter/material.dart';
import 'package:pcplus/models/bills/bill_shop_item_model.dart';
import 'package:pcplus/pages/rating/rating_contract.dart';
import 'package:pcplus/pages/rating/rating_presenter.dart';
import 'package:pcplus/services/utility.dart';

import '../../commands/rating_item/rating_item_on_submit_command.dart';
import '../../models/bills/bill_model.dart';
import '../../models/orders/order_model.dart';
import '../../themes/text_decor.dart';
import '../widgets/listItem/rating_item.dart';
import '../widgets/util_widgets.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});
  static const String routeName = 'rating_screen';

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> implements RatingScreenContract {
  RatingPresenter? _presenter;

  @override
  void initState() {
    _presenter = RatingPresenter(this);
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
          'My Rating',
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
        child: SingleChildScrollView(
          child: null
            //   StreamBuilder<List<BillModel>>(
            //     stream: _presenter!.billStream,
            //     builder: (context, snapshot) {
            //       Widget? result = UtilWidgets.createSnapshotResultWidget(context, snapshot);
            //       if (result != null) {
            //         return result;
            //       }
            //
            //       final orders = snapshot.data ?? [];
            //
            //       if (orders.isEmpty) {
            //         return const Center(child: Text('No data'));
            //       }
            //
            //       List<BillShopItemModel> items = [];
            //
            //
            //       return ListView.builder(
            //           itemCount: items.length,
            //           shrinkWrap: true,
            //           physics: const NeverScrollableScrollPhysics(),
            //           itemBuilder: (context, index) {
            //             return RatingItem(
            //                 shopName: orders[index].shopName!,
            //                 productName: orders[index].itemModel!.name!,
            //                 color: orders[index].itemModel!.color!.name!,
            //                 image: orders[index].itemModel!.image!,
            //                 dayRemain: 30 - Utility.calculateDuration(orders[index].orderDate!, DateTime.now()).inDays,
            //                 buyAmount: orders[index].amount!,
            //                 onSubmit: RatingItemOnSubmitCommand(
            //                   presenter: _presenter!,
            //                   model: orders[index]
            //                 ),
            //             );
            //           },
            //         );
            //   },
            // ),


        ),
      ),
    );
  }

  @override
  void onLoadDataSucceeded() {
    // TODO: implement onLoadDataSucceeded
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
