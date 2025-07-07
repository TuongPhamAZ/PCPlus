import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/commands/search_command.dart';
import 'package:pcplus/component/item_argument.dart';
import 'package:pcplus/const/item_filter.dart';
import 'package:pcplus/factories/widget_factories/suggest_item_factory.dart';
import 'package:pcplus/pages/search/search_screen_contract.dart';
import 'package:pcplus/pages/search/search_screen_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import 'dart:async'; // ✅ Import Timer cho debounce
import 'dart:developer' as developer; // ✅ Import để force garbage collection
import 'package:pcplus/const/shop_location.dart';
import 'package:pcplus/const/product_types.dart';
import 'package:pcplus/services/property_service.dart';
import 'package:pcplus/services/extract_service.dart';
import 'package:pcplus/pages/manage_product/widget/bottom_data_sheet.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../component/search_argument.dart';
import '../../models/items/item_with_seller.dart';
import '../manage_product/detail_product/detail_product.dart';
import '../widgets/paginated_list_view.dart';
import '../widgets/util_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static const String routeName = 'search_screen';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    implements SearchScreenContract {
  SearchScreenPresenter? _presenter;

  bool _isFirstLoad = true;
  bool isSearching = false;

  // ✅ Thay đổi: Mặc định tất cả bộ lọc đều là false
  bool lienQuan = false;
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

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  List<ItemWithSeller> sortedItems = [];

  final ScrollController _scrollController = ScrollController();

  // ✅ Debounce timer để tránh spam search
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  // ✅ Memory management
  Timer? _memoryCleanupTimer;
  static const Duration _memoryCleanupInterval = Duration(seconds: 30);

  @override
  void initState() {
    _presenter = SearchScreenPresenter(this);
    _loadPropertyData();
    _startMemoryManagement();

    super.initState();
  }

  Future<void> _loadPropertyData() async {
    await PropertyService.loadPropertyData();
  }

  // ✅ Memory management methods
  void _startMemoryManagement() {
    _memoryCleanupTimer = Timer.periodic(_memoryCleanupInterval, (timer) {
      if (mounted) {
        _performMemoryCleanup();
      }
    });
  }

  void _performMemoryCleanup() {
    final imageCache = PaintingBinding.instance.imageCache;

    // ✅ Chỉ cleanup khi cache quá lớn
    if (imageCache.currentSizeBytes > 50 * 1024 * 1024) {
      // 50MB
      developer.log(
          'SearchScreen: Performing memory cleanup - Cache size: ${imageCache.currentSizeBytes / 1024 / 1024}MB');
      imageCache.clear();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isFirstLoad) {
      final args = ModalRoute.of(context)!.settings.arguments as SearchArgument;

      if (args.query.isEmpty == false) {
        _searchController.text = args.query;
        args.query = '';
      }

      // ✅ Đầu tiên loadData để có fuzzy search results
      loadData();
      // ✅ Sau đó set filter DEFAULT (nhưng không emit gì vì chưa có data)
      _presenter!.setFilter(ItemFilter.DEFAULT);
      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    // ✅ CRITICAL: Cleanup toàn bộ để tránh memory leak
    _scrollController.dispose();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();

    // ✅ Cancel timers
    _debounceTimer?.cancel();
    _memoryCleanupTimer?.cancel();

    // ✅ Clear danh sách lớn và force memory cleanup
    sortedItems.clear();

    // ✅ Dispose presenter cuối cùng
    _presenter?.dispose();

    // ✅ CRITICAL: Force garbage collection để clear image cache
    developer
        .log('SearchScreen: Forcing garbage collection for memory cleanup');
    Future.delayed(const Duration(milliseconds: 100), () {
      // Clear any remaining image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    });

    super.dispose();
  }

  Future<void> loadData() async {
    if (mounted) {
      _debouncedSearch(_searchController.text);
    }
  }

  // ✅ Method search với debounce và memory monitoring
  void _debouncedSearch(String query, {bool resetAdvancedFilters = true}) {
    _debounceTimer?.cancel();

    // ✅ Clear cache trước khi search mới
    PaintingBinding.instance.imageCache.clear();

    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        // ✅ Reset basic filters khi search mới
        setState(() {
          lienQuan = false;
          moiNhat = false;
          gia = false;
          giaTang = false;

          // Chỉ reset advanced filters khi search từ search box (không phải từ apply filter)
          if (resetAdvancedFilters) {
            _selectedLocations.clear();
            _selectedProductTypes.clear();
            _selectedManufacturers.clear();
            _selectedConditions.clear();
            _minPriceController.clear();
            _maxPriceController.clear();
            _hasAdvancedFilters = false;
          }
        });

        // ✅ Reset filter mode về DEFAULT
        _presenter?.setFilter(ItemFilter.DEFAULT);

        developer.log('SearchScreen: Starting search for query: "$query"');
        _presenter?.handleSearch(query.trim());
      }
    });
  }

  void _goToTop() {
    // ✅ Check mounted trước khi animate
    if (mounted && _scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ✅ Helper method để so sánh list hiệu quả
  bool _listEquals(List<ItemWithSeller> list1, List<ItemWithSeller> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].item.itemID != list2[i].item.itemID) return false;
    }
    return true;
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
                  color: Palette.main1.withOpacity(0.1),
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

    // No need to trigger new search, just update UI with current filters
    // The StreamBuilder will automatically apply advanced filtering
  }

  // Filter items based on advanced filters
  List<ItemWithSeller> _applyAdvancedFiltering(List<ItemWithSeller> items) {
    if (!_hasAdvancedFilters) return items;

    final filteredItems = items.where((itemWithSeller) {
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

    return filteredItems;
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  SizedBox(
                    height: 42,
                    width: size.width - 75,
                    child: TextField(
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      readOnly: isSearching,
                      onChanged: (value) {},
                      onSubmitted: (value) {
                        _debouncedSearch(_searchController.text.trim());
                      },
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Palette.primaryColor, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Palette.primaryColor, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.only(top: 4),
                        prefixIcon: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            _debouncedSearch(_searchController.text.trim());
                          },
                          child: const Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            size: 16,
                            //color: Palette.greenText,
                          ),
                        ),
                        suffixIcon: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            _startListening();
                          },
                          child: const Icon(
                            FontAwesomeIcons.microphone,
                            size: 16,
                            //color: Palette.greenText,
                          ),
                        ),
                        hintText: 'Tìm kiếm',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Column(
                children: [
                  // First row - original filters
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          if (isSearching) {
                            return;
                          }
                          setState(() {
                            lienQuan = true;
                            moiNhat = false;
                            giaTang = false;
                            gia = false;
                          });
                          _presenter!.setFilter(lienQuan
                              ? ItemFilter.RELATED
                              : ItemFilter.DEFAULT);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: (size.width - 50) / 3,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              lienQuan
                                  ? const Radius.circular(5)
                                  : const Radius.circular(0),
                            ),
                            border: lienQuan
                                ? Border.all(
                                    color: Palette.primaryColor,
                                    width: 1,
                                  )
                                : moiNhat
                                    ? const Border(
                                        right: BorderSide(
                                          color: Palette.primaryColor,
                                          width: 1,
                                        ),
                                      )
                                    : null,
                          ),
                          child: const Text(
                            'Liên quan',
                            style: TextStyle(
                              color: Palette.primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (isSearching) {
                            return;
                          }
                          setState(() {
                            lienQuan = false;
                            moiNhat = true;
                            giaTang = false;
                            gia = false;
                          });
                          _presenter!.setFilter(
                              moiNhat ? ItemFilter.NEWEST : ItemFilter.DEFAULT);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: (size.width - 50) / 3,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              moiNhat
                                  ? const Radius.circular(5)
                                  : const Radius.circular(0),
                            ),
                            border: moiNhat
                                ? Border.all(
                                    color: Palette.primaryColor,
                                    width: 1,
                                  )
                                : const Border(
                                    right: BorderSide(
                                      color: Palette.primaryColor,
                                      width: 1,
                                    ),
                                    left: BorderSide(
                                      color: Palette.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                          ),
                          child: const Text(
                            'Mới nhất',
                            style: TextStyle(
                              color: Palette.primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (isSearching) {
                            return;
                          }
                          setState(() {
                            giaTang = !giaTang;
                            gia = true;
                            lienQuan = false;
                            moiNhat = false;
                          });
                          _presenter!.setFilter(giaTang
                              ? ItemFilter.PRICE_ASCENDING
                              : ItemFilter.PRICE_DESCENDING);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: (size.width - 50) / 3,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              gia
                                  ? const Radius.circular(5)
                                  : const Radius.circular(0),
                            ),
                            border: gia
                                ? Border.all(
                                    color: Palette.primaryColor,
                                    width: 1,
                                  )
                                : moiNhat
                                    ? const Border(
                                        left: BorderSide(
                                          color: Palette.primaryColor,
                                          width: 1,
                                        ),
                                      )
                                    : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Giá',
                                style: TextStyle(
                                  color: Palette.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              const Gap(4),
                              Icon(
                                !gia
                                    ? FontAwesomeIcons.sort
                                    : giaTang
                                        ? FontAwesomeIcons.arrowUp
                                        : FontAwesomeIcons.arrowDown,
                                size: 14,
                                color: Palette.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  // Second row - Advanced filter button
                  InkWell(
                    onTap: () {
                      if (isSearching) {
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
                ],
              ),
              const Gap(10),
              StreamBuilder<List<ItemWithSeller>>(
                  key: const ValueKey('search_results'),
                  stream: _presenter!.searchItemStream,
                  builder: (context, snapshot) {
                    Widget? result = UtilWidgets.createSnapshotResultWidget(
                        context, snapshot);
                    if (result != null) {
                      return result;
                    }

                    final itemsWithSeller = snapshot.data ?? [];

                    // ✅ Chỉ update sortedItems khi:
                    // 1. Chưa có filter nào active và có data
                    // 2. Hoặc filter là "Liên quan" (exact matching) - bất kể empty hay không
                    final hasNonRelatedFilter = moiNhat || gia;
                    final needsUpdate =
                        sortedItems.length != itemsWithSeller.length ||
                            !_listEquals(sortedItems, itemsWithSeller);

                    // ✅ Cho phép update khi:
                    // - Filter "Liên quan" active: update bất kể empty hay không
                    // - Không có filter nào active: chỉ update khi có data
                    final shouldUpdate = needsUpdate &&
                        ((lienQuan) || // Exact matching - luôn update
                            (!hasNonRelatedFilter &&
                                itemsWithSeller
                                    .isNotEmpty) // Default - chỉ khi có data
                        );

                    if (shouldUpdate) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            sortedItems =
                                List<ItemWithSeller>.from(itemsWithSeller);
                          });
                        }
                      });
                    }

                    // ✅ Sử dụng sortedItems thay vì itemsWithSeller để hiển thị
                    final baseItems =
                        sortedItems.isNotEmpty ? sortedItems : itemsWithSeller;

                    // Apply advanced filtering
                    final displayItems = _applyAdvancedFiltering(baseItems);

                    if (displayItems.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _hasAdvancedFilters
                                    ? Icons.filter_list_off
                                    : Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const Gap(16),
                              Text(
                                _hasAdvancedFilters
                                    ? 'Không tìm thấy sản phẩm phù hợp với bộ lọc'
                                    : 'Không có dữ liệu',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              if (_hasAdvancedFilters) ...[
                                const Gap(12),
                                TextButton(
                                  onPressed: () {
                                    _clearAllFilters();
                                    // Just trigger setState, no need for new search
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
                      children: [
                        // ✅ CRITICAL: Thay thế PaginatedListView bằng ListView.builder thực sự
                        Text(
                          'Tìm thấy ${displayItems.length} kết quả',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // ✅ LAZY LOADING ListView - CHỈ render items trong viewport
                        ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Controlled by parent ScrollView
                          itemCount: displayItems.length,
                          // ✅ CRITICAL: addAutomaticKeepAlives: false để dispose widgets ngoài viewport
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: true, // Tối ưu repaint
                          addSemanticIndexes: false, // Giảm overhead
                          itemBuilder: (context, index) {
                            // ✅ Lazy loading - chỉ build khi cần
                            return SuggestItemFactory.create(
                                itemWithSeller: displayItems[index],
                                command: SearchItemPressedCommand(
                                    presenter: _presenter!,
                                    item: displayItems[index]));
                          },
                        ),
                      ],
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startListening() async {
    bool isAvailable =
        await SpeechToTextGoogleDialog.getInstance().showGoogleDialog(
      onTextReceived: (text) {
        _searchController.text = text.trim();
        _debouncedSearch(text);
      },
      locale: 'vi-VN',
    );

    if (!mounted) {
      return;
    }

    if (!isAvailable) {
      UtilWidgets.createSnackBar(context, 'Không thể mở Google Speech Dialog',
          backgroundColor: Colors.red);
    }
  }

  @override
  void onBack() {
    // ✅ CRITICAL: Clear image cache trước khi navigate back
    PaintingBinding.instance.imageCache.clear();
    Navigator.pop(context);
  }

  @override
  Future<void> onChangeFilter() async {
    if (mounted) {
      setState(() {
        // ✅ KHÔNG apply filter nếu đang ở mode "Liên quan" (exact matching)
        if (lienQuan) {
          return; // Exit early, không làm gì cả
        }

        // ✅ Lấy fuzzy search results từ presenter và apply filter
        final fuzzyResults = _presenter!.fuzzySearchResults;
        if (fuzzyResults.isNotEmpty) {
          sortedItems = _presenter!.filter(fuzzyResults);
        }
      });
    }
  }

  @override
  void onFinishSearching() {
    setState(() {
      isSearching = false;
    });
  }

  @override
  void onStartSearching() {
    setState(() {
      isSearching = true;
    });
  }

  @override
  void onSelectItem(ItemWithSeller item) {
    Navigator.of(context).pushNamed(
      DetailProduct.routeName,
      arguments: ItemArgument(data: item),
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
}
