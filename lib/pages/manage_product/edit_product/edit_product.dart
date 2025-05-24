import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcplus/pages/manage_product/edit_product/edit_product_contract.dart';
import 'package:pcplus/pages/manage_product/edit_product/edit_product_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/objects/image_data.dart';
import 'package:pcplus/const/item_type.dart';
import '../../../component/item_argument.dart';
import '../../../models/items/item_model.dart';
import '../../../models/items/color_model.dart';
import '../../widgets/util_widgets.dart';

class ColorInfo {
  String name;
  String? imageUrl;
  File? imageFile;
  bool isNew;

  ColorInfo(
      {required this.name, this.imageUrl, this.imageFile, this.isNew = false});
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

class EditProduct extends StatefulWidget {
  const EditProduct({super.key});
  static const String routeName = 'edit_product';

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct>
    implements EditProductContract {
  final _formKey = GlobalKey<FormState>();
  EditProductPresenter? _presenter;
  List<ImageData> _images = [];
  final List<ColorInfo> _colors = [];
  final ImagePicker _picker = ImagePicker();
  String? _selectedProductType;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _priceOriginalController =
      TextEditingController();
  final TextEditingController _priceSaleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    _presenter = EditProductPresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as ItemArgument;

    if (_presenter!.itemWithSeller == null) {
      _presenter!.itemWithSeller = args.data;
      ItemModel itemModel = args.data.item;

      _nameController.text = itemModel.name!;
      _detailController.text = itemModel.detail!;
      _descriptionController.text = itemModel.description!;
      _priceOriginalController.text = itemModel.price.toString();
      _priceSaleController.text =
          itemModel.discountPrice?.toString() ?? itemModel.price.toString();
      _amountController.text = itemModel.stock.toString();

      // Kiểm tra và đặt giá trị loại sản phẩm
      _selectedProductType = itemModel.itemType;
      // Đảm bảo loại sản phẩm có trong danh sách, nếu không thì đặt là "Khác"
      if (!ItemType.collections.contains(_selectedProductType)) {
        _selectedProductType = "Khác";
      }

      // Nạp danh sách hình ảnh
      if (itemModel.reviewImages != null &&
          itemModel.reviewImages!.isNotEmpty) {
        for (String imagePath in itemModel.reviewImages!) {
          _images.add(ImageData(
            path: imagePath,
            isNew: false,
          ));
        }
      }

      // Nạp danh sách màu sắc
      if (itemModel.colors != null && itemModel.colors!.isNotEmpty) {
        for (ColorModel color in itemModel.colors!) {
          _colors.add(ColorInfo(
              name: color.name!, imageUrl: color.image, isNew: false));
        }
      }
    }
  }

  // Hàm chọn ảnh từ thiết bị
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        ImageData imageData = ImageData(
            path: pickedFile.path, isNew: true, file: File(pickedFile.path));
        _images.add(imageData);
      });
    }
  }

  // Hàm xoá ảnh
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // Hàm chọn ảnh cho màu
  Future<void> _pickColorImage(int index) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _colors[index].imageFile = File(pickedFile.path);
        _colors[index].isNew = true;
      });
    }
  }

  // Hàm thêm màu mới
  void _addNewColor() {
    setState(() {
      _colors.add(ColorInfo(name: '', isNew: true));
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
    // Thêm kiểm tra dữ liệu đã sẵn sàng chưa
    bool isDataReady =
        _presenter?.itemWithSeller != null && _selectedProductType != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EDIT PRODUCT',
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
      body: !isDataReady
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      _buildUpdateButton(),
                      const Gap(10),
                      _buildCancelButton(),
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
      items: ItemType.collections.map((String type) {
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
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _images[index].isNew == false
                        ? Image.network(_images[index].path,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover)
                        : Image.file(
                            _images[index].file!,
                            width: double.infinity,
                            height: double.infinity,
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
                              color: Colors.black.withOpacity(0.2),
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
                    color: Colors.black.withOpacity(0.05),
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
                        child: _buildColorImageWidget(color, index),
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

  Widget _buildColorImageWidget(ColorInfo color, int index) {
    if (color.isNew && color.imageFile != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.file(
              color.imageFile!,
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
                  color.imageFile = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
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
      );
    } else if (!color.isNew && color.imageUrl != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.network(
              color.imageUrl!,
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
                  color.imageUrl = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
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
      );
    } else {
      return Center(
        child: IconButton(
          onPressed: () => _pickColorImage(index),
          icon: const Icon(Icons.add_photo_alternate, size: 28),
          color: Palette.main1,
        ),
      );
    }
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          // Xử lý logic sửa sản phẩm tại đây
          _presenter?.handleEditProduct(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              detail: _detailController.text.trim(),
              price: int.parse(_priceOriginalController.text.trim()),
              amount: int.parse(_amountController.text.trim()),
              images: _images);
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: Palette.main1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        "CẬP NHẬT",
        style: TextDecor.robo18Semi,
      ),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: Colors.orangeAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        "HUỶ",
        style: TextDecor.robo18Semi,
      ),
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
  void onEditFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onEditSucceeded() {
    UtilWidgets.createSnackBar(context, "Cập nhật thành công");
  }
}
