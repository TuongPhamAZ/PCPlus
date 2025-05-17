import 'package:pcplus/models/bills/bill_shop_item_model.dart';
import 'package:pcplus/services/utility.dart';

import '../models/bills/bill_of_shop_model.dart';

class YearlySaleDataObject {
  String year;
  Map<String, MonthlySaleDataObject> monthlyData;
  int orderCount;
  int orderRevenue;
  int vat;
  int pit;
  int commissionFee;
  int payout;

  YearlySaleDataObject({
    required this.year,
    required this.monthlyData,
    required this.orderCount,
    required this.orderRevenue,
    required this.vat,
    required this.pit,
    required this.commissionFee,
    required this.payout,
  });

  int get totalFee {
    return vat + pit + commissionFee;
  }

  static YearlySaleDataObject fromBillsOfShop(String year, List<BillOfShopModel> bills) {
    Map<String, MonthlySaleDataObject> monthlyData = {};
    int orderRevenue = 0;
    int orderCount = 0;
    int vat = 0;
    int pit = 0;
    int commissionFee = 0;
    int payout = 0;

    final List<String> months = List.generate(12, (index) => "${index + 1}"); // Tháng 1–12

    for (String month in months) {
      MonthlySaleDataObject newMonthData = MonthlySaleDataObject.fromBillsOfShop(month, year, bills);
      monthlyData[month] = newMonthData;

      orderRevenue += newMonthData.orderRevenue;
      orderCount += newMonthData.orderCount;
      vat += newMonthData.vat;
      pit += newMonthData.pit;
      commissionFee += newMonthData.commissionFee;
      payout += newMonthData.payout;
    }

    return YearlySaleDataObject(
        year: year,
        monthlyData: monthlyData,
        orderCount: orderCount,
        orderRevenue: orderRevenue,
        vat: vat,
        pit: pit,
        commissionFee: commissionFee,
        payout: payout
    );
  }

  Map<String, SaleDataItemObject> createYearlyData () {
    Map<String, SaleDataItemObject> data = {};

    for (String month in monthlyData.keys) {
      MonthlySaleDataObject? monthData = monthlyData[month];

      if (monthData == null) {
        continue;
      }

      for (String itemID in monthData.items.keys) {
        if (data.containsKey(itemID)) {
          // Item exist
          SaleDataItemObject? itemData = data[itemID];
          SaleDataItemObject? thisMonthData = monthData.items[itemID];

          itemData!.amount += thisMonthData!.amount;
        } else {
          // new Data
          SaleDataItemObject? thisMonthData = monthData.items[itemID];

          data[itemID] = SaleDataItemObject(
              itemID: itemID,
              itemName: thisMonthData!.itemName,
              itemType: thisMonthData.itemType,
              amount: thisMonthData.amount,
          );
        }
      }
    }

    return data;
  }
}

class MonthlySaleDataObject {
  String month;
  Map<String, SaleDataItemObject> items;
  int orderCount;
  int orderRevenue;
  int vat;
  int pit;
  int commissionFee;
  int payout;

  MonthlySaleDataObject({
    required this.month,
    required this.items,
    required this.orderCount,
    required this.orderRevenue,
    required this.vat,
    required this.pit,
    required this.commissionFee,
    required this.payout,
  });

  int get totalFee {
    return vat + pit + commissionFee;
  }

  static MonthlySaleDataObject fromBillsOfShop(String month, String year, List<BillOfShopModel> bills) {
    Map<String, SaleDataItemObject> items = {};
    int orderRevenue = 0;
    int orderCount = 0;
    int vat = 0;
    int pit = 0;
    int commissionFee = 0;
    int payout = 0;

    // Chuyển đổi tháng và năm từ String sang int
    int monthInt = int.parse(month);
    int yearInt = int.parse(year);

    // Ngày đầu tháng
    DateTime firstDayOfMonth = DateTime(yearInt, monthInt, 1);

    // Tạo ngày đầu tháng của tháng tiếp theo
    DateTime firstDayNextMonth = DateTime(yearInt, monthInt + 1, 1);

    // Trừ đi 1 ngày từ ngày đầu tháng tiếp theo để có ngày cuối tháng
    DateTime lastDayOfMonth = firstDayNextMonth.subtract(const Duration(days: 1));

    for (BillOfShopModel bill in bills) {
      if (Utility.isDateInRange(bill.orderDate!, firstDayOfMonth, lastDayOfMonth)) {
        orderCount ++;
        orderRevenue += bill.totalPrice!;
        commissionFee += bill.commissionFee!;
        vat += bill.vat!;
        pit += bill.pit!;
        payout += bill.payout!;

        for (BillShopItemModel billItem in bill.items!) {
          if (items.containsKey(billItem.itemID)) {
            // Item exist
            SaleDataItemObject? itemData = items[billItem.itemID!];
            itemData!.amount += billItem.amount!;
          } else {
            // New Data
            items[billItem.itemID!] = SaleDataItemObject(
                itemID: billItem.itemID!,
                itemName: billItem.name!,
                itemType: billItem.itemType!,
                amount: billItem.amount!,
            );
          }
        }
      }
    }

    return MonthlySaleDataObject(
        month: month,
        items: items,
        orderCount: orderCount,
        orderRevenue: orderRevenue,
        payout: payout,
        commissionFee: commissionFee,
        pit: pit,
        vat: vat,
    );

  }
}

class SaleDataItemObject {
  String itemID;
  String itemName;
  String itemType;
  int amount;

  SaleDataItemObject({
    required this.itemID,
    required this.itemName,
    required this.itemType,
    required this.amount,
  });
}