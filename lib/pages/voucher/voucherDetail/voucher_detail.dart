// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:pcplus/component/voucher_argument.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/vouchers/voucher_model.dart';
import 'package:pcplus/pages/voucher/voucherDetail/voucher_detail_contract.dart';
import 'package:pcplus/pages/voucher/voucherDetail/voucher_detail_presenter.dart';
import 'package:pcplus/pages/voucher/editvoucher/edit_voucher.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/widgets/util_widgets.dart';

class VoucherDetail extends StatefulWidget {
  const VoucherDetail({super.key});
  static const String routeName = 'voucher_detail';

  @override
  State<VoucherDetail> createState() => _VoucherDetailState();
}

class _VoucherDetailState extends State<VoucherDetail>
    implements VoucherDetailContract {
  // ignore: unused_field
  VoucherDetailPresenter? _presenter;
  VoucherModel? _voucher;
  String? _voucherId;
  bool isShop = false;
  bool _isFirstLoad = true;

  @override
  void initState() {
    _presenter = VoucherDetailPresenter(this);
    isShop = SessionController.getInstance().isShop();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      if (_voucherId == null) {
        final args =
            ModalRoute.of(context)?.settings.arguments as VoucherArgument?;
        if (args != null) {
          _voucher = args.data;
          _voucherId = _voucher!.voucherID;
        }
      }
      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    _presenter?.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatStartDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isShop ? 'QUẢN LÝ VOUCHER' : 'CHI TIẾT VOUCHER',
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
        actions: isShop && _voucher != null
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 24,
                    color: Palette.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      EditVoucher.routeName,
                      arguments: VoucherArgument(data: _voucher!),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ]
            : null,
        centerTitle: true,
      ),
      body: _voucher == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const Gap(20),
                  _buildVoucherCard(),
                  const Gap(20),
                  _buildVoucherInfo(),
                  // if (isShop) ...[
                  //   const Gap(20),
                  //   _buildShopStatistics(),
                  // ],
                  const Gap(20),
                  isShop ? _buildShopManagement() : _buildUsageInfo(),
                  const Gap(20),
                ],
              ),
            ),
    );
  }

  Widget _buildVoucherCard() {
    final now = DateTime.now();
    final isExpired = _voucher!.endDate!.isBefore(now);
    final isNotStarted =
        _voucher!.startDate != null && _voucher!.startDate!.isAfter(now);
    final isOutOfStock = _voucher!.quantity! <= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isExpired || isOutOfStock
                  ? [Colors.grey.shade400, Colors.grey.shade500]
                  : isNotStarted
                      ? [Colors.orange.shade400, Colors.orange.shade600]
                      : [
                          Palette.primaryColor,
                          Palette.main1,
                        ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -40,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Voucher name
                    Text(
                      _voucher!.name ?? 'Voucher',
                      style: TextDecor.robo24Bold.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    const Gap(8),

                    // Discount amount
                    Row(
                      children: [
                        const Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 20,
                        ),
                        const Gap(8),
                        Text(
                          'Giảm ${_formatCurrency(_voucher!.discount!)}',
                          style: TextDecor.robo18Bold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Bottom info
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Số lượng còn lại',
                                  style: TextDecor.robo12.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  '${_voucher!.quantity}',
                                  style: TextDecor.robo16Medi.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Hạn sử dụng',
                                  style: TextDecor.robo12.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  _formatDate(_voucher!.endDate!),
                                  style: TextDecor.robo16Medi.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_voucher!.startDate != null) ...[
                          const Gap(12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const Gap(8),
                              Row(
                                children: [
                                  Text(
                                    'Hiệu lực từ: ',
                                    style: TextDecor.robo14.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  Text(
                                    _formatStartDate(_voucher!.startDate!),
                                    style: TextDecor.robo16Medi.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Status overlay
              if (isExpired || isOutOfStock)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isNotStarted ? Colors.orange : Colors.red,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'HẾT HẠN',
                        style: TextDecor.robo16Medi.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
  }

  Widget _buildVoucherInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Thông tin voucher',
            style: TextDecor.robo18Bold.copyWith(
              color: Colors.black87,
            ),
          ),
          const Gap(16),
          _buildInfoRow(
            icon: Icons.description,
            title: 'Mô tả',
            content: _voucher!.description ?? '',
          ),
          if (_voucher!.startDate != null) ...[
            const Gap(16),
            _buildInfoRow(
              icon: Icons.access_time,
              title: 'Thời gian bắt đầu',
              content: _formatStartDate(_voucher!.startDate!),
            ),
          ],
          const Gap(16),
          _buildInfoRow(
            icon: Icons.event,
            title: 'Thời gian kết thúc',
            content: _formatDate(_voucher!.endDate!),
          ),
          const Gap(16),
          _buildInfoRow(
            icon: Icons.shopping_cart,
            title: 'Điều kiện áp dụng',
            content:
                'Đơn hàng tối thiểu ${_formatCurrency(_voucher!.condition!)}',
          ),
          const Gap(16),
          _buildInfoRow(
            icon: Icons.discount,
            title: 'Giảm giá',
            content: _formatCurrency(_voucher!.discount!),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Hướng dẫn sử dụng',
            style: TextDecor.robo18Bold.copyWith(
              color: Colors.black87,
            ),
          ),
          const Gap(16),
          _buildUsageStep(
            step: '1',
            title: 'Thêm sản phẩm vào giỏ hàng',
            description: 'Chọn sản phẩm bạn muốn mua và thêm vào giỏ hàng',
          ),
          const Gap(12),
          _buildUsageStep(
            step: '2',
            title: 'Áp dụng voucher',
            description: 'Tại trang thanh toán, nhập mã voucher để giảm giá',
          ),
          const Gap(12),
          _buildUsageStep(
            step: '3',
            title: 'Hoàn tất đơn hàng',
            description: 'Kiểm tra thông tin và hoàn tất thanh toán',
          ),
        ],
      ),
    );
  }

  Widget _buildShopManagement() {
    final now = DateTime.now();
    final isExpired = _voucher!.endDate!.isBefore(now);
    final isNotStarted =
        _voucher!.startDate != null && _voucher!.startDate!.isAfter(now);
    final isOutOfStock = _voucher!.quantity! <= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Quản lý voucher',
            style: TextDecor.robo18Bold.copyWith(
              color: Colors.black87,
            ),
          ),
          const Gap(16),

          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isExpired || isOutOfStock)
                  ? Colors.red.withOpacity(0.1)
                  : isNotStarted
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isExpired || isOutOfStock)
                    ? Colors.red.withOpacity(0.3)
                    : isNotStarted
                        ? Colors.orange.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  (isExpired || isOutOfStock)
                      ? Icons.warning
                      : isNotStarted
                          ? Icons.schedule
                          : Icons.check_circle,
                  color: (isExpired || isOutOfStock)
                      ? Colors.red
                      : isNotStarted
                          ? Colors.orange
                          : Colors.green,
                  size: 24,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng thái voucher',
                        style: TextDecor.robo14.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const Gap(4),
                      Text(
                        isExpired
                            ? 'Đã hết hạn'
                            : (isOutOfStock
                                ? 'Hết lượt sử dụng'
                                : isNotStarted
                                    ? 'Chưa bắt đầu'
                                    : 'Đang hoạt động'),
                        style: TextDecor.robo16Medi.copyWith(
                          color: (isExpired || isOutOfStock)
                              ? Colors.red
                              : isNotStarted
                                  ? Colors.orange
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Gap(16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      EditVoucher.routeName,
                      arguments: VoucherArgument(data: _voucher!),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                  label: const Text('Chỉnh sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showDeleteConfirmDialog();
                  },
                  icon: const Icon(Icons.delete, size: 20, color: Colors.white),
                  label: const Text('Xóa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog() {
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
            'Bạn có chắc chắn muốn xóa voucher "${_voucher!.name}"?\nHành động này không thể hoàn tác.',
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
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
                UtilWidgets.createSnackBar(
                  context,
                  'Đã xóa voucher: ${_voucher!.name}',
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

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Palette.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Palette.primaryColor,
            size: 20,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextDecor.robo14.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(4),
              Text(
                content,
                style: TextDecor.robo16.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageStep({
    required String step,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Palette.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: TextDecor.robo14.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextDecor.robo16Medi.copyWith(
                  color: Colors.black87,
                ),
              ),
              const Gap(4),
              Text(
                description,
                style: TextDecor.robo14.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
