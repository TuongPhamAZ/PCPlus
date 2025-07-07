import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcplus/extensions/money_format_extension.dart';
import 'package:pcplus/pages/manage_product/edit_product/edit_product_contract.dart';
import 'package:pcplus/pages/manage_product/edit_product/edit_product_presenter.dart';
import 'package:pcplus/pages/manage_product/widget/bottom_data_sheet.dart';
import 'package:pcplus/services/compress_service.dart';
import 'package:pcplus/services/extract_service.dart';
import 'package:pcplus/services/property_service.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/objects/image_data.dart';
import 'package:pcplus/const/item_type.dart';
import '../../../component/item_argument.dart';
import '../../../const/product_types.dart';
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
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

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
    this.inputFormatters,
    this.suffixIcon,
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

  // Helper method để parse số an toàn
  int _parseIntSafely(String text) {
    // Loại bỏ tất cả ký tự không phải số
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return 0;
    return int.parse(digitsOnly);
  }

  final List<ImageData> _images = [];
  final List<ColorInfo> _colors = [];
  final ImagePicker _picker = ImagePicker();
  String? _selectedProductType;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceOriginalController =
      TextEditingController();
  final TextEditingController _priceSaleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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
    _presenter = EditProductPresenter(this);
    _loadPropertyData();
    super.initState();
  }

  Future<void> _loadPropertyData() async {
    await PropertyService.loadPropertyData();
    setState(() {
      _isPropertyDataLoaded = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as ItemArgument;

    if (_presenter!.itemWithSeller == null) {
      _presenter!.itemWithSeller = args.data;
      ItemModel itemModel = args.data.item;

      _nameController.text = itemModel.name!;
      _descriptionController.text = itemModel.description!;

      // Format currency cho các trường giá
      final formatter = CurrencyInputFormatter();
      _priceOriginalController.text = formatter
          .formatEditUpdate(const TextEditingValue(),
              TextEditingValue(text: itemModel.price.toString()))
          .text;
      _priceSaleController.text = formatter
          .formatEditUpdate(
              const TextEditingValue(),
              TextEditingValue(
                  text:
                      (itemModel.discountPrice ?? itemModel.price).toString()))
          .text;
      _amountController.text = formatter
          .formatEditUpdate(const TextEditingValue(),
              TextEditingValue(text: itemModel.stock.toString()))
          .text;

      // Kiểm tra và đặt giá trị loại sản phẩm
      _selectedProductType = itemModel.itemType;
      // Đảm bảo loại sản phẩm có trong danh sách, nếu không thì đặt là "Khác"
      if (!ProductTypes.all.contains(_selectedProductType)) {
        _selectedProductType = "Khác";
      }

      // Phân giải dữ liệu thuộc tính từ detail
      if (itemModel.detail != null && itemModel.detail!.isNotEmpty) {
        _parseDetailProperties(itemModel.detail!);
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

  void _parseDetailProperties(String detail) {
    final properties = ExtractService.extractProperties(detail);

    _selectedTinhTrang = properties['tinhTrang']?.isNotEmpty == true
        ? properties['tinhTrang']
        : null;
    _selectedNhaSanXuat = properties['nhaSanXuat']?.isNotEmpty == true
        ? properties['nhaSanXuat']
        : null;
    _selectedKetNoi = List<String>.from(properties['ketNoi'] ?? []);
    _selectedHDH = List<String>.from(properties['hdh'] ?? []);
    _selectedChungChi = List<String>.from(properties['chungChi'] ?? []);
    _selectedVatLieu = properties['vatLieu']?.isNotEmpty == true
        ? properties['vatLieu']
        : null;
    _thongTinKhacController.text = properties['thongTinKhac'] ?? '';

    // Phân giải bảo hành
    if (properties['baoHanh']?.isNotEmpty == true) {
      final baoHanhInfo = ExtractService.parseBaoHanh(properties['baoHanh']);
      _selectedBaoHanhThoiGian = baoHanhInfo['thoiGian']?.isNotEmpty == true
          ? baoHanhInfo['thoiGian']
          : null;
      _selectedBaoHanhLoai =
          baoHanhInfo['loai']?.isNotEmpty == true ? baoHanhInfo['loai'] : null;
    }

    // Phân giải kích thước
    if (properties['kichThuoc']?.isNotEmpty == true) {
      final kichThuocInfo =
          ExtractService.parseKichThuoc(properties['kichThuoc']);
      _kichThuocController.text = kichThuocInfo['giaTri'] ?? '';
      _selectedKichThuocDonVi = kichThuocInfo['donVi']?.isNotEmpty == true
          ? kichThuocInfo['donVi']
          : null;
    }

    // Phân giải khối lượng
    if (properties['khoiLuong']?.isNotEmpty == true) {
      final khoiLuongInfo =
          ExtractService.parseKhoiLuong(properties['khoiLuong']);
      _khoiLuongController.text = khoiLuongInfo['giaTri'] ?? '';
      _selectedKhoiLuongDonVi = khoiLuongInfo['donVi']?.isNotEmpty == true
          ? khoiLuongInfo['donVi']
          : null;
    }

    // Format cũ đã được xử lý ở trên trong thongTinKhac
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

  @override
  Widget build(BuildContext context) {
    // Thêm kiểm tra dữ liệu đã sẵn sàng chưa
    bool isDataReady = _presenter?.itemWithSeller != null &&
        _selectedProductType != null &&
        _isPropertyDataLoaded;

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
      ),
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
          suffixIcon: const Text("VNĐ"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập giá gốc';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: "Giá bán",
          controller: _priceSaleController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          suffixIcon: const Text("VNĐ"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập giá bán';
            }
            return null;
          },
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
            childAspectRatio: 1,
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
                      color: Colors.black.withValues(alpha: 0.2),
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
                  if (color.isNew == false) {
                    color.isNew = true;
                  }
                });
              },
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

          // Xử lý logic sửa sản phẩm tại đây
          _presenter?.handleEditProduct(
            name: _nameController.text.trim(),
            itemType: _selectedProductType!,
            description: _descriptionController.text.trim(),
            detail: compressedDetail,
            price: _parseIntSafely(_priceOriginalController.text.trim()),
            salePrice: _parseIntSafely(_priceSaleController.text.trim()),
            amount: _parseIntSafely(_amountController.text.trim()),
            images: _images,
            colors: _colors,
          );
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
