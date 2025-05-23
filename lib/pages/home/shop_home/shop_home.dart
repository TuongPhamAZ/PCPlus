import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/commands/shop_home_command.dart';
import 'package:pcplus/component/item_argument.dart';
import 'package:pcplus/component/shop_argument.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/const/navigator_arguments.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/factories/widget_factories/shop_item_factory.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/home/shop_home/shop_home_contract.dart';
import 'package:pcplus/pages/home/shop_home/shop_home_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product.dart';
import '../../../models/shops/shop_model.dart';
import '../../manage_product/edit_product/edit_product.dart';
import '../../widgets/bottom/shop_bottom_bar.dart';
import '../../widgets/util_widgets.dart';
import '../user_home/home.dart';

class ShopHome extends StatefulWidget {
  const ShopHome({super.key});
  static const String routeName = 'shop_home';

  @override
  State<ShopHome> createState() => _ShopHomeState();
}

class _ShopHomeState extends State<ShopHome> implements ShopHomeContract {
  ShopHomePresenter? _presenter;

  ShopModel? shop;

  bool init = true;
  bool isShop = true;
  bool isLoading = true;
  String avatarUrl = "";
  String shopName = "";
  String shopPhone = "";
  String location = "";

  @override
  void initState() {
    isShop = SessionController.getInstance().isShop();
    _presenter = ShopHomePresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (SessionController.getInstance().isShop() == false) {
      final args = ModalRoute.of(context)!.settings.arguments as ShopArgument;
      _presenter!.userId = args.shop.shopID;
    }

    loadData();
  }

  Future<void> loadData() async {
    await _presenter?.getData();
  }

  @override
  void dispose() {
    super.dispose();
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
                        shopName,
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
                            shopPhone,
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
                            location,
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
              SizedBox(
                height: 585,
                width: size.width,
                child: StreamBuilder<List<ItemWithSeller>>(
                    stream: _presenter!.userItemsStream,
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
                        scrollDirection: Axis.vertical,
                        itemCount: itemsWithSeller.length,
                        itemBuilder: (context, index) {
                          return ShopItemFactory.create(
                              data: itemsWithSeller[index],
                              editCommand:
                              ShopHomeItemEditCommand(presenter: _presenter!, item: itemsWithSeller[index]),
                              deleteCommand:
                              ShopHomeItemDeleteCommand(presenter: _presenter!, item: itemsWithSeller[index]),
                              pressedCommand:
                              ShopHomeItemPressedCommand(presenter: _presenter!, item: itemsWithSeller[index]),
                              isShop: isShop
                          );
                        },
                      );
                    }
                ),
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

  @override
  void onItemEdit(ItemWithSeller item) {
    Navigator.of(context).pushNamed(
      EditProduct.routeName,
      arguments: ItemArgument(data: item),
    );
  }

  @override
  void onItemDelete() {
    // setState(() {
    //   buildItemList();
    // });
  }

  @override
  void onLoadDataSucceeded() {
    // buildItemList();
    if (!mounted) return;

    setState(() {
      shop = _presenter!.seller;
      avatarUrl = shop!.image ?? "";
      shopName = shop!.name!;
      shopPhone = shop!.phone!;
      location = shop!.location!;
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

  // @override
  // void onFetchDataSucceeded() {
  //   setState(() {
  //     buildItemList();
  //   });
  // }

  @override
  void onItemPressed(ItemWithSeller item) {
    Navigator.of(context).pushNamed(
        DetailProduct.routeName,
        arguments: ItemArgument(data: item),
    );
  }

  @override
  void onBack() {
    Navigator.of(context).pushNamed(HomeScreen.routeName);
  }
}
