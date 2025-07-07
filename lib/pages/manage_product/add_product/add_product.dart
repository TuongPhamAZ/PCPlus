import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcplus/const/item_type.dart';
import 'package:pcplus/extensions/money_format_extension.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product_contract.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product_presenter.dart';
import 'package:pcplus/pages/manage_product/widget/bottom_data_sheet.dart';
import 'package:pcplus/services/compress_service.dart';
import 'package:pcplus/services/property_service.dart';
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
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.initialValue,
    this.validator,
    this.maxLines,
    this.minLines,
    this.suffixIcon,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
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
      inputFormatters: inputFormatters,
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
        suffixIcon: suffixIcon != null
            ? Container(
                width: 30,
                alignment: Alignment.center,
                child: suffixIcon,
              )
            : null,
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

  // Helper method để parse số an toàn
  int _parseIntSafely(String text) {
    // Loại bỏ tất cả ký tự không phải số
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return 0;
    return int.parse(digitsOnly);
  }

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

  // Thuộc tính sản phẩm
  String? _selectedTinhTrang;
  String? _selectedNhaSanXuat;
  List<String> _selectedKetNoi = [];
  List<String> _selectedHDH = [];
  String? _selectedBaoHanhThoiGian;
  String? _selectedBaoHanhLoai;
  List<String> _selectedChungChi = [];
  String? _selectedVatLieu;
  final TextEditingController _kichThuocController = TextEditingController();
  String? _selectedKichThuocDonVi;
  final TextEditingController _khoiLuongController = TextEditingController();
  String? _selectedKhoiLuongDonVi;
  final TextEditingController _thongTinKhacController = TextEditingController();

  // Property data
  bool _isPropertyDataLoaded = false;
  bool _isFormSubmitted = false;

  @override
  void initState() {
    _presenter = AddProductPresenter(this);
    _loadPropertyData();
    super.initState();
  }

  Future<void> _loadPropertyData() async {
    await PropertyService.loadPropertyData();
    setState(() {
      _isPropertyDataLoaded = true;
    });
  }

  void _showMultiSelectBottomSheet({
    required String title,
    required List<String> allItems,
    required List<String> selectedItems,
    required Function(List<String>) onSelectionChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomDataSheet(
        title: title,
        allItems: allItems,
        selectedItems: selectedItems,
        onSelectionChanged: onSelectionChanged,
      ),
    );
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
                _buildProductProperties(),
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
    return Container(
        constraints: const BoxConstraints(
          minHeight: 70,
        ),
        padding: const EdgeInsets.only(top: 10),
        alignment: Alignment.bottomCenter,
        child: CustomTextField(
          labelText: "Tên sản phẩm",
          controller: _nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên sản phẩm';
            }
            return null;
          },
        ));
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

  Widget _buildProductProperties() {
    if (!_isPropertyDataLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

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
            "Thông số kỹ thuật:",
            style: TextDecor.robo16.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTinhTrangField(),
          const SizedBox(height: 16),
          _buildNhaSanXuatField(),
          const SizedBox(height: 16),
          _buildKetNoiField(),
          const SizedBox(height: 16),
          _buildHDHField(),
          const SizedBox(height: 16),
          _buildBaoHanhField(),
          const SizedBox(height: 16),
          _buildChungChiField(),
          const SizedBox(height: 16),
          _buildVatLieuField(),
          const SizedBox(height: 16),
          _buildKichThuocField(),
          const SizedBox(height: 16),
          _buildKhoiLuongField(),
          const SizedBox(height: 16),
          _buildThongTinKhacField(),
        ],
      ),
    );
  }

  Widget _buildTinhTrangField() {
    final tinhTrangList = PropertyService.getTinhTrangWithVietnamese();
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Tình trạng",
        labelStyle: TextDecor.robo16,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      value: _selectedTinhTrang,
      items: tinhTrangList.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(item['label']!),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedTinhTrang = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn tình trạng';
        }
        return null;
      },
    );
  }

  Widget _buildNhaSanXuatField() {
    final nhaSanXuatList = PropertyService.getNhaSanXuat();
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Nhà sản xuất",
        labelStyle: TextDecor.robo16,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      value: _selectedNhaSanXuat,
      items: nhaSanXuatList.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedNhaSanXuat = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn nhà sản xuất';
        }
        return null;
      },
    );
  }

  Widget _buildKetNoiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Loại kết nối (có thể chọn nhiều):",
          style: TextDecor.robo16.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _showMultiSelectBottomSheet(
              title: "Chọn loại kết nối",
              allItems: PropertyService.getKetNoi(),
              selectedItems: _selectedKetNoi,
              onSelectionChanged: (selectedItems) {
                setState(() {
                  _selectedKetNoi = selectedItems;
                });
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: (_isFormSubmitted && _selectedKetNoi.isEmpty)
                    ? Colors.red.shade300
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedKetNoi.isEmpty
                          ? "Chọn loại kết nối"
                          : "${_selectedKetNoi.length} kết nối đã chọn",
                      style: TextDecor.robo16.copyWith(
                        color: _selectedKetNoi.isEmpty
                            ? Colors.grey.shade600
                            : Colors.black,
                        fontWeight: _selectedKetNoi.isEmpty
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                if (_selectedKetNoi.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedKetNoi.take(3).map((ketNoi) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Palette.main1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Palette.main1.withOpacity(0.3)),
                        ),
                        child: Text(
                          ketNoi,
                          style:
                              TextDecor.robo12.copyWith(color: Palette.main1),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_selectedKetNoi.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "+ ${_selectedKetNoi.length - 3} kết nối khác",
                        style: TextDecor.robo12
                            .copyWith(color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (_isFormSubmitted && _selectedKetNoi.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Vui lòng chọn ít nhất một loại kết nối',
              style: TextDecor.robo12.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildHDHField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hệ điều hành tương thích (có thể chọn nhiều):",
          style: TextDecor.robo16.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _showMultiSelectBottomSheet(
              title: "Chọn hệ điều hành",
              allItems: PropertyService.getHDH(),
              selectedItems: _selectedHDH,
              onSelectionChanged: (selectedItems) {
                setState(() {
                  _selectedHDH = selectedItems;
                });
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: (_isFormSubmitted && _selectedHDH.isEmpty)
                    ? Colors.red.shade300
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedHDH.isEmpty
                          ? "Chọn hệ điều hành"
                          : "${_selectedHDH.length} hệ điều hành đã chọn",
                      style: TextDecor.robo16.copyWith(
                        color: _selectedHDH.isEmpty
                            ? Colors.grey.shade600
                            : Colors.black,
                        fontWeight: _selectedHDH.isEmpty
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                if (_selectedHDH.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedHDH.take(3).map((hdh) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Palette.main1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Palette.main1.withOpacity(0.3)),
                        ),
                        child: Text(
                          hdh,
                          style:
                              TextDecor.robo12.copyWith(color: Palette.main1),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_selectedHDH.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "+ ${_selectedHDH.length - 3} hệ điều hành khác",
                        style: TextDecor.robo12
                            .copyWith(color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (_isFormSubmitted && _selectedHDH.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Vui lòng chọn ít nhất một hệ điều hành',
              style: TextDecor.robo12.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildBaoHanhField() {
    final baoHanhThoiGianList = PropertyService.getBaoHanhThoiGian();
    final baoHanhLoaiList = PropertyService.getBaoHanhLoai();

    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Thời gian bảo hành",
            labelStyle: TextDecor.robo16,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          value: _selectedBaoHanhThoiGian,
          items: baoHanhThoiGianList.map((item) {
            return DropdownMenuItem<String>(
              value: item['label'],
              child: Text(item['label']),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedBaoHanhThoiGian = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn thời gian bảo hành';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Loại bảo hành",
            labelStyle: TextDecor.robo16,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          value: _selectedBaoHanhLoai,
          items: baoHanhLoaiList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedBaoHanhLoai = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn loại bảo hành';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildChungChiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chứng chỉ (có thể chọn nhiều):",
          style: TextDecor.robo16.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _showMultiSelectBottomSheet(
              title: "Chọn chứng chỉ",
              allItems: PropertyService.getChungChi(),
              selectedItems: _selectedChungChi,
              onSelectionChanged: (selectedItems) {
                setState(() {
                  _selectedChungChi = selectedItems;
                });
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: (_isFormSubmitted && _selectedChungChi.isEmpty)
                    ? Colors.red.shade300
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedChungChi.isEmpty
                          ? "Chọn chứng chỉ"
                          : "${_selectedChungChi.length} chứng chỉ đã chọn",
                      style: TextDecor.robo16.copyWith(
                        color: _selectedChungChi.isEmpty
                            ? Colors.grey.shade600
                            : Colors.black,
                        fontWeight: _selectedChungChi.isEmpty
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                if (_selectedChungChi.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedChungChi.take(3).map((chungChi) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Palette.main1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Palette.main1.withOpacity(0.3)),
                        ),
                        child: Text(
                          chungChi,
                          style:
                              TextDecor.robo12.copyWith(color: Palette.main1),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_selectedChungChi.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "+ ${_selectedChungChi.length - 3} chứng chỉ khác",
                        style: TextDecor.robo12
                            .copyWith(color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (_isFormSubmitted && _selectedChungChi.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Vui lòng chọn ít nhất một chứng chỉ',
              style: TextDecor.robo12.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildVatLieuField() {
    final vatLieuList = PropertyService.getVatLieu();
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Vật liệu",
        labelStyle: TextDecor.robo16,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      value: _selectedVatLieu,
      items: vatLieuList.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedVatLieu = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn vật liệu';
        }
        return null;
      },
    );
  }

  Widget _buildKichThuocField() {
    final donViList = PropertyService.getKichThuocDonVi();
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: CustomTextField(
            labelText: "Kích thước",
            controller: _kichThuocController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập kích thước';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Đơn vị",
              labelStyle: TextDecor.robo16,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            value: _selectedKichThuocDonVi,
            items: donViList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedKichThuocDonVi = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Chọn đơn vị';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKhoiLuongField() {
    final donViList = PropertyService.getKhoiLuongDonVi();
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: CustomTextField(
            labelText: "Khối lượng",
            controller: _khoiLuongController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập khối lượng';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Đơn vị",
              labelStyle: TextDecor.robo16,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            value: _selectedKhoiLuongDonVi,
            items: donViList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedKhoiLuongDonVi = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Chọn đơn vị';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThongTinKhacField() {
    return CustomTextField(
      labelText: "Thông tin khác (không bắt buộc)",
      controller: _thongTinKhacController,
      maxLines: 3,
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
          inputFormatters: [CurrencyInputFormatter()],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập giá gốc';
            }
            return null;
          },
          suffixIcon: const Text("VNĐ"),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: "Giá bán",
          controller: _priceSaleController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập giá bán';
            }
            return null;
          },
          suffixIcon: const Text("VNĐ"),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return CustomTextField(
      labelText: "Số lượng",
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [CurrencyInputFormatter()],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số lượng';
        }
        return null;
      },
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
        setState(() {
          _isFormSubmitted = true;
        });

        if (_formKey.currentState?.validate() ?? false) {
          // Validate các trường bắt buộc
          bool isValid = true;
          String errorMessage = '';

          if (_selectedTinhTrang == null) {
            isValid = false;
            errorMessage = 'Vui lòng chọn tình trạng';
          } else if (_selectedNhaSanXuat == null) {
            isValid = false;
            errorMessage = 'Vui lòng chọn nhà sản xuất';
          } else if (_selectedKetNoi.isEmpty) {
            isValid = false;
            errorMessage = 'Vui lòng chọn ít nhất một loại kết nối';
          } else if (_selectedHDH.isEmpty) {
            isValid = false;
            errorMessage = 'Vui lòng chọn ít nhất một hệ điều hành';
          } else if (_selectedBaoHanhThoiGian == null ||
              _selectedBaoHanhLoai == null) {
            isValid = false;
            errorMessage = 'Vui lòng chọn đầy đủ thông tin bảo hành';
          } else if (_selectedChungChi.isEmpty) {
            isValid = false;
            errorMessage = 'Vui lòng chọn ít nhất một chứng chỉ';
          } else if (_selectedVatLieu == null) {
            isValid = false;
            errorMessage = 'Vui lòng chọn vật liệu';
          } else if (_kichThuocController.text.trim().isEmpty ||
              _selectedKichThuocDonVi == null) {
            isValid = false;
            errorMessage = 'Vui lòng nhập đầy đủ thông tin kích thước';
          } else if (_khoiLuongController.text.trim().isEmpty ||
              _selectedKhoiLuongDonVi == null) {
            isValid = false;
            errorMessage = 'Vui lòng nhập đầy đủ thông tin khối lượng';
          }

          if (!isValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Nén dữ liệu thuộc tính thành chuỗi
          final String compressedDetail = CompressService.compressProperties(
            tinhTrang: _selectedTinhTrang!,
            nhaSanXuat: _selectedNhaSanXuat!,
            ketNoi: _selectedKetNoi,
            hdh: _selectedHDH,
            baoHanh: '$_selectedBaoHanhThoiGian - $_selectedBaoHanhLoai',
            chungChi: _selectedChungChi,
            vatLieu: _selectedVatLieu!,
            kichThuoc:
                '${_kichThuocController.text.trim()} $_selectedKichThuocDonVi',
            khoiLuong:
                '${_khoiLuongController.text.trim()} $_selectedKhoiLuongDonVi',
            thongTinKhac: _thongTinKhacController.text.trim(),
          );

          // Xử lý logic thêm sản phẩm tại đây
          _presenter?.handleAddProduct(
            name: _nameController.text.trim(),
            itemType: _selectedProductType!,
            description: _descriptionController.text.trim(),
            detail: compressedDetail,
            price: _parseIntSafely(_priceOriginalController.text.trim()),
            amount: _parseIntSafely(_amountController.text.trim()),
            discountPrice: _parseIntSafely(_priceSaleController.text.trim()),
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

      // Reset thuộc tính sản phẩm
      _selectedTinhTrang = null;
      _selectedNhaSanXuat = null;
      _selectedKetNoi.clear();
      _selectedHDH.clear();
      _selectedBaoHanhThoiGian = null;
      _selectedBaoHanhLoai = null;
      _selectedChungChi.clear();
      _selectedVatLieu = null;
      _kichThuocController.clear();
      _selectedKichThuocDonVi = null;
      _khoiLuongController.clear();
      _selectedKhoiLuongDonVi = null;
      _thongTinKhacController.clear();

      // Reset form state
      _isFormSubmitted = false;
    });
  }
}
