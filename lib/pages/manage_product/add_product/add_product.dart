import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product_contract.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../widgets/util_widgets.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});
  static const String routeName = 'add_product';

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> implements AddProductContract {
  AddProductPresenter? _presenter;

  final _formKey = GlobalKey<FormState>();

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    _presenter = AddProductPresenter(this);
    super.initState();
  }

  // Hàm chọn ảnh từ thiết bị
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  // Hàm xoá ảnh
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NEW PRODUCT',
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
                // Tên sản phẩm
                const Gap(10),
                TextFormField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    labelText: "Tên sản phẩm",
                    labelStyle: TextDecor.robo16,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên sản phẩm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Mô tả
                TextFormField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Mô tả",
                    labelStyle: TextDecor.robo16,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 16),
                // Giới thiệu chi tiết
                TextFormField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _detailController,
                  decoration: InputDecoration(
                    labelText: "Giới thiệu chi tiết",
                    labelStyle: TextDecor.robo16,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 200,
                  minLines: 1,
                ),
                const SizedBox(height: 16),
                // Giá
                TextFormField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: "Giá",
                    labelStyle: TextDecor.robo16,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Số lượng
                TextFormField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: "Số lượng",
                    labelStyle: TextDecor.robo16,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Ảnh minh hoạ
                Text(
                  "Ảnh minh hoạ:",
                  style: TextDecor.robo16,
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 400 / 200,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _images[index],
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
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
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
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text("Tải ảnh lên"),
                ),
                const SizedBox(height: 32),
                // Nút thêm sản phẩm
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Xử lý logic thêm sản phẩm tại đây
                      _presenter?.handleAddProduct(
                          name: _nameController.text.trim(),
                          description: _descriptionController.text.trim(),
                          detail: _detailController.text.trim(),
                          price: int.parse(_priceController.text.trim()),
                          amount: int.parse(_amountController.text.trim()),
                          images: _images
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Palette.main1,
                  ),
                  child: Text(
                    "Thêm sản phẩm",
                    style: TextDecor.robo18Semi,
                  ),
                ),
                const Gap(16),
              ],
            ),
          ),
        ),
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
  void onAddFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onAddSucceeded() {
    UtilWidgets.createSnackBar(context, "Thêm sản phẩm thành công");
    setState(() {
      _nameController.clear();
      _amountController.clear();
      _priceController.clear();
      _detailController.clear();
      _descriptionController.clear();
      _images.clear();
    });
  }
}
