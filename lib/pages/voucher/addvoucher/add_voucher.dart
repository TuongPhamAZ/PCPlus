// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:pcplus/extensions/money_format_extension.dart';
import 'package:pcplus/pages/voucher/addvoucher/add_voucher_contract.dart';
import 'package:pcplus/pages/voucher/addvoucher/add_voucher_presenter.dart';
import 'package:pcplus/pages/voucher/widget/voucher_text_field.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/widgets/util_widgets.dart';

class AddVoucher extends StatefulWidget {
  const AddVoucher({super.key});
  static const String routeName = 'add_voucher';

  @override
  State<AddVoucher> createState() => _AddVoucherState();
}

class _AddVoucherState extends State<AddVoucher> implements AddVoucherContract {
  AddVoucherPresenter? _presenter;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? _selectedEndDate;

  @override
  void initState() {
    _presenter = AddVoucherPresenter(this);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _conditionController.dispose();
    _discountController.dispose();
    _quantityController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // Hàm chọn ngày kết thúc
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Palette.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Palette.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
        _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Hàm parse số tiền từ formatted text
  int _parseFormattedNumber(String formattedText) {
    if (formattedText.isEmpty) return 0;
    return int.parse(formattedText.replaceAll(RegExp(r'[^\d]'), ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'THÊM VOUCHER MỚI',
          style: TextDecor.robo18Bold.copyWith(
            color: Palette.primaryColor,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 28,
            color: Palette.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Palette.primaryColor.withOpacity(0.1),
                        Palette.primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Palette.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Palette.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tạo voucher giảm giá',
                              style: TextDecor.robo18Bold.copyWith(
                                color: Palette.primaryColor,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              'Tăng doanh thu và thu hút khách hàng',
                              style: TextDecor.robo14.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(32),

                // Form fields
                _buildVoucherNameField(),
                const Gap(20),
                _buildDescriptionField(),
                const Gap(20),
                _buildConditionField(),
                const Gap(20),
                _buildDiscountField(),
                const Gap(20),
                _buildQuantityField(),
                const Gap(20),
                _buildEndDateField(),
                const Gap(40),
                _buildAddButton(),
                const Gap(20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tên voucher",
          style: TextDecor.robo16Medi.copyWith(
            color: Colors.black87,
          ),
        ),
        const Gap(8),
        CustomTextField(
          labelText: "Nhập tên voucher",
          controller: _nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên voucher';
            }
            if (value.length < 3) {
              return 'Tên voucher phải có ít nhất 3 ký tự';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mô tả voucher",
          style: TextDecor.robo16Medi.copyWith(
            color: Colors.black87,
          ),
        ),
        const Gap(8),
        CustomTextField(
          labelText: "Nhập mô tả chi tiết về voucher",
          controller: _descriptionController,
          maxLines: 3,
          minLines: 1,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mô tả voucher';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConditionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Điều kiện áp dụng",
          style: TextDecor.robo16Medi.copyWith(
            color: Colors.black87,
          ),
        ),
        const Gap(4),
        Text(
          "Giá trị đơn hàng tối thiểu",
          style: TextDecor.robo14.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const Gap(8),
        CustomTextField(
          labelText: "Nhập số tiền tối thiểu",
          controller: _conditionController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          suffixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'VND',
              style: TextDecor.robo14.copyWith(
                color: Palette.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập điều kiện áp dụng';
            }
            int amount = _parseFormattedNumber(value);
            if (amount <= 0) {
              return 'Điều kiện áp dụng phải lớn hơn 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDiscountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Số tiền giảm giá",
          style: TextDecor.robo16Medi.copyWith(
            color: Colors.black87,
          ),
        ),
        const Gap(8),
        CustomTextField(
          labelText: "Nhập số tiền giảm",
          controller: _discountController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          suffixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'VND',
              style: TextDecor.robo14.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số tiền giảm giá';
            }
            int amount = _parseFormattedNumber(value);
            if (amount <= 0) {
              return 'Số tiền giảm giá phải lớn hơn 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Số lượng voucher",
          style: TextDecor.robo16Medi.copyWith(
            color: Colors.black87,
          ),
        ),
        const Gap(8),
        CustomTextField(
          labelText: "Nhập số lượng",
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số lượng voucher';
            }
            int quantity = int.tryParse(value) ?? 0;
            if (quantity <= 0) {
              return 'Số lượng phải lớn hơn 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEndDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ngày kết thúc",
          style: TextDecor.robo16Medi.copyWith(
            color: Colors.black87,
          ),
        ),
        const Gap(8),
        CustomTextField(
          labelText: "Chọn ngày kết thúc",
          controller: _endDateController,
          readOnly: true,
          onTap: _selectEndDate,
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.calendar_today,
              color: Palette.primaryColor,
            ),
            onPressed: _selectEndDate,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn ngày kết thúc';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Palette.primaryColor, Palette.main1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Palette.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _presenter?.handleAddVoucher(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              condition: _parseFormattedNumber(_conditionController.text),
              endDate: _selectedEndDate!,
              discount: _parseFormattedNumber(_discountController.text),
              quantity: int.parse(_quantityController.text.trim()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 24,
            ),
            const Gap(12),
            Text(
              "Tạo voucher",
              style: TextDecor.robo18Semi.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onAddSucceeded() {
    UtilWidgets.createSnackBar(context, "Tạo voucher thành công!");
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _conditionController.clear();
      _discountController.clear();
      _quantityController.clear();
      _endDateController.clear();
      _selectedEndDate = null;
    });
  }

  @override
  void onAddFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
