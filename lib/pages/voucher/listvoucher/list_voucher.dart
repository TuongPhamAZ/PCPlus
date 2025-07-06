import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/component/voucher_argument.dart';
import 'package:pcplus/models/vouchers/voucher_model.dart';
import 'package:pcplus/pages/voucher/listvoucher/list_voucher_contract.dart';
import 'package:pcplus/pages/voucher/listvoucher/list_voucher_presenter.dart';
import 'package:pcplus/pages/voucher/widget/voucher_item.dart';
import 'package:pcplus/pages/voucher/editvoucher/edit_voucher.dart';
import 'package:pcplus/pages/voucher/voucherDetail/voucher_detail.dart';
import 'package:pcplus/pages/voucher/addvoucher/add_voucher.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/widgets/util_widgets.dart';

import '../../../component/shop_argument.dart';
import '../../../controller/session_controller.dart';

class ListVoucher extends StatefulWidget {
  const ListVoucher({super.key});
  static const String routeName = 'list_voucher';

  @override
  State<ListVoucher> createState() => _ListVoucherState();
}

class _ListVoucherState extends State<ListVoucher>
    implements ListVoucherContract {
  ListVoucherPresenter? _presenter;
  bool isShop = false;
  String selectedFilter = 'all';
  bool _isFirstLoad = true;

  @override
  void initState() {
    // isShop = SessionController.getInstance().isShop();
    _presenter = ListVoucherPresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isFirstLoad) {
      isShop = SessionController.getInstance().isShop();
      final args = ModalRoute.of(context)!.settings.arguments as ShopArgument;
      _presenter!.shopModel = args.shop;

      loadData();
      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    _presenter?.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (mounted) {
      await _presenter?.getData();
    }
  }

  List<VoucherModel> _getFilteredVouchers(List<VoucherModel> vouchers) {
    if (!isShop) {
      // Người dùng thường thấy voucher còn hoạt động và voucher chưa bắt đầu (để biết thời gian săn sale)
      final now = DateTime.now();
      return vouchers.where((voucher) {
        final isNotExpired = voucher.endDate!.isAfter(now);
        final hasQuantity = voucher.quantity! > 0;
        return isNotExpired &&
            hasQuantity; // Bao gồm cả voucher chưa bắt đầu và đang hoạt động
      }).toList();
    } else {
      // Shop owner có thể filter theo lựa chọn
      switch (selectedFilter) {
        case 'active':
          return vouchers.where((voucher) {
            return voucher.isValid();
          }).toList();
        case 'pending':
          return vouchers.where((voucher) {
            return voucher.startDate != null &&
                voucher.startDate!.isAfter(DateTime.now()) &&
                voucher.quantity! > 0;
          }).toList();
        case 'expired':
          return vouchers.where((voucher) {
            return voucher.endDate!.isBefore(DateTime.now());
          }).toList();
        case 'out_of_stock':
          return vouchers.where((voucher) {
            return voucher.quantity! <= 0;
          }).toList();
        default:
          return List.from(vouchers);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isShop ? 'QUẢN LÝ VOUCHER' : 'DANH SÁCH VOUCHER',
          style: TextDecor.robo18Bold.copyWith(
            color: Palette.primaryColor,
            fontSize: 18,
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
        actions: isShop
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 26,
                    color: Palette.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(AddVoucher.routeName);
                  },
                ),
                const SizedBox(width: 8),
              ]
            : null,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter section (chỉ hiển thị cho shop)
          if (isShop) _buildFilterSection(),

          // Content will be built in StreamBuilder below

          // Voucher list
          Expanded(
            child: StreamBuilder<List<VoucherModel>>(
                stream: _presenter!.voucherStream,
                builder: (context, snapshot) {
                  Widget? result =
                      UtilWidgets.createSnapshotResultWidget(context, snapshot);
                  if (result != null) {
                    return result;
                  }

                  var vouchers = snapshot.data ?? [];

                  if (vouchers.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Get filtered vouchers
                  final filteredVouchers = _getFilteredVouchers(vouchers);

                  return Column(
                    children: [
                      // Statistics section (chỉ hiển thị cho shop)
                      if (isShop) _buildStatisticsSection(vouchers),

                      // Voucher list
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: ListView.builder(
                            itemCount: filteredVouchers.length,
                            itemBuilder: (context, index) {
                              final voucher = filteredVouchers[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: VoucherItem(
                                  voucher: voucher,
                                  isShop: isShop,
                                  onTap: () =>
                                      _presenter!.handleViewVoucher(voucher),
                                  onEdit: isShop
                                      ? () =>
                                          _presenter!.handleEditVoucher(voucher)
                                      : null,
                                  onDelete: isShop
                                      ? () => _showDeleteVoucherDialog(voucher)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lọc voucher',
            style: TextDecor.robo16Medi.copyWith(
              color: Colors.black87,
            ),
          ),
          const Gap(12),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('all', 'Tất cả'),
              _buildFilterChip('active', 'Đang hoạt động'),
              _buildFilterChip('pending', 'Chưa bắt đầu'),
              _buildFilterChip('expired', 'Hết hạn'),
              _buildFilterChip('out_of_stock', 'Hết lượt'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
        // Filter will be applied in StreamBuilder
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? Palette.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Palette.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextDecor.robo14.copyWith(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(List<VoucherModel> vouchers) {
    final totalVouchers = vouchers.length;
    final activeVouchers = vouchers.where((v) => v.isValid()).length;
    final pendingVouchers = vouchers
        .where((v) =>
            v.startDate != null &&
            v.startDate!.isAfter(DateTime.now()) &&
            v.quantity! > 0)
        .length;
    final expiredVouchers =
        vouchers.where((v) => v.endDate!.isBefore(DateTime.now())).length;
    final outOfStockVouchers = vouchers
        .where((v) => v.quantity! <= 0 && v.endDate!.isAfter(DateTime.now()))
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan',
            style: TextDecor.robo16Medi.copyWith(
              color: Colors.black87,
            ),
          ),
          const Gap(12),
          // First row: Total, Active, Pending
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng số',
                  totalVouchers.toString(),
                  Colors.blue,
                  Icons.local_offer,
                ),
              ),
              const Gap(8),
              Expanded(
                child: _buildStatCard(
                  'Hoạt động',
                  activeVouchers.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const Gap(8),
              Expanded(
                child: _buildStatCard(
                  'Chưa bắt đầu',
                  pendingVouchers.toString(),
                  Colors.amber,
                  Icons.schedule_send,
                ),
              ),
            ],
          ),
          const Gap(8),
          // Second row: Expired, Out of stock
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Hết hạn',
                  expiredVouchers.toString(),
                  Colors.red,
                  Icons.schedule,
                ),
              ),
              const Gap(8),
              Expanded(
                child: _buildStatCard(
                  'Hết lượt',
                  outOfStockVouchers.toString(),
                  Colors.orange,
                  Icons.inventory,
                ),
              ),
              const Gap(8),
              // Empty space to balance the row
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const Gap(4),
          Text(
            value,
            style: TextDecor.robo16Medi.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextDecor.robo12.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    if (!isShop) {
      // Message cho người dùng thường
      message = 'Hiện tại không có voucher nào khả dụng';
      icon = Icons.local_offer_outlined;
    } else {
      // Message cho shop owner theo filter
      switch (selectedFilter) {
        case 'active':
          message = 'Không có voucher nào đang hoạt động';
          icon = Icons.check_circle_outline;
          break;
        case 'pending':
          message = 'Không có voucher nào chưa bắt đầu';
          icon = Icons.schedule_send;
          break;
        case 'expired':
          message = 'Không có voucher nào hết hạn';
          icon = Icons.schedule;
          break;
        case 'out_of_stock':
          message = 'Không có voucher nào hết lượt';
          icon = Icons.inventory_outlined;
          break;
        default:
          message = 'Chưa có voucher nào';
          icon = Icons.local_offer_outlined;
      }
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const Gap(16),
            Text(
              message,
              style: TextDecor.robo16.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (isShop && selectedFilter == 'all') ...[
              const Gap(16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AddVoucher.routeName);
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Tạo voucher đầu tiên'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteVoucherDialog(VoucherModel voucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning,
                color: Colors.red,
                size: 24,
              ),
              const Gap(8),
              Text(
                'Xác nhận xóa',
                style: TextDecor.robo18Bold,
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa voucher "${voucher.name}"?\nHành động này không thể hoàn tác.',
            style: TextDecor.robo14,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Hủy',
                style: TextDecor.robo14.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Remove voucher from list
                _presenter!.handleDeleteVoucher(voucher);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Xóa',
                style: TextDecor.robo14.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
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
  void onVoucherDelete(VoucherModel voucher) {
    UtilWidgets.createSnackBar(
      context,
      'Đã xóa voucher: ${voucher.name}',
    );
  }

  // Navigation functions
  @override
  void onVoucherEdit(VoucherModel voucher) {
    Navigator.of(context).pushNamed(
      EditVoucher.routeName,
      arguments: VoucherArgument(data: voucher),
    );
  }

  @override
  void onVoucherPressed(VoucherModel voucher) {
    Navigator.of(context).pushNamed(
      VoucherDetail.routeName,
      arguments: VoucherArgument(data: voucher),
    );
  }
}
