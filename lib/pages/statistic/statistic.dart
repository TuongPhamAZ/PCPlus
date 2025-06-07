import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pcplus/const/tax_rate.dart';
import 'package:pcplus/models/bills/bill_of_shop_model.dart';
import 'package:pcplus/pages/statistic/statistic_contract.dart';
import 'package:pcplus/pages/statistic/statistic_presenter.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../const/item_type.dart';
import '../../objects/sale_data_object.dart';
import '../widgets/bottom/shop_bottom_bar.dart';
import '../widgets/util_widgets.dart';

class Statistic extends StatefulWidget {
  const Statistic({super.key});
  static const String routeName = 'statistic';

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> implements StatisticContract {
  StatisticPresenter? _presenter;

  List<BillOfShopModel> bills = [];

  String _selectedStatisticType = "Tháng"; // "Tháng" hoặc "Năm"
  String _selectedMonth = "12"; // Tháng mặc định
  String _selectedYear = "2024"; // Năm mặc định
  String _selectedItemType = "Tất cả"; // Loại sản phẩm mặc định
  final List<String> _months =
      List.generate(12, (index) => "${index + 1}"); // Tháng 1–12
  final List<String> _years =
      List.generate(DateTime.now().year - 2020 + 1, (index) => "${2020 + index}"); // Năm 2020–nay
  final List<String> _itemTypes = ["Tất cả", ...ItemType.collections];

  // Dữ liệu bán hàng (tháng và năm trong cùng một cấu trúc)
  final Map<String, Map<String, List<int>>> salesData = {
    "2024": {
      "12": [100, 120, 80],
      "2": [90, 140, 100],
      "Yearly": [1500, 1800, 1200],
    },
    "2025": {
      "1": [110, 130, 90],
      "Yearly": [1400, 1700, 1100],
    },
  };

  Map<String, YearlySaleDataObject> saleDataObjects = {};
  List<int> chartSalesData = [];
  List<String> chartItemsName = [];

  @override
  void initState() {
    _presenter = StatisticPresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DateTime dateTimeNow = DateTime.now();
    _selectedMonth = dateTimeNow.month.toString();
    _selectedYear = dateTimeNow.year.toString();
    loadData();
  }

  Future<void> loadData() async {
    await _presenter?.getData();
  }

  void getSalesData() {
    List<int> data = [];

    if (saleDataObjects.containsKey(_selectedYear)) {
      if (_selectedStatisticType == "Tháng") {
        MonthlySaleDataObject? monthlyData = saleDataObjects[_selectedYear]?.monthlyData[_selectedMonth];

        for (String itemID in monthlyData!.items.keys) {
          SaleDataItemObject? itemData = monthlyData.items[itemID];

          // filter
          if (_selectedItemType != "Tất cả" && _selectedItemType != itemData!.itemType) {
            continue;
          }

          data.add(itemData!.amount);
        }

      } else {
        // Yearly Mode
        Map<String, SaleDataItemObject> yearlyItemsData = saleDataObjects[_selectedYear]!.createYearlyData();

        for (String itemID in yearlyItemsData.keys) {
          SaleDataItemObject? itemData = yearlyItemsData[itemID];

          // filter
          if (_selectedItemType != "Tất cả" && _selectedItemType != itemData!.itemType) {
            continue;
          }

          data.add(itemData!.amount);
        }
      }
    }

    chartSalesData = data;
  }

  void getItemsName() {
    List<String> data = [];

    if (saleDataObjects.containsKey(_selectedYear)) {
      if (_selectedStatisticType == "Tháng") {
        MonthlySaleDataObject? monthlyData = saleDataObjects[_selectedYear]?.monthlyData[_selectedMonth];

        for (String itemID in monthlyData!.items.keys) {
          SaleDataItemObject? itemData = monthlyData.items[itemID];

          // filter
          if (_selectedItemType != "Tất cả" && _selectedItemType != itemData!.itemType) {
            continue;
          }

          data.add(itemData!.itemName);
        }
      } else {
        // Yearly Mode
        Map<String, SaleDataItemObject> yearlyItemsData = saleDataObjects[_selectedYear]!.createYearlyData();

        for (String itemID in yearlyItemsData.keys) {
          SaleDataItemObject? itemData = yearlyItemsData[itemID];

          // filter
          if (_selectedItemType != "Tất cả" && _selectedItemType != itemData!.itemType) {
            continue;
          }

          data.add(itemData!.itemName);
        }
      }
    }

    chartItemsName = data;
  }

  MonthlySaleDataObject? _getMonthlyData() {
    return saleDataObjects[_selectedYear]?.monthlyData[_selectedMonth];
  }

  YearlySaleDataObject? _getYearlyData() {
    return saleDataObjects[_selectedYear];
  }

  int _getOrderCount() {
    MonthlySaleDataObject? monthlyData = _getMonthlyData();
    YearlySaleDataObject? yearlyData = _getYearlyData();

    if (_selectedStatisticType == "Tháng") {
      return monthlyData == null ? 0 : monthlyData.orderCount;
    } else {
      return yearlyData == null ? 0 : yearlyData.orderCount;
    }
  }

  int _getPayout() {
    MonthlySaleDataObject? monthlyData = _getMonthlyData();
    YearlySaleDataObject? yearlyData = _getYearlyData();

    if (_selectedStatisticType == "Tháng") {
      return monthlyData == null ? 0 : monthlyData.payout;
    } else {
      return yearlyData == null ? 0 : yearlyData.payout;
    }
  }

  int _getTotalFee() {
    MonthlySaleDataObject? monthlyData = _getMonthlyData();
    YearlySaleDataObject? yearlyData = _getYearlyData();

    if (_selectedStatisticType == "Tháng") {
      return monthlyData == null ? 0 : monthlyData.totalFee;
    } else {
      return yearlyData == null ? 0 : yearlyData.totalFee;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'STATISTIC',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown chọn kiểu thống kê (Tháng/Năm)

            Row(
              children: [
                const Text(
                  "Thống kê theo: ",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedStatisticType,
                  items: ["Tháng", "Năm"].map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _presenter?.onChangeStatisticFilter(value!);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Dropdown chọn Tháng (chỉ hiển thị nếu chọn Tháng)
            if (_selectedStatisticType == "Tháng") ...[
              Row(
                children: [
                  const Text(
                    "Chọn tháng: ",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedMonth,
                    items: _months.map((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _presenter?.onChangeMonth(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Dropdown chọn Năm
            Row(
              children: [
                const Text(
                  "Chọn năm: ",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedYear,
                  items: _years.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _presenter?.onChangeYear(value);
                  },
                ),
              ],
            ),
            // Dropdown chọn loại sản phẩm
            Row(
              children: [
                const Text(
                  "Chọn loại sản phẩm: ",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedItemType,
                  items: _itemTypes.map((String itemType) {
                    return DropdownMenuItem<String>(
                      value: itemType,
                      child: Text(itemType),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _presenter?.onChangeItemType(value!);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Biểu đồ cột
            Expanded(

              child: StreamBuilder<List<BillOfShopModel>>(
                  stream: _presenter!.billsStream,
                  builder: (context, snapshot) {
                    Widget? result = UtilWidgets.createSnapshotResultWidget(context, snapshot);
                    if (result != null) {
                      return result;
                    }

                    final billData = snapshot.data ?? [];

                    bills = billData;
                    saleDataObjects.clear();

                    if (bills.isEmpty) {
                      return const Center(child: Text('No data'));
                    }

                    for (String year in _years) {
                      saleDataObjects[year] = YearlySaleDataObject.fromBillsOfShop(year, bills);
                    }

                    getSalesData();
                    getItemsName();

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thống kê doanh thu
                        Text(
                            "Tổng quan:",
                            style: TextDecor.robo18Bold.copyWith(color: Colors.black)
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          direction: Axis.vertical,
                          spacing: 8,
                          children: [
                            Text("Số đơn hàng: ${_getOrderCount()}"),
                            Text("Doanh thu: ${_getPayout()}"),
                            Text("Phí giao dịch (${TaxRate.totalFeePercent}): ${_getTotalFee()}"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                            "Biểu đồ",
                            style: TextDecor.robo18Bold.copyWith(color: Colors.black)
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              barGroups: chartSalesData
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.toDouble(),
                                      color: Colors.blue,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              )
                                  .toList(),
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: true),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Chú thích
                        Wrap(
                          spacing: 8,
                          children: chartItemsName
                              .asMap()
                              .entries
                              .map((entry) => Chip(
                            label: Text(
                                "(${entry.key}) ${entry.value}: ${chartSalesData[entry.key]} sản phẩm"),
                            backgroundColor: Colors.blue[100],
                          ))
                              .toList(),
                        ),
                      ],
                    );
                  }
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const ShopBottomBar(currentIndex: 1),
    );
  }

  @override
  void onChangeItemType(String itemType) {
    setState(() {
      _selectedItemType = itemType;
      getSalesData();
      getItemsName();
    });
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

  @override
  void onChangeStatisticMode(String mode) {
    setState(() {
      _selectedStatisticType = mode;
      if (_selectedStatisticType == "Năm") {
        _selectedMonth = "1"; // Reset tháng khi chọn Năm
      }
    });
  }

  @override
  void onChangeMonth(String month) {
    setState(() {
      _selectedMonth = month;
      getSalesData();
      getItemsName();
    });
  }

  @override
  void onChangeYear(String year) {
    setState(() {
      _selectedYear = year;
      getSalesData();
      getItemsName();
    });
  }
}
