import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/models/vouchers/voucher_model.dart';
import 'package:pcplus/pages/bill/list_voucher/list_voucher_choice_contract.dart';
import 'package:pcplus/pages/bill/list_voucher/list_voucher_choice_presenter.dart';
import 'package:pcplus/pages/voucher/widget/voucher_item.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/services/utility.dart';

import '../../widgets/util_widgets.dart';

class ListVoucherChoice extends StatefulWidget {
  final String shopId;
  final int orderAmount; // Giá trị đơn hàng để kiểm tra điều kiện
  final VoucherModel? currentSelectedVoucher; // Voucher đang được chọn (nếu có)

  const ListVoucherChoice({
    super.key,
    required this.shopId,
    required this.orderAmount,
    this.currentSelectedVoucher,
  });

  static const String routeName = 'list_voucher_choice';

  @override
  State<ListVoucherChoice> createState() => _ListVoucherChoiceState();
}

class _ListVoucherChoiceState extends State<ListVoucherChoice> implements ListVoucherChoiceContract {
  ListVoucherChoicePresenter? _presenter;
  
  VoucherModel? selectedVoucher;
  List<VoucherModel> mockVouchers = [];

  @override
  void initState() {
    _presenter = ListVoucherChoicePresenter(this);
    super.initState();
    selectedVoucher = widget.currentSelectedVoucher;
    _initMockVouchers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    _presenter!.shopID = widget.shopId;
    await _presenter?.getData();
  }

  void _initMockVouchers() {
    mockVouchers = [
      VoucherModel(
        voucherID: "1",
        name: "Giảm 50k",
        description: "Voucher giảm 50,000đ cho đơn hàng từ 200,000đ",
        condition: 200000,
        endDate: DateTime.now().add(const Duration(days: 30)),
        discount: 50000,
        quantity: 100,
      ),
      VoucherModel(
        voucherID: "2",
        name: "Giảm 20%",
        description: "Voucher giảm 20% tối đa 100,000đ cho đơn từ 500,000đ",
        condition: 500000,
        endDate: DateTime.now().add(const Duration(days: 15)),
        discount: 100000,
        quantity: 50,
      ),
      VoucherModel(
        voucherID: "3",
        name: "Freeship",
        description: "Miễn phí vận chuyển cho đơn từ 100,000đ",
        condition: 100000,
        endDate: DateTime.now().add(const Duration(days: 7)),
        discount: 30000,
        quantity: 0, // Hết lượt
      ),
      VoucherModel(
        voucherID: "4",
        name: "Voucher VIP",
        description: "Giảm 300,000đ cho đơn hàng trên 1 triệu",
        condition: 1000000,
        endDate: DateTime.now().add(const Duration(days: 10)),
        discount: 300000,
        quantity: 25,
      ),
      VoucherModel(
        voucherID: "5",
        name: "Sinh nhật shop",
        description: "Voucher sinh nhật giảm 100,000đ cho đơn từ 300,000đ",
        condition: 300000,
        endDate: DateTime.now().add(const Duration(days: 60)),
        discount: 100000,
        quantity: 200,
      ),
    ];
  }

  bool _isVoucherEligible(VoucherModel voucher) {
    return voucher.quantity! > 0 &&
        voucher.endDate!.isAfter(DateTime.now()) &&
        widget.orderAmount >= voucher.condition!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'CHỌN VOUCHER',
          style: TextDecor.robo18Bold.copyWith(
            color: Palette.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 26,
            color: Palette.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Trả về voucher đã chọn
              Navigator.pop(context, selectedVoucher);
            },
            child: Text(
              'Xong',
              style: TextDecor.robo16Medi.copyWith(
                color: Palette.primaryColor,
              ),
            ),
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          // Thông tin đơn hàng
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Palette.primaryColor,
                  size: 20,
                ),
                const Gap(8),
                Text(
                  'Giá trị đơn hàng: ',
                  style: TextDecor.robo14.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  Utility.formatCurrency(widget.orderAmount),
                  style: TextDecor.robo16Medi.copyWith(
                    color: Palette.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Option "Không sử dụng voucher"
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedVoucher == null
                    ? Palette.primaryColor
                    : Colors.grey.shade300,
                width: selectedVoucher == null ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: Icon(
                Icons.block,
                color: Colors.grey.shade600,
                size: 24,
              ),
              title: Text(
                'Không sử dụng voucher',
                style: TextDecor.robo15Medi.copyWith(
                  color: Colors.black87,
                ),
              ),
              trailing: Radio<VoucherModel?>(
                value: null,
                groupValue: selectedVoucher,
                onChanged: (value) {
                  setState(() {
                    selectedVoucher = null;
                  });
                },
                activeColor: Palette.primaryColor,
              ),
              onTap: () {
                setState(() {
                  selectedVoucher = null;
                });
              },
            ),
          ),

          const Gap(16),

          // Danh sách voucher
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<List<VoucherModel>>(
                  stream: _presenter!.voucherStream,
                  builder: (context, snapshot) {
                    Widget? result = UtilWidgets.createSnapshotResultWidget(
                        context, snapshot);
                    if (result != null) {
                      return result;
                    }

                    var vouchers = snapshot.data ?? [];

                    if (vouchers.isEmpty) {
                      return const Center(child: Text('Không có voucher nào'));
                    }

                    mockVouchers = vouchers;

                    return _createListVoucher();
                  }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              _presenter?.handleSelectVoucher(selectedVoucher);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Palette.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selectedVoucher == null
                  ? 'Không sử dụng voucher'
                  : 'Áp dụng voucher',
              style: TextDecor.robo16Medi.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createListVoucher() {
    return ListView.builder(
      itemCount: mockVouchers.length,
      itemBuilder: (context, index) {
        final voucher = mockVouchers[index];
        final isEligible = _isVoucherEligible(voucher);
        final isSelected =
            selectedVoucher?.voucherID == voucher.voucherID;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Opacity(
            opacity: isEligible ? 1.0 : 0.5,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Palette.primaryColor
                      : (isEligible
                      ? Colors.grey.shade300
                      : Colors.grey.shade400),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  VoucherItem(
                    voucher: voucher,
                    isShop: false,
                    onTap: isEligible
                        ? () {
                      setState(() {
                        selectedVoucher =
                        isSelected ? null : voucher;
                      });
                    }
                        : null,
                  ),
                  // Overlay checkbox
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Radio<VoucherModel>(
                      value: voucher,
                      groupValue: selectedVoucher,
                      onChanged: isEligible
                          ? (value) {
                        setState(() {
                          selectedVoucher = value;
                        });
                      }
                          : null,
                      activeColor: Palette.primaryColor,
                    ),
                  ),
                  // Overlay thông báo nếu không đủ điều kiện
                  if (!isEligible)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red.shade300,
                              ),
                            ),
                            child: Text(
                              voucher.quantity! <= 0
                                  ? 'Hết lượt sử dụng'
                                  : voucher.endDate!
                                  .isBefore(DateTime.now())
                                  ? 'Đã hết hạn'
                                  : 'Không đủ điều kiện',
                              style: TextDecor.robo12.copyWith(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void onPopContext() {
    // TODO: implement onPopContext
  }

  @override
  void onVoucherPressed(VoucherModel? voucher) {
    Navigator.pop(context, selectedVoucher);
  }

  @override
  void onWaitingProgressBar() {
    // TODO: implement onWaitingProgressBar
  }
}
