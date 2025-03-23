import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/builders/widget_builders/suggest_item_builder.dart';
import 'package:pcplus/builders/widget_builders/widget_builder_director.dart';
import 'package:pcplus/commands/search_command.dart';
import 'package:pcplus/const/item_filter.dart';
import 'package:pcplus/contract/search_screen_contract.dart';
import 'package:pcplus/presenter/search_screen_presenter.dart';
import 'package:pcplus/singleton/search_singleton.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/views/widgets/util_widgets.dart';

import '../../objects/suggest_item_data.dart';
import '../product/detail_product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static const String routeName = 'search_screen';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> implements SearchScreenContract {
  SearchScreenPresenter? _presenter;
  final WidgetBuilderDirector director = WidgetBuilderDirector();
  final SearchSingleton _searchSingleton = SearchSingleton.getInstance();

  List<ItemData> _items = [];

  bool lienQuan = true;
  bool moiNhat = false;
  bool gia = false;
  bool giaTang = false;

  bool isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _presenter = SearchScreenPresenter(this);
    _searchController.text = _searchSingleton.storedSearchInput;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_searchSingleton.needSearch) {
      loadData();
      _searchSingleton.needSearch = false;
    }
  }

  Future<void> loadData() async {
    await _presenter?.handleSearch(_searchController.text);
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
                          borderSide:
                              const BorderSide(color: Palette.primaryColor, width: 1),
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
                            _presenter?.handleSearch(_searchController.text.trim());
                          },
                          child: const Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            size: 16,
                            //color: Palette.greenText,
                          ),
                        ),
                        hintText: 'Search',
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
                      _presenter!.setFilter(lienQuan ? ItemFilter.RELATED : ItemFilter.DEFAULT);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: (size.width - 40) / 3,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          lienQuan ? const Radius.circular(5) : const Radius.circular(0),
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
                      _presenter!.setFilter(moiNhat ? ItemFilter.NEWEST : ItemFilter.DEFAULT);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: (size.width - 40) / 3,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          moiNhat ? const Radius.circular(5) : const Radius.circular(0),
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
                      _presenter!.setFilter(giaTang ? ItemFilter.PRICE_ASCENDING : ItemFilter.PRICE_DESCENDING);

                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: (size.width - 40) / 3,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          gia ? const Radius.circular(5) : const Radius.circular(0),
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
              isSearching ?
                UtilWidgets.getLoadingWidgetWithContainer(
                    width: size.width,
                    height: size.height * 3/4
                )
              : _items.isEmpty ?
                  UtilWidgets.getCenterTextWithContainer(
                    width: size.width,
                    height: size.height * 3/4,
                    text: "No result"
                  )
                :
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    SuggestItemBuilder builder = SuggestItemBuilder();
                    director.makeSuggestItem(
                        builder: builder,
                        data: _items[index],
                        command: SearchItemPressedCommand(
                            presenter: _presenter!,
                            item: _items[index]
                        ),
                    );
                    return builder.createWidget();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onBack() {
    Navigator.pop(context);
  }

  @override
  Future<void> onChangeFilter(List<ItemData> result) async {
    setState(() {
      _items = result;
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
  void onSelectItem() {
    Navigator.of(context).pushNamed(DetailProduct.routeName);
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
