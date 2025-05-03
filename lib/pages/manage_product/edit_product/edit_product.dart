import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcplus/pages/manage_product/edit_product/edit_product_contract.dart';
import 'package:pcplus/pages/manage_product/edit_product/edit_product_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/objects/image_data.dart';
import '../../../models/items/item_model.dart';
import '../../widgets/util_widgets.dart';

class EditProduct extends StatefulWidget {
  const EditProduct({super.key});
  static const String routeName = 'edit_product';

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> implements EditProductContract {
  final _formKey = GlobalKey<FormState>();
  EditProductPresenter? _presenter;
  List<ImageData> _images = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    _presenter = EditProductPresenter(this);
    // ItemModel itemModel = _shopSingleton.editedItem!.product!;
    // _nameController.text = itemModel.name!;
    // _detailController.text = itemModel.detail!;
    // _descriptionController.text = itemModel.description!;
    // _priceController.text = itemModel.price.toString();
    // _amountController.text = itemModel.stock.toString();
    // for (String url in itemModel.reviewImages!) {
    //   ImageData imageData = ImageData(
    //       path: url,
    //       isNew: false
    //   );
    //   _images.add(imageData);
    // }

    super.initState();
  }

  // Hàm chọn ảnh từ thiết bị
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        ImageData imageData = ImageData(
          path: pickedFile.path,
          isNew: true,
          file: File(pickedFile.path)
        );
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

  @override
  Widget build(BuildContext context) {
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
                  controller: _nameController,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên sản phẩm';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
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
                SizedBox(height: 16),
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
                SizedBox(height: 16),
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
                SizedBox(height: 16),
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
                SizedBox(height: 16),
                // Ảnh minh hoạ
                Text(
                  "Ảnh minh hoạ:",
                  style: TextDecor.robo16,
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          child:
                            _images[index].isNew == false ?
                              Image.network(
                                _images[index].path,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover
                              )
                              :
                              Image.file(_images[index].file!,
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
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
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
                      // Xử lý logic sửa sản phẩm tại đây
                      _presenter?.handleEditProduct(
                          name: _nameController.text.trim(),
                          description: _descriptionController.text.trim(),
                          detail: _detailController.text.trim(),
                          price: int.parse(_priceController.text.trim()),
                          amount: int.parse(_amountController.text.trim()),
                          images: _images
                      );
                    }
                  },
                  child: Text(
                    "CẬP NHẬT",
                    style: TextDecor.robo18Semi,
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Palette.main1,
                  ),
                ),
                const Gap(10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "HUỶ",
                    style: TextDecor.robo18Semi,
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.orangeAccent,
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
  void onEditFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onEditSucceeded() {
    UtilWidgets.createSnackBar(context, "Cập nhật thành công");
  }
}
