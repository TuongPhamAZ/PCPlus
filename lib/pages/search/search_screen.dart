import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/commands/search_command.dart';
import 'package:pcplus/component/item_argument.dart';
import 'package:pcplus/const/item_filter.dart';
import 'package:pcplus/factories/widget_factories/suggest_item_factory.dart';
import 'package:pcplus/pages/search/search_screen_contract.dart';
import 'package:pcplus/pages/search/search_screen_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';

import '../../component/search_argument.dart';
import '../../models/items/item_with_seller.dart';
import '../manage_product/detail_product/detail_product.dart';
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

  bool lienQuan = true;
  bool moiNhat = false;
  bool gia = false;
  bool giaTang = false;

  bool isSearching = false;
  bool _isFirstLoad = true;

  final TextEditingController _searchController = TextEditingController();

  List<ItemWithSeller> sortedItems = [];

  @override
  void initState() {
    _presenter = SearchScreenPresenter(this);
    super.initState();
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

      loadData();
      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    _presenter?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (mounted) {
      await _presenter?.handleSearch(_searchController.text);
    }
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
                        _presenter!.handleSearch(_searchController.text.trim());
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
                            _presenter
                                ?.handleSearch(_searchController.text.trim());
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
                      lienQuan = true;
                      moiNhat = false;
                      giaTang = false;
                      gia = false;
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
                      lienQuan = false;
                      moiNhat = true;
                      giaTang = false;
                      gia = false;
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
                      giaTang = !giaTang;
                      gia = true;
                      lienQuan = false;
                      moiNhat = false;
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
                  stream: _presenter!.searchItemStream,
                  builder: (context, snapshot) {
                    Widget? result = UtilWidgets.createSnapshotResultWidget(
                        context, snapshot);
                    if (result != null) {
                      return result;
                    }

                    final itemsWithSeller = snapshot.data ?? [];

                    sortedItems = itemsWithSeller;

                    if (itemsWithSeller.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: sortedItems.length,
                      itemBuilder: (context, index) {
                        return SuggestItemFactory.create(
                            itemWithSeller: sortedItems[index],
                            command: SearchItemPressedCommand(
                                presenter: _presenter!,
                                item: itemsWithSeller[index]));
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================

  Future<void> _startListening() async {
    bool isAvailable =
        await SpeechToTextGoogleDialog.getInstance().showGoogleDialog(
      onTextReceived: (text) {
        _searchController.text = text.trim();
        _presenter?.handleSearch(text);
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

  // ===========================================================================

  @override
  void onBack() {
    Navigator.pop(context);
  }

  @override
  Future<void> onChangeFilter() async {
    setState(() {
      sortedItems = _presenter!.filter(sortedItems);
    });
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
