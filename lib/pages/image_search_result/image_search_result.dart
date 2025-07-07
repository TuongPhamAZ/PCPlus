import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/const/item_filter.dart';
import 'package:pcplus/factories/widget_factories/suggest_item_factory.dart';
import 'package:pcplus/interfaces/command.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/const/shop_location.dart';
import 'package:pcplus/const/product_types.dart';
import 'package:pcplus/services/property_service.dart';
import 'package:pcplus/services/extract_service.dart';
import 'package:pcplus/pages/manage_product/widget/bottom_data_sheet.dart';

import '../../component/item_argument.dart';
import '../../models/items/item_with_seller.dart';
import '../manage_product/detail_product/detail_product.dart';
import '../widgets/paginated_list_view.dart';
// import '../widgets/util_widgets.dart';
import 'image_search_result_contract.dart';
import 'image_search_result_presenter.dart';

class ImageSearchResultArgument {
  final List<String> productIds;
  final String? searchImageUrl;
  final File? searchImageFile;

  ImageSearchResultArgument({
    required this.productIds,
    this.searchImageUrl,
    this.searchImageFile,
  });
}

class ImageSearchResult extends StatefulWidget {
  const ImageSearchResult({super.key});
  static const String routeName = 'image_search_result';

  @override
  State<ImageSearchResult> createState() => _ImageSearchResultState();
}

