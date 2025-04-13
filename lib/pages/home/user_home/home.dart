import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/builders/widget_builders/widget_builder_director.dart';
import 'package:pcplus/commands/home_command.dart';
import 'package:pcplus/component/item_argument.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/const/navigator_arguments.dart';
import 'package:pcplus/factories/widget_factories/new_item_factory.dart';
import 'package:pcplus/factories/widget_factories/suggest_item_factory.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/home/user_home/home_contract.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product.dart';
import 'package:pcplus/pages/search/search_screen.dart';
import '../../widgets/bottom/bottom_bar_custom.dart';
import '../../widgets/util_widgets.dart';
import 'home_presenter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = 'home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeContract {
  HomePresenter? _presenter;
  WidgetBuilderDirector director = WidgetBuilderDirector();
  bool isShop = false;
  bool isLoading = true;
  bool isFirstLoad = true;
  List<Widget> newProducts = [];
  List<Widget> recommendedProducts = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _presenter = HomePresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    await _presenter?.getData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading ? UtilWidgets.getLoadingWidget() : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 42,
                width: double.infinity,
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
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
                        _presenter!.handleSearch(_searchController.text.trim());
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
              Container(
                height: 200,
                padding: const EdgeInsets.only(top: 12),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      height: 145,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Palette.primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Music and No more",
                            style: TextDecor.robo24Medi,
                          ),
                          const Gap(5),
                          Text(
                            "10% off for One of the best\nheadphones in the world",
                            style: TextDecor.robo12,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      AssetHelper.sampleImage,
                    ),
                  ],
                ),
              ),
              const Gap(30),
              Text('New Products', style: TextDecor.robo18Bold),
              const Gap(10),
              SizedBox(
                height: 285,
                width: size.width,
                child: StreamBuilder<List<ItemWithSeller>>(
                    stream: _presenter!.newestItemStream,
                    builder: (context, snapshot) {
                      Widget? result = UtilWidgets.createSnapshotResultWidget(context, snapshot);
                      if (result != null) {
                        return result;
                      }

                      final itemsWithSeller = snapshot.data ?? [];

                      if (itemsWithSeller.isEmpty) {
                        return const Center(child: Text('No data'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        itemCount: itemsWithSeller.length,
                        itemBuilder: (context, index) {
                          return NewItemFactory.create(
                              itemWithSeller: itemsWithSeller[index],
                              command: HomeItemPressedCommand(
                                  presenter: _presenter!,
                                  item: itemsWithSeller[index]
                              )
                          );
                        },
                      );
                    }
                  ),
              ),
              const Gap(30),
              Text('Suggestions for you', style: TextDecor.robo18Bold),
              const Gap(10),
              StreamBuilder<List<ItemWithSeller>>(
                  stream: _presenter!.recommendedItemStream,
                  builder: (context, snapshot) {
                    Widget? result = UtilWidgets.createSnapshotResultWidget(context, snapshot);
                    if (result != null) {
                      return result;
                    }

                    final itemsWithSeller = snapshot.data ?? [];

                    if (itemsWithSeller.isEmpty) {
                      return const Center(child: Text('No data'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: itemsWithSeller.length,
                      itemBuilder: (context, index) {
                        return SuggestItemFactory.create(
                            itemWithSeller: itemsWithSeller[index],
                            command: HomeItemPressedCommand(
                                presenter: _presenter!,
                                item: itemsWithSeller[index]
                            )
                        );
                      },
                    );
                  }
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarCustom(currentIndex: 0),
    );
  }

  @override
  Future<void> onLoadDataSucceed() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  void onItemPressed(ItemWithSeller itemData) {
    Navigator.of(context).pushNamed(
        DetailProduct.routeName,
        arguments: {NavigatorArgs.itemData : itemData}
    );
  }

  @override
  void onSearch() {
    Navigator.of(context).pushNamed(
        SearchScreen.routeName,
        arguments: ItemArgument(data: {
          NavigatorArgs.searchQuery : _searchController.text.trim()
        })
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
