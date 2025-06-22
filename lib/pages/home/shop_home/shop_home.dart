// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/commands/shop_home_command.dart';
import 'package:pcplus/component/item_argument.dart';
import 'package:pcplus/component/shop_argument.dart';
import 'package:pcplus/component/voucher_argument.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/factories/widget_factories/shop_item_factory.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/models/vouchers/voucher_model.dart';
import 'package:pcplus/pages/home/shop_home/shop_home_contract.dart';
import 'package:pcplus/pages/home/shop_home/shop_home_presenter.dart';
import 'package:pcplus/pages/voucher/widget/voucher_item.dart';
import 'package:pcplus/pages/voucher/editvoucher/edit_voucher.dart';
import 'package:pcplus/pages/voucher/voucherDetail/voucher_detail.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product.dart';
import 'package:pcplus/pages/voucher/addvoucher/add_voucher.dart';
import 'package:pcplus/pages/voucher/listvoucher/list_voucher.dart';
import 'package:pcplus/pages/conversations/conversations.dart';
import '../../../models/shops/shop_model.dart';
import '../../../models/users/user_model.dart';
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

  bool init = false;
  bool isShop = false;
  bool isLoading = true;
  String avatarUrl = "";
  String shopName = "";
  String shopPhone = "";
  String location = "";

  // Balance related variables
  int balance = 0; // Mock balance
  bool isBalanceVisible = false; // State to show/hide balance

  // Mock voucher data
  // List<VoucherModel> _mockVouchers = [];

  final ValueNotifier<int> _voucherCount = ValueNotifier<int>(0);

  @override
  void initState() {
    isShop = SessionController.getInstance().isShop();
    _presenter = ShopHomePresenter(this);
    // _initMockVouchers();
    super.initState();
    SessionController.getInstance().changeUserCallback.add(balanceChangeHandler);
  }

  // void _initMockVouchers() {
  //   _mockVouchers = [
  //     VoucherModel(
  //       voucherID: "1",
  //       name: "Giảm 50k",
  //       description: "Voucher giảm 50,000đ cho đơn hàng từ 200,000đ",
  //       condition: 200000,
  //       endDate: DateTime.now().add(const Duration(days: 30)),
  //       discount: 50000,
  //       quantity: 100,
  //     ),
  //     VoucherModel(
  //       voucherID: "2",
  //       name: "Giảm 20%",
  //       description: "Voucher giảm 20% tối đa 100,000đ",
  //       condition: 500000,
  //       endDate: DateTime.now().add(const Duration(days: 15)),
  //       discount: 100000,
  //       quantity: 50,
  //     ),
  //     VoucherModel(
  //       voucherID: "3",
  //       name: "Freeship",
  //       description: "Miễn phí vận chuyển cho đơn từ 100,000đ",
  //       condition: 100000,
  //       endDate: DateTime.now().add(const Duration(days: 7)),
  //       discount: 30000,
  //       quantity: 0, // Out of stock
  //     ),
  //     VoucherModel(
  //       voucherID: "4",
  //       name: "Black Friday",
  //       description: "Giảm 300,000đ cho đơn hàng trên 1 triệu",
  //       condition: 1000000,
  //       endDate: DateTime.now().subtract(const Duration(days: 1)), // Expired
  //       discount: 300000,
  //       quantity: 25,
  //     ),
  //   ];
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (init) return;
    init = true;

    if (SessionController.getInstance().isShop() == false) {
      final args = ModalRoute.of(context)!.settings.arguments as ShopArgument;
      _presenter!.userId = args.shop.shopID;
    } else {
      balance = 0;
    }

    loadData();
  }

  Future<void> loadData() async {
    if (isShop) {
      // chờ lấy thông tin user
      while (SessionController.getInstance().currentUser == null) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      balance = SessionController.getInstance().currentUser!.money!;
    }
    await _presenter?.getData();
  }

  @override
  void dispose() {
    super.dispose();
    SessionController.getInstance().changeUserCallback.remove(balanceChangeHandler);
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
                      image: avatarUrl.isEmpty
                          ? const DecorationImage(
                              image: AssetImage(AssetHelper.shopAvt),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          shopName,
                          style: TextDecor.robo24Bold.copyWith(
                            color: Palette.primaryColor,
                          ),
                        ),
                        const Gap(4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.black,
                              size: 20,
                            ),
                            const Gap(8),
                            Text(
                              shopPhone,
                              style: TextDecor.robo16.copyWith(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.black,
                              size: 20,
                            ),
                            const Gap(8),
                            Flexible(
                              child: Text(
                                location,
                                style: TextDecor.robo16.copyWith(
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // Hiển thị số dư khi là shop
                        if (isShop) ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Palette.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Palette.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet,
                                  color: Palette.primaryColor,
                                  size: 18,
                                ),
                                const Gap(8),
                                Text(
                                  'Số dư: ',
                                  style: TextDecor.robo14.copyWith(
                                    color: Palette.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  isBalanceVisible
                                      ? '${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ'
                                      : '••••••••',
                                  style: TextDecor.robo14.copyWith(
                                    color: Palette.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isBalanceVisible = !isBalanceVisible;
                                    });
                                  },
                                  child: Icon(
                                    isBalanceVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Palette.primaryColor,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(20),

              // Voucher section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mã giảm giá', style: TextDecor.robo18Bold),
                  GestureDetector(
                    onTap: _navigateToVoucherList,
                    child: Row(
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: _voucherCount,
                          builder: (context, value, _) => Text(
                            'Xem tất cả ($value)',
                            style: TextDecor.robo14.copyWith(
                              color: Palette.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Gap(4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Palette.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(12),
              SizedBox(
                height: 140,
                child: StreamBuilder<List<VoucherModel>>(
                    stream: _presenter!.voucherStream,
                    builder: (context, snapshot) {
                      Widget? result = UtilWidgets.createSnapshotResultWidget(
                          context, snapshot);
                      if (result != null) {
                        return result;
                      }

                      var vouchers = snapshot.data ?? [];

                      if (SessionController.getInstance().isSeller == false) {
                        // lọc các voucher không khả dụng cho người dùng
                        vouchers = vouchers
                            .where((v) =>
                                v.quantity! > 0 &&
                                v.endDate!.isAfter(DateTime.now()))
                            .toList();
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _voucherCount.value = vouchers.length;
                      });

                      if (vouchers.isEmpty) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const Gap(8),
                                Text(
                                  'Chưa có voucher nào',
                                  style: TextDecor.robo14.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemCount: vouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = vouchers[index];
                          return VoucherItem(
                            voucher: voucher,
                            isShop: isShop,
                            onTap: () => _presenter?.handleViewVoucher(voucher),
                            onEdit: () =>
                                _presenter?.handleEditVoucher(voucher),
                            onDelete: () => _showDeleteVoucherDialog(voucher),
                          );
                        },
                      );
                    }),
              ),
              const Gap(24),

              Text('Danh mục sản phẩm', style: TextDecor.robo18Bold),
              const Gap(10),
              SizedBox(
                height: 585,
                width: size.width,
                child: StreamBuilder<List<ItemWithSeller>>(
                    stream: _presenter!.userItemsStream,
                    builder: (context, snapshot) {
                      Widget? result = UtilWidgets.createSnapshotResultWidget(
                          context, snapshot);
                      if (result != null) {
                        return result;
                      }

                      final itemsWithSeller = snapshot.data ?? [];

                      if (itemsWithSeller.isEmpty) {
                        return const Center(child: Text('Không có sản phẩm nào'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        itemCount: itemsWithSeller.length,
                        itemBuilder: (context, index) {
                          return ShopItemFactory.create(
                              data: itemsWithSeller[index],
                              editCommand: ShopHomeItemEditCommand(
                                  presenter: _presenter!,
                                  item: itemsWithSeller[index]),
                              deleteCommand: ShopHomeItemDeleteCommand(
                                  presenter: _presenter!,
                                  item: itemsWithSeller[index]),
                              pressedCommand: ShopHomeItemPressedCommand(
                                  presenter: _presenter!,
                                  item: itemsWithSeller[index]),
                              isShop: isShop);
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isShop
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Chat floating button
                FloatingActionButton(
                  heroTag:
                      "chat_fab", // Unique tag to avoid hero animation conflicts
                  onPressed: () {
                    Navigator.pushNamed(context, ConversationsScreen.routeName);
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(
                    Icons.chat,
                    color: Colors.white,
                  ),
                ),
                const Gap(16),
                // Add floating button
                FloatingActionButton(
                  heroTag:
                      "add_fab", // Unique tag to avoid hero animation conflicts
                  onPressed: _showAddOptionsDialog,
                  backgroundColor: Palette.primaryColor,
                  child: const Icon(
                    Icons.add,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ],
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

  void _showAddOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thêm mới',
                  style: TextDecor.robo18Bold.copyWith(
                    color: Palette.primaryColor,
                    fontSize: 20,
                  ),
                ),
                const Gap(24),

                // Nút Thêm sản phẩm mới
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AddProduct.routeName);
                    },
                    icon: const Icon(
                      Icons.shopping_bag,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Thêm sản phẩm mới',
                      style: TextDecor.robo16Medi.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const Gap(12),

                // Nút Thêm voucher mới
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AddVoucher.routeName);
                    },
                    icon: const Icon(
                      Icons.local_offer,
                      size: 24,
                      color: Palette.primaryColor,
                    ),
                    label: Text(
                      'Thêm voucher mới',
                      style: TextDecor.robo16Medi.copyWith(
                        color: Palette.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                          color: Palette.primaryColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const Gap(20),

                // Nút Cancel
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Hủy',
                    style: TextDecor.robo16.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Navigation functions
  @override
  void onVoucherEdit(VoucherModel voucher) {
    // Tìm voucher object từ ID
    // VoucherModel? voucher = _mockVouchers.firstWhere(
    //   (v) => v.voucherID == voucherId,
    //   orElse: () => VoucherModel(
    //     voucherID: voucherId,
    //     name: "Unknown Voucher",
    //     description: "Voucher không xác định",
    //     condition: 0,
    //     endDate: DateTime.now().add(const Duration(days: 30)),
    //     discount: 0,
    //     quantity: 0,
    //   ),
    // );

    Navigator.of(context).pushNamed(
      EditVoucher.routeName,
      arguments: VoucherArgument(data: voucher),
    );
  }

  @override
  void onVoucherPressed(VoucherModel voucher) {
    // Tìm voucher object từ ID
    // VoucherModel? voucher = _mockVouchers.firstWhere(
    //   (v) => v.voucherID == voucherId,
    //   orElse: () => VoucherModel(
    //     voucherID: voucherId,
    //     name: "Unknown Voucher",
    //     description: "Voucher không xác định",
    //     condition: 0,
    //     endDate: DateTime.now().add(const Duration(days: 30)),
    //     discount: 0,
    //     quantity: 0,
    //   ),
    // );

    Navigator.of(context).pushNamed(
      VoucherDetail.routeName,
      arguments: VoucherArgument(data: voucher),
    );
  }

  void _navigateToVoucherList() {
    Navigator.of(context)
        .pushNamed(ListVoucher.routeName, arguments: ShopArgument(shop: shop!));
  }

  void _showDeleteVoucherDialog(VoucherModel voucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const Gap(16),
                Text(
                  'Xác nhận xóa voucher',
                  style: TextDecor.robo18Bold.copyWith(
                    color: Colors.black87,
                  ),
                ),
                const Gap(12),
                Text(
                  'Bạn có chắc chắn muốn xóa voucher "${voucher.name}"?\nHành động này không thể hoàn tác.',
                  style: TextDecor.robo14.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextDecor.robo14.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // TODO: Delete voucher logic
                          _presenter?.handleDeleteVoucher(voucher);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Xóa',
                          style: TextDecor.robo14.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void onVoucherDelete(VoucherModel voucher) {
    UtilWidgets.createSnackBar(context, "Đã xóa voucher: ${voucher.name}");
  }

  // Callback
  void balanceChangeHandler(UserModel? user) {
    if (!mounted) return;
    if (user != null) {
      setState(() {
        balance = user.money!;
      });
    }
  }
}
