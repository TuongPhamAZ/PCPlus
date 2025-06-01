import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/component/voucher_argument.dart';
import 'package:pcplus/models/vouchers/voucher_model.dart';
import 'package:pcplus/pages/voucher/widget/voucher_item.dart';
import 'package:pcplus/pages/voucher/editvoucher/edit_voucher.dart';
import 'package:pcplus/pages/voucher/voucherDetail/voucher_detail.dart';
import 'package:pcplus/pages/voucher/addvoucher/add_voucher.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/widgets/util_widgets.dart';

class ListVoucher extends StatefulWidget {
  const ListVoucher({super.key});
  static const String routeName = 'list_voucher';

  @override
  State<ListVoucher> createState() => _ListVoucherState();
}

class _ListVoucherState extends State<ListVoucher> {
  bool isShop = false;
  String selectedFilter = 'all';
  List<VoucherModel> _mockVouchers = [];
  List<VoucherModel> _filteredVouchers = [];

  @override
  void initState() {
    // isShop = SessionController.getInstance().isShop();
    _initMockVouchers();
    _applyFilter();
    super.initState();
  }

  void _initMockVouchers() {
    _mockVouchers = [
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
        description: "Voucher giảm 20% tối đa 100,000đ",
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
        quantity: 0, // Out of stock
      ),
      VoucherModel(
        voucherID: "4",
        name: "Black Friday",
        description: "Giảm 300,000đ cho đơn hàng trên 1 triệu",
        condition: 1000000,
        endDate: DateTime.now().subtract(const Duration(days: 1)), // Expired
        discount: 300000,
        quantity: 25,
      ),
      VoucherModel(
        voucherID: "5",
        name: "Sinh nhật shop",
        description: "Voucher sinh nhật giảm 100,000đ",
        condition: 300000,
        endDate: DateTime.now().add(const Duration(days: 60)),
        discount: 100000,
        quantity: 200,
      ),
      VoucherModel(
        voucherID: "6",
        name: "Mùa hè sôi động",
        description: "Voucher mùa hè giảm 15% tối đa 75,000đ",
        condition: 150000,
        endDate: DateTime.now().add(const Duration(days: 45)),
        discount: 75000,
        quantity: 80,
      ),
    ];
  }

  void _applyFilter() {
    setState(() {
      if (!isShop) {
        // Người dùng thường chỉ thấy voucher còn hoạt động
        _filteredVouchers = _mockVouchers.where((voucher) {
          return voucher.endDate!.isAfter(DateTime.now()) &&
              voucher.quantity! > 0;
        }).toList();
      } else {
        // Shop owner có thể filter theo lựa chọn
        switch (selectedFilter) {
          case 'active':
            _filteredVouchers = _mockVouchers.where((voucher) {
              return voucher.endDate!.isAfter(DateTime.now()) &&
                  voucher.quantity! > 0;
            }).toList();
            break;
          case 'expired':
            _filteredVouchers = _mockVouchers.where((voucher) {
              return voucher.endDate!.isBefore(DateTime.now());
            }).toList();
            break;
          case 'out_of_stock':
            _filteredVouchers = _mockVouchers.where((voucher) {
              return voucher.quantity! <= 0;
            }).toList();
            break;
          default:
            _filteredVouchers = List.from(_mockVouchers);
        }
      }
    });
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

          // Statistics section (chỉ hiển thị cho shop)
          if (isShop) _buildStatisticsSection(),

          // Voucher list
          Expanded(
            child: _filteredVouchers.isEmpty
                ? _buildEmptyState()
                : _buildVoucherList(),
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
        _applyFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildStatisticsSection() {
    final totalVouchers = _mockVouchers.length;
    final activeVouchers = _mockVouchers
        .where((v) => v.endDate!.isAfter(DateTime.now()) && v.quantity! > 0)
        .length;
    final expiredVouchers =
        _mockVouchers.where((v) => v.endDate!.isBefore(DateTime.now())).length;
    final outOfStockVouchers = _mockVouchers
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

  Widget _buildVoucherList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ListView.builder(
        itemCount: _filteredVouchers.length,
        itemBuilder: (context, index) {
          final voucher = _filteredVouchers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: VoucherItem(
              voucher: voucher,
              isShop: isShop,
              onTap: () => _navigateToVoucherDetail(voucher.voucherID!),
              onEdit: isShop
                  ? () => _navigateToEditVoucher(voucher.voucherID!)
                  : null,
              onDelete: isShop
                  ? () => _showDeleteVoucherDialog(
                        voucher.voucherID!,
                        voucher.name!,
                      )
                  : null,
            ),
          );
        },
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

  // Navigation functions
  void _navigateToVoucherDetail(String voucherId) {
    VoucherModel? voucher = _mockVouchers.firstWhere(
      (v) => v.voucherID == voucherId,
      orElse: () => VoucherModel(
        voucherID: voucherId,
        name: "Unknown Voucher",
        description: "Voucher không xác định",
        condition: 0,
        endDate: DateTime.now().add(const Duration(days: 30)),
        discount: 0,
        quantity: 0,
      ),
    );

    Navigator.of(context).pushNamed(
      VoucherDetail.routeName,
      arguments: VoucherArgument(data: voucher),
    );
  }

  void _navigateToEditVoucher(String voucherId) {
    VoucherModel? voucher = _mockVouchers.firstWhere(
      (v) => v.voucherID == voucherId,
      orElse: () => VoucherModel(
        voucherID: voucherId,
        name: "Unknown Voucher",
        description: "Voucher không xác định",
        condition: 0,
        endDate: DateTime.now().add(const Duration(days: 30)),
        discount: 0,
        quantity: 0,
      ),
    );

    Navigator.of(context).pushNamed(
      EditVoucher.routeName,
      arguments: VoucherArgument(data: voucher),
    );
  }

  void _showDeleteVoucherDialog(String voucherId, String voucherName) {
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
            'Bạn có chắc chắn muốn xóa voucher "$voucherName"?\nHành động này không thể hoàn tác.',
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
                setState(() {
                  _mockVouchers.removeWhere((v) => v.voucherID == voucherId);
                });
                _applyFilter();
                UtilWidgets.createSnackBar(
                  context,
                  'Đã xóa voucher: $voucherName',
                );
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
}
