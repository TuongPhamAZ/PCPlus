import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcplus/const/item_type.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product_contract.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../../const/product_types.dart';
import '../../widgets/util_widgets.dart';

class ColorInfo {
  String name;
  File? image;

  ColorInfo({required this.name, this.image});
}

// Custom TextField widget để tái sử dụng
class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.initialValue,
    this.validator,
    this.maxLines,
    this.minLines,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextDecor.robo16,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});
  static const String routeName = 'add_product';

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> implements AddProductContract {
  AddProductPresenter? _presenter;

  final _formKey = GlobalKey<FormState>();

  List<PlatformFile> _images = [];
  final List<ColorInfo> _colors = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _priceOriginalController =
      TextEditingController();
  final TextEditingController _priceSaleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedProductType;

  @override
  void initState() {
    _presenter = AddProductPresenter(this);
    super.initState();
  }

  // Hàm chọn ảnh từ thiết bị
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true, // cần thiết để lấy bytes
    );
    if (result != null) {
      setState(() {
        _images = result.files;
      });
    }
  }

  // Hàm chọn ảnh cho màu
  Future<void> _pickColorImage(int index) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _colors[index].image = File(pickedFile.path);
      });
    }
  }

  // Hàm xoá ảnh
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // Hàm thêm màu mới
  void _addNewColor() {
    setState(() {
      _colors.add(ColorInfo(name: ''));
    });
  }

  // Hàm xóa màu
  void _removeColor(int index) {
    setState(() {
      _colors.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SẢN PHẨM MỚI',
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductNameField(),
                const SizedBox(height: 16),
                _buildProductTypeDropdown(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildDetailField(),
                const SizedBox(height: 16),
                _buildPriceFields(),
                const SizedBox(height: 16),
                _buildAmountField(),
                const SizedBox(height: 16),
                _buildProductImages(),
                const SizedBox(height: 16),
                _buildColorSection(),
                const SizedBox(height: 32),
                _buildAddButton(),
                const Gap(16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductNameField() {
    return CustomTextField(
      labelText: "Tên sản phẩm",
      controller: _nameController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập tên sản phẩm';
        }
        return null;
      },
    );
  }

  Widget _buildProductTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Loại sản phẩm",
        labelStyle: TextDecor.robo16,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      value: _selectedProductType,
      items: ProductTypes.all.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedProductType = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn loại sản phẩm';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return CustomTextField(
      labelText: "Mô tả",
      controller: _descriptionController,
      maxLines: 3,
      minLines: 1,
    );
  }

  Widget _buildDetailField() {
    return CustomTextField(
      labelText: "Giới thiệu chi tiết",
      controller: _detailController,
      maxLines: 200,
      minLines: 1,
    );
  }

  Widget _buildPriceFields() {
    return Column(
      children: [
        CustomTextField(
          labelText: "Giá gốc",
          controller: _priceOriginalController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: "Giá bán",
          controller: _priceSaleController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return CustomTextField(
      labelText: "Số lượng",
      controller: _amountController,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildProductImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ảnh minh hoạ:",
          style: TextDecor.robo16.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1, // Tỷ lệ 1:1 để tạo hình vuông
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _images[index].bytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate, size: 24),
            label: Text("Tải ảnh lên", style: TextDecor.robo16),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: Palette.main1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Màu sắc:",
            style: TextDecor.robo16.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._colors.asMap().entries.map((entry) {
            int index = entry.key;
            ColorInfo color = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      labelText: "Tên màu",
                      initialValue: color.name,
                      onChanged: (value) {
                        setState(() {
                          color.name = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: AspectRatio(
                      aspectRatio: 1, // Tỷ lệ 1:1 để tạo hình vuông
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: color.image != null
                            ? Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Image.file(
                                      color.image!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -10,
                                    right: -10,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          color.image = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: IconButton(
                                  onPressed: () => _pickColorImage(index),
                                  icon: const Icon(Icons.add_photo_alternate,
                                      size: 28),
                                  color: Palette.main1,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => _removeColor(index),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: _addNewColor,
              icon: const Icon(Icons.add, size: 24),
              label: Text("Thêm màu", style: TextDecor.robo16),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: const BorderSide(color: Palette.main1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          // Xử lý logic thêm sản phẩm tại đây
          _presenter?.handleAddProduct(
            name: _nameController.text.trim(),
            itemType: _selectedProductType!,
            description: _descriptionController.text.trim(),
            detail: _detailController.text.trim(),
            price: int.parse(_priceOriginalController.text.trim()),
            amount: int.parse(_amountController.text.trim()),
            discountPrice: int.parse(_priceSaleController.text.trim()),
            images: _images,
            colors: _colors,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56), // Tăng cao nút
        backgroundColor: Palette.main1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        "Thêm sản phẩm",
        style: TextDecor.robo18Semi,
      ),
    );
  }

  // =================================================================

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }

  @override
  void onAddFailed(String message) {
    _showResultDialog(
      title: "Thất bại",
      message: "Thêm sản phẩm thất bại.",
      isSuccess: false,
    );
  }

  @override
  void onAddSuccessWithVector() {
    _showResultDialog(
      title: "Thành công",
      message: "Đã thêm sản phẩm thành công - Sẵn sàng cho tìm kiếm",
      isSuccess: true,
    );
  }

  @override
  void onAddSuccessWithoutVector() {
    _showResultDialog(
      title: "Thành công",
      message: "Đã thêm sản phẩm thành công - Chưa thể tìm kiếm",
      isSuccess: true,
    );
  }

  // Hiển thị dialog kết quả
  void _showResultDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextDecor.robo18Semi.copyWith(
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextDecor.robo16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                if (isSuccess) {
                  _clearForm(); // Clear form nếu thành công
                }
              },
              child: Text(
                "OK",
                style: TextDecor.robo16Semi.copyWith(
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Clear form sau khi thêm thành công
  void _clearForm() {
    setState(() {
      _nameController.clear();
      _amountController.clear();
      _priceOriginalController.clear();
      _priceSaleController.clear();
      _detailController.clear();
      _descriptionController.clear();
      _images.clear();
      _colors.clear();
      _selectedProductType = null;
    });
  }
}
