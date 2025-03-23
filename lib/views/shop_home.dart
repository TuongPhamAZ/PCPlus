import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/commands/shop_home_command.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/contract/shop_home_contract.dart';
import 'package:pcplus/presenter/shop_home_presenter.dart';
import 'package:pcplus/singleton/shop_singleton.dart';
import 'package:pcplus/singleton/user_singleton.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/views/add_product.dart';
import 'package:pcplus/views/product/detail_product.dart';
import 'package:pcplus/views/widgets/bottom/shop_bottom_bar.dart';
import 'package:pcplus/views/widgets/util_widgets.dart';

import '../builders/widget_builders/shop_item_builder.dart';
import '../builders/widget_builders/widget_builder_director.dart';
import '../models/users/user_model.dart';
import '../objects/suggest_item_data.dart';
import 'edit_product.dart';
import 'home.dart';

class ShopHome extends StatefulWidget {
  const ShopHome({super.key});
  static const String routeName = 'shop_home';

  @override
  State<ShopHome> createState() => _ShopHomeState();
}

class _ShopHomeState extends State<ShopHome> implements ShopHomeContract {
  ShopHomePresenter? _presenter;
  final UserSingleton _userSingleton = UserSingleton.getInstance();
  WidgetBuilderDirector director = WidgetBuilderDirector();

  UserModel? shop;

  bool init = true;
  bool isShop = true;
  bool isLoading = true;
  String avatarUrl = "";

  List<Widget> productWidgets = [];

  @override
  void initState() {
    isShop = _userSingleton.isShop();
    shop = ShopSingleton.getInstance().shop;
    avatarUrl = shop!.avatarUrl ?? "";
    _presenter = ShopHomePresenter(this);
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
  void dispose() {
    super.dispose();
    _presenter?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: !isShop
          ? AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 30,
                ),
                onPressed: () {
                  _presenter!.handleBack();
                },
              ),
            )
          : null,
      body: Container(
        height: size.height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetHelper.shopBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isShop) const Gap(50),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image:
                        avatarUrl.isEmpty ?
                          const DecorationImage(
                            image: AssetImage(AssetHelper.shopAvt),
                            fit: BoxFit.cover,
                          )
                        :
                          DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                          ),
                    ),
                  ),
                  const Gap(10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        shop!.getShopName(),
                        style: TextDecor.robo24Bold.copyWith(
                          color: Palette.primaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.black,
                            size: 24,
                          ),
                          const Gap(10),
                          Text(
                            shop!.phone!,
                            style: TextDecor.robo18.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.black,
                            size: 28,
                          ),
                          const Gap(5),
                          Text(
                            shop!.getLocation(),
                            style: TextDecor.robo18.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(20),
              Text('Danh mục sản phẩm', style: TextDecor.robo18Bold),
              const Gap(10),
              if (isLoading)
                UtilWidgets.getLoadingWidgetWithContainer(
                    width: size.width,
                    height: size.height * 0.5
                )
              else if (productWidgets.isEmpty)
                UtilWidgets.getCenterTextWithContainer(
                    width: size.width,
                    height: size.height * 0.5,
                    text: "Không có sản phẩm nào",
                    color: Palette.primaryColor)
              else
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: productWidgets.length,
                  itemBuilder: (context, index) {
                    return productWidgets[index];
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: isShop
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AddProduct.routeName);
              },
              child: const Icon(
                Icons.add,
                size: 36,
              ),
            )
          : null,
      bottomNavigationBar: isShop ? const ShopBottomBar(currentIndex: 0) : null,
    );
  }

  Future<void> buildItemList() async {
    productWidgets.clear();
    ShopItemBuilder shopItemBuilder = ShopItemBuilder();
    for (ItemData item in _presenter!.itemsData) {
      director.makeShopItem(
          builder: shopItemBuilder,
          data: item,
          isShop: isShop,
          editCommand:
              ShopHomeItemEditCommand(presenter: _presenter!, item: item),
          deleteCommand:
              ShopHomeItemDeleteCommand(presenter: _presenter!, item: item),
          pressedCommand:
              ShopHomeItemPressedCommand(presenter: _presenter!, item: item)
      );
      productWidgets.add(shopItemBuilder.createWidget()!);
    }
    setState(() {});
  }

  @override
  void onItemEdit() {
    Navigator.of(context).pushNamed(EditProduct.routeName);
  }

  @override
  void onItemDelete() {
    setState(() {
      buildItemList();
    });
  }

  @override
  void onLoadDataSucceeded() {
    buildItemList();
    setState(() {
      isLoading = false;
    });
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
  void onFetchDataSucceeded() {
    setState(() {
      buildItemList();
    });
  }

  @override
  void onItemPressed() {
    Navigator.of(context).pushNamed(DetailProduct.routeName);
  }

  @override
  void onBack() {
    Navigator.of(context).pushNamed(HomeScreen.routeName);
  }
}
