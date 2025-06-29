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

  final TextEditingController _searchController = TextEditingController();

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

    _startMemoryManagement();

    super.initState();
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
  void _debouncedSearch(String query) {
    _debounceTimer?.cancel();

    // ✅ Clear cache trước khi search mới
    PaintingBinding.instance.imageCache.clear();

    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        // ✅ Reset tất cả filter khi search mới
        setState(() {
          lienQuan = false;
          moiNhat = false;
          gia = false;
          giaTang = false;
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
                      _presenter!.setFilter(
                          lienQuan ? ItemFilter.RELATED : ItemFilter.DEFAULT);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: (size.width - 40) / 3,
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
                          fontSize: 16,
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
                      width: (size.width - 40) / 3,
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
                          fontSize: 16,
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
                      width: (size.width - 40) / 3,
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
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            !gia
                                ? FontAwesomeIcons.sort
                                : giaTang
                                    ? FontAwesomeIcons.arrowUp
                                    : FontAwesomeIcons.arrowDown,
                            size: 16,
                            color: Palette.primaryColor,
                          ),
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
                    final displayItems =
                        sortedItems.isNotEmpty ? sortedItems : itemsWithSeller;

                    if (displayItems.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Không có dữ liệu',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
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