class _ImageSearchResultState extends State<ImageSearchResult>
    implements ImageSearchResultContract {
  ImageSearchResultPresenter? _presenter;

  bool lienQuan = true;
  bool moiNhat = false;
  bool gia = false;
  bool giaTang = false;

  // Advanced filter states
  List<String> _selectedLocations = [];
  List<String> _selectedProductTypes = [];
  List<String> _selectedManufacturers = [];
  List<String> _selectedConditions = [];
  double _minPrice = 0;
  double _maxPrice = 100000000; // 100 triệu
  bool _hasAdvancedFilters = false;

  bool isLoading = true;
  String? errorMessage;
  bool _isFirstLoad = true;

  List<String> productIds = [];
  String? searchImageUrl;
  File? searchImageFile;

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _presenter = ImageSearchResultPresenter(this);
    _loadPropertyData();
    super.initState();
  }

  Future<void> _loadPropertyData() async {
    await PropertyService.loadPropertyData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      final args = ModalRoute.of(context)!.settings.arguments
          as ImageSearchResultArgument;
      productIds = args.productIds;
      searchImageUrl = args.searchImageUrl;
      searchImageFile = args.searchImageFile;
      loadData();
      _isFirstLoad = false;
    }
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    await _presenter?.loadProductsByIds(productIds);
  }

  void _goToTop() {
    // scroll to top
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với nút back
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      _presenter!.handleBack();
                    },
                    child: const Icon(
                      FontAwesomeIcons.arrowLeft,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Kết quả tìm kiếm',
                        style: TextDecor.robo18Bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Để cân bằng layout
                ],
              ),
              const Gap(20),

              // Tiêu đề "Kết quả tìm kiếm cho:"
              Text(
                'Kết quả tìm kiếm cho:',
                style: TextDecor.robo16,
              ),
              const Gap(12),

              // Hiển thị ảnh tìm kiếm
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildSearchImage(),
                  ),
                ),
              ),
              const Gap(20),

              // Bộ lọc
              if (!isLoading &&
                  errorMessage == null &&
                  _presenter!.filteredItems.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFilterButton(
                      'Liên quan',
                      lienQuan,
                      () => _setFilter(
                          ItemFilter.RELATED, true, false, false, false),
                      size,
                    ),
                    _buildFilterButton(
                      'Mới nhất',
                      moiNhat,
                      () => _setFilter(
                          ItemFilter.NEWEST, false, true, false, false),
                      size,
                    ),
                    _buildFilterButton(
                      'Giá ↑',
                      giaTang,
                      () => _setFilter(ItemFilter.PRICE_ASCENDING, false, false,
                          false, true),
                      size,
                    ),
                    _buildFilterButton(
                      'Giá ↓',
                      gia,
                      () => _setFilter(ItemFilter.PRICE_DESCENDING, false,
                          false, true, false),
                      size,
                    ),
                  ],
                ),
                const Gap(12),
                // Advanced filter button
                InkWell(
                  onTap: () {
                    if (isLoading) {
                      return;
                    }
                    _showAdvancedFilterDialog();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _hasAdvancedFilters
                            ? Palette.primaryColor
                            : Colors.grey.shade400,
                        width: 1,
                      ),
                      color: _hasAdvancedFilters
                          ? Palette.primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: _hasAdvancedFilters
                              ? Palette.primaryColor
                              : Colors.grey.shade600,
                          size: 18,
                        ),
                        const Gap(8),
                        Text(
                          _hasAdvancedFilters
                              ? 'Bộ lọc đang áp dụng'
                              : 'Bộ lọc nâng cao',
                          style: TextStyle(
                            color: _hasAdvancedFilters
                                ? Palette.primaryColor
                                : Colors.grey.shade600,
                            fontSize: 15,
                            fontWeight: _hasAdvancedFilters
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        if (_hasAdvancedFilters) ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Palette.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '●',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Gap(20),
              ],

              // Nội dung chính
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const Gap(16),
                        Text(
                          'Không tìm thấy sản phẩm phù hợp',
                          style: TextDecor.robo16Semi
                              .copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(8),
                        Text(
                          'Hãy thử với hình ảnh khác',
                          style: TextDecor.robo14
                              .copyWith(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Builder(builder: (context) {
                  // Apply advanced filtering to presenter's filtered items
                  final displayItems =
                      _applyAdvancedFiltering(_presenter!.filteredItems);

                  if (displayItems.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          children: [
                            Icon(
                              _hasAdvancedFilters
                                  ? Icons.filter_list_off
                                  : Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const Gap(16),
                            Text(
                              _hasAdvancedFilters
                                  ? 'Không tìm thấy sản phẩm phù hợp với bộ lọc'
                                  : 'Không tìm thấy sản phẩm phù hợp',
                              style: TextDecor.robo16Semi
                                  .copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(8),
                            Text(
                              _hasAdvancedFilters
                                  ? 'Hãy thử điều chỉnh bộ lọc'
                                  : 'Hãy thử với hình ảnh khác',
                              style: TextDecor.robo14
                                  .copyWith(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                            if (_hasAdvancedFilters) ...[
                              const Gap(12),
                              TextButton(
                                onPressed: () {
                                  _clearAllFilters();
                                },
                                child: Text(
                                  'Xóa bộ lọc',
                                  style: TextDecor.robo14.copyWith(
                                    color: Palette.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tìm thấy ${displayItems.length} sản phẩm tương tự',
                        style: TextDecor.robo16Semi
                            .copyWith(color: Colors.green[700]),
                      ),
                      const Gap(16),
                      PaginatedListView<ItemWithSeller>(
                        items: displayItems,
                        itemsPerPage: 10,
                        onPageChanged: (value) {
                          _goToTop();
                        },
                        itemBuilder: (context, item) {
                          return SuggestItemFactory.create(
                            itemWithSeller: item,
                            command: ImageSearchItemPressedCommand(
                              presenter: _presenter!,
                              item: item,
                            ),
                          );
                        },
                      ),
                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   padding: EdgeInsets.zero,
                      //   physics: const NeverScrollableScrollPhysics(),
                      //   itemCount: _presenter!.filteredItems.length > 15 ? 15 : _presenter!.filteredItems.length,
                      //   itemBuilder: (context, index) {
                      //     return SuggestItemFactory.create(
                      //       itemWithSeller: _presenter!.filteredItems[index],
                      //       command: ImageSearchItemPressedCommand(
                      //         presenter: _presenter!,
                      //         item: _presenter!.filteredItems[index],
                      //       ),
                      //     );
                      //   },
                      // ),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchImage() {
    if (searchImageFile != null) {
      return Image.file(
        searchImageFile!,
        fit: BoxFit.cover,
      );
    } else if (searchImageUrl != null) {
      return Image.network(
        searchImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      );
    } else {
      return const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 48),
      );
    }
  }

  Widget _buildFilterButton(
      String text, bool isSelected, VoidCallback onTap, Size size) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        alignment: Alignment.center,
        width: (size.width - 40) / 4 - 5,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSelected ? 5 : 0),
          border: Border.all(
            color: Palette.primaryColor,
            width: 1,
          ),
          color: isSelected
              ? Palette.primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Palette.primaryColor,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _setFilter(String filter, bool lq, bool mn, bool g, bool gt) {
    if (isLoading) return;

    setState(() {
      lienQuan = lq;
      moiNhat = mn;
      gia = g;
      giaTang = gt;
    });
    _presenter!.setFilter(filter);
  }

  // Show advanced filter dialog
  void _showAdvancedFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdvancedFilterSheet(),
    );
  }

  // Build advanced filter bottom sheet
  Widget _buildAdvancedFilterSheet() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Palette.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      color: Palette.primaryColor,
                      size: 24,
                    ),
                    const Gap(12),
                    Text(
                      'Bộ lọc nâng cao',
                      style: TextDecor.robo18Bold.copyWith(
                        color: Palette.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _clearAllFilters();
                        });
                        setModalState(() {}); // Update modal state
                      },
                      child: Text(
                        'Xóa tất cả',
                        style: TextDecor.robo14.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationFilter(setModalState),
                      const Gap(20),
                      _buildPriceRangeFilter(setModalState),
                      const Gap(20),
                      _buildProductTypeFilter(setModalState),
                      const Gap(20),
                      _buildManufacturerFilter(setModalState),
                      const Gap(20),
                      _buildConditionFilter(setModalState),
                    ],
                  ),
                ),
              ),
              // Footer buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Palette.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextDecor.robo16.copyWith(
                            color: Palette.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _applyAdvancedFilters();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Áp dụng',
                          style: TextDecor.robo16.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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

  // Clear all advanced filters
  void _clearAllFilters() {
    setState(() {
      _selectedLocations.clear();
      _selectedProductTypes.clear();
      _selectedManufacturers.clear();
      _selectedConditions.clear();
      _minPrice = 0;
      _maxPrice = 100000000;
      _minPriceController.clear();
      _maxPriceController.clear();
      _hasAdvancedFilters = false;
    });
  }

  // Apply advanced filters
  void _applyAdvancedFilters() {
    setState(() {
      _hasAdvancedFilters = _selectedLocations.isNotEmpty ||
          _selectedProductTypes.isNotEmpty ||
          _selectedManufacturers.isNotEmpty ||
          _selectedConditions.isNotEmpty ||
          _minPriceController.text.isNotEmpty ||
          _maxPriceController.text.isNotEmpty;

      // Parse price values
      if (_minPriceController.text.isNotEmpty) {
        _minPrice =
            double.tryParse(_minPriceController.text.replaceAll(',', '')) ?? 0;
      }
      if (_maxPriceController.text.isNotEmpty) {
        _maxPrice =
            double.tryParse(_maxPriceController.text.replaceAll(',', '')) ??
                100000000;
      }
    });

    // Apply filters to current results
    _applyFiltersToPresenter();
  }

  // Apply advanced filters to presenter data
  void _applyFiltersToPresenter() {
    // Simply trigger setState to rebuild, the filtering will be applied in build method
    setState(() {});
  }

  // Filter items based on advanced filters
  List<ItemWithSeller> _applyAdvancedFiltering(List<ItemWithSeller> items) {
    if (!_hasAdvancedFilters) return items;

    return items.where((itemWithSeller) {
      // Filter by location (seller location)
      if (_selectedLocations.isNotEmpty) {
        final shopLocation = itemWithSeller.seller.location ?? '';
        bool locationMatch = _selectedLocations.any((location) =>
            shopLocation.toLowerCase().contains(location.toLowerCase()));
        if (!locationMatch) return false;
      }

      // Filter by product type
      if (_selectedProductTypes.isNotEmpty) {
        final itemType = itemWithSeller.item.itemType ?? '';
        bool typeMatch = _selectedProductTypes.contains(itemType);
        if (!typeMatch) return false;
      }

      // Filter by price range
      final itemPrice = itemWithSeller.item.price?.toDouble() ?? 0;
      bool priceMatch = itemPrice >= _minPrice && itemPrice <= _maxPrice;
      if (!priceMatch) return false;

      // Filter by manufacturer (check product details)
      if (_selectedManufacturers.isNotEmpty) {
        final details = itemWithSeller.item.detail ?? '';
        // Use ExtractService to parse manufacturer from details
        final properties = ExtractService.extractProperties(details);
        final manufacturer = properties['nhaSanXuat'] as String? ?? '';

        // Only items with matching manufacturer should pass
        if (!_selectedManufacturers.contains(manufacturer)) {
          return false;
        }
      }

      // Filter by condition (check product details)
      if (_selectedConditions.isNotEmpty) {
        final details = itemWithSeller.item.detail ?? '';
        final properties = ExtractService.extractProperties(details);
        final condition = properties['tinhTrang'] as String? ?? '';

        // Convert condition value to Vietnamese label for comparison
        String conditionLabel = '';
        final conditions = PropertyService.getTinhTrangWithVietnamese();
        for (var item in conditions) {
          if (item['value'] == condition) {
            conditionLabel = item['label']!;
            break;
          }
        }

        // Only items with matching condition should pass
        if (!_selectedConditions.contains(conditionLabel)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Build location filter
  Widget _buildLocationFilter([StateSetter? setModalState]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nơi bán',
          style: TextDecor.robo16.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        GestureDetector(
          onTap: () {
            _showMultiSelectBottomSheet(
              title: 'Chọn nơi bán',
              allItems: LOCATIONS,
              selectedItems: _selectedLocations,
              onSelectionChanged: (selected) {
                setState(() {
                  _selectedLocations = selected;
                });
                setModalState?.call(() {}); // Update modal state
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    color: Palette.primaryColor, size: 20),
                const Gap(8),
                Expanded(
                  child: Text(
                    _selectedLocations.isEmpty
                        ? 'Chọn địa điểm'
                        : '${_selectedLocations.length} địa điểm đã chọn',
                    style: TextDecor.robo14.copyWith(
                      color: _selectedLocations.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_selectedLocations.isNotEmpty) ...[
          const Gap(8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedLocations.take(3).map((location) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Palette.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Palette.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  location,
                  style: TextDecor.robo12.copyWith(color: Palette.primaryColor),
                ),
              );
            }).toList(),
          ),
          if (_selectedLocations.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+ ${_selectedLocations.length - 3} địa điểm khác',
                style: TextDecor.robo12.copyWith(color: Colors.grey),
              ),
            ),
        ],
      ],
    );
  }

  // Build price range filter
  Widget _buildPriceRangeFilter([StateSetter? setModalState]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khoảng giá',
          style: TextDecor.robo16.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Auto format number with commas
                  final cleanValue = value.replaceAll(',', '');
                  if (cleanValue.isNotEmpty) {
                    final number = int.tryParse(cleanValue);
                    if (number != null) {
                      final formatted = number.toString().replaceAllMapped(
                            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          );
                      if (formatted != value) {
                        _minPriceController.value = TextEditingValue(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    }
                  }
                  setModalState?.call(() {}); // Update modal state
                },
                decoration: InputDecoration(
                  hintText: 'Giá từ (VNĐ)',
                  prefixIcon: const Icon(Icons.monetization_on,
                      color: Palette.primaryColor, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: TextDecor.robo14,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('-',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Auto format number with commas
                  final cleanValue = value.replaceAll(',', '');
                  if (cleanValue.isNotEmpty) {
                    final number = int.tryParse(cleanValue);
                    if (number != null) {
                      final formatted = number.toString().replaceAllMapped(
                            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          );
                      if (formatted != value) {
                        _maxPriceController.value = TextEditingValue(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    }
                  }
                  setModalState?.call(() {}); // Update modal state
                },
                decoration: InputDecoration(
                  hintText: 'Giá đến (VNĐ)',
                  prefixIcon: const Icon(Icons.monetization_on,
                      color: Palette.primaryColor, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: TextDecor.robo14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build product type filter
  Widget _buildProductTypeFilter([StateSetter? setModalState]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại sản phẩm',
          style: TextDecor.robo16.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        GestureDetector(
          onTap: () {
            _showMultiSelectBottomSheet(
              title: 'Chọn loại sản phẩm',
              allItems: ProductTypes.all,
              selectedItems: _selectedProductTypes,
              onSelectionChanged: (selected) {
                setState(() {
                  _selectedProductTypes = selected;
                });
                setModalState?.call(() {}); // Update modal state
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.category,
                    color: Palette.primaryColor, size: 20),
                const Gap(8),
                Expanded(
                  child: Text(
                    _selectedProductTypes.isEmpty
                        ? 'Chọn loại sản phẩm'
                        : '${_selectedProductTypes.length} loại đã chọn',
                    style: TextDecor.robo14.copyWith(
                      color: _selectedProductTypes.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_selectedProductTypes.isNotEmpty) ...[
          const Gap(8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedProductTypes.take(3).map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Palette.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Palette.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  type,
                  style: TextDecor.robo12.copyWith(color: Palette.primaryColor),
                ),
              );
            }).toList(),
          ),
          if (_selectedProductTypes.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+ ${_selectedProductTypes.length - 3} loại khác',
                style: TextDecor.robo12.copyWith(color: Colors.grey),
              ),
            ),
        ],
      ],
    );
  }

  // Build manufacturer filter
  Widget _buildManufacturerFilter([StateSetter? setModalState]) {
    final manufacturers = PropertyService.getNhaSanXuat();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhà sản xuất',
          style: TextDecor.robo16.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        GestureDetector(
          onTap: () {
            _showMultiSelectBottomSheet(
              title: 'Chọn nhà sản xuất',
              allItems: manufacturers,
              selectedItems: _selectedManufacturers,
              onSelectionChanged: (selected) {
                setState(() {
                  _selectedManufacturers = selected;
                });
                setModalState?.call(() {}); // Update modal state
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.business,
                    color: Palette.primaryColor, size: 20),
                const Gap(8),
                Expanded(
                  child: Text(
                    _selectedManufacturers.isEmpty
                        ? 'Chọn nhà sản xuất'
                        : '${_selectedManufacturers.length} nhà sản xuất đã chọn',
                    style: TextDecor.robo14.copyWith(
                      color: _selectedManufacturers.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_selectedManufacturers.isNotEmpty) ...[
          const Gap(8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedManufacturers.take(3).map((manufacturer) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Palette.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Palette.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  manufacturer,
                  style: TextDecor.robo12.copyWith(color: Palette.primaryColor),
                ),
              );
            }).toList(),
          ),
          if (_selectedManufacturers.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+ ${_selectedManufacturers.length - 3} nhà sản xuất khác',
                style: TextDecor.robo12.copyWith(color: Colors.grey),
              ),
            ),
        ],
      ],
    );
  }

  // Build condition filter
  Widget _buildConditionFilter([StateSetter? setModalState]) {
    final conditions = PropertyService.getTinhTrangWithVietnamese();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tình trạng',
          style: TextDecor.robo16.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        GestureDetector(
          onTap: () {
            _showMultiSelectBottomSheet(
              title: 'Chọn tình trạng',
              allItems: conditions.map((item) => item['label']!).toList(),
              selectedItems: _selectedConditions,
              onSelectionChanged: (selected) {
                setState(() {
                  _selectedConditions = selected;
                });
                setModalState?.call(() {}); // Update modal state
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Palette.primaryColor, size: 20),
                const Gap(8),
                Expanded(
                  child: Text(
                    _selectedConditions.isEmpty
                        ? 'Chọn tình trạng'
                        : '${_selectedConditions.length} tình trạng đã chọn',
                    style: TextDecor.robo14.copyWith(
                      color: _selectedConditions.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_selectedConditions.isNotEmpty) ...[
          const Gap(8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedConditions.take(3).map((condition) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Palette.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Palette.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  condition,
                  style: TextDecor.robo12.copyWith(color: Palette.primaryColor),
                ),
              );
            }).toList(),
          ),
          if (_selectedConditions.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+ ${_selectedConditions.length - 3} tình trạng khác',
                style: TextDecor.robo12.copyWith(color: Colors.grey),
              ),
            ),
        ],
      ],
    );
  }

  // ===========================================================================

  @override
  void onLoadDataSucceed() {
    setState(() {
      isLoading = false;
      errorMessage = null;
    });
  }

  @override
  void onLoadDataFailed(String message) {
    setState(() {
      isLoading = false;
      errorMessage = message;
    });
  }

  @override
  void onItemPressed(ItemWithSeller itemData) {
    Navigator.of(context).pushNamed(
      DetailProduct.routeName,
      arguments: ItemArgument(data: itemData),
    );
  }

  @override
  void onBack() {
    Navigator.of(context).pop();
  }
}

// Command pattern cho item pressed
class ImageSearchItemPressedCommand implements ICommand {
  final ImageSearchResultPresenter presenter;
  final ItemWithSeller item;

  ImageSearchItemPressedCommand({
    required this.presenter,
    required this.item,
  });

  @override
  void execute() {
    presenter.handleItemPressed(item);
  }
}
