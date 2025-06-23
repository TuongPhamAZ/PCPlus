import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/const/item_filter.dart';
import 'package:pcplus/factories/widget_factories/suggest_item_factory.dart';
import 'package:pcplus/interfaces/command.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

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

  bool isLoading = true;
  String? errorMessage;
  bool _isFirstLoad = true;

  List<String> productIds = [];
  String? searchImageUrl;
  File? searchImageFile;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _presenter = ImageSearchResultPresenter(this);
    super.initState();
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
              else if (_presenter!.filteredItems.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tìm thấy ${_presenter!.filteredItems.length} sản phẩm tương tự',
                      style: TextDecor.robo16Semi
                          .copyWith(color: Colors.green[700]),
                    ),
                    const Gap(16),
                    PaginatedListView<ItemWithSeller>(
                      items: _presenter!.filteredItems,
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
                ),
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
