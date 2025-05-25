import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/component/item_argument.dart';
import 'package:pcplus/component/shop_argument.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/const/navigator_arguments.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product_contract.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product_presenter.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/bill/bill_product/bill_product.dart';
import 'package:pcplus/pages/widgets/product_action_dialog.dart';
import 'package:pcplus/pages/widgets/listItem/review_item.dart';
import 'package:pcplus/pages/widgets/price_display_widget.dart';
import 'package:pcplus/pages/widgets/color_selection_widget.dart';
import 'package:pcplus/pages/manage_product/edit_product/edit_product.dart';

import '../../../models/shops/shop_model.dart';
import '../../../objects/review_data.dart';
import '../../home/shop_home/shop_home.dart';
import '../../widgets/util_widgets.dart';

class DetailProduct extends StatefulWidget {
  const DetailProduct({super.key});
  static const String routeName = 'detail_product';

  @override
  State<DetailProduct> createState() => _DetailProductState();
}

class _DetailProductState extends State<DetailProduct>
    implements DetailProductContract {
  DetailProductPresenter? _presenter;

  List<String> images = [];
  bool isShop = true;

  bool isLoading = true;

  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  String productName = "Product Name Here";
  String description = "description";
  String detail = "detail information\ndetail information";
  int stock = 100;
  int price = 200000;
  int sourcePrice = 300000; // Giá gốc
  int salePrice = 200000; // Giá bán
  int sold = 1000200;

  bool _detailInfor = false;
  double rating = 3.5;
  int selectedColorIndex = 0; // Màu được chọn hiện tại
  int soluong = 1;

  // Shop data
  String shopAvatar = "";
  String shopName = "King Shop";
  String shopPhone = "0123456789";
  String location = "TP. Ho Chi Minh";
  int productsCount = 50;

  List<ReviewData> reviews = [];

  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    _presenter = DetailProductPresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as ItemArgument;
    _presenter!.itemWithSeller = args.data;
    loadData();
  }

  Future<void> loadData() async {
    isShop = SessionController.getInstance().isSeller;
    await _presenter?.getData();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
      _scrollToIndex(index);
    });
  }

  void _scrollToIndex(int index) {
    _scrollController.animateTo(
      index * 80.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop(); // Đóng dialog
        });
        return AlertDialog(
          alignment: Alignment.center,
          content: Container(
            alignment: Alignment.center,
            height: 120,
            child: Column(
              children: [
                Expanded(child: Container()),
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 50,
                ),
                const Gap(10),
                Text(
                  'Add to cart successfully!',
                  style: TextDecor.robo18Semi.copyWith(
                    color: Colors.white,
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          backgroundColor: Colors.black.withOpacity(0.45),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading
          ? UtilWidgets.getLoadingWidget()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 45),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                _presenter?.handleBack();
                              },
                              child: Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Palette.borderBackBtn,
                                  ),
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.arrowLeft,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Gap(30),

                            //list small Image view
                            SizedBox(
                              width: 50,
                              height: 270,
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      _pageController.jumpToPage(index);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _selectedIndex == index
                                              ? Palette.primaryColor
                                              : Palette.borderBackBtn,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(images[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      //Big Image view
                      SizedBox(
                        height: 430,
                        width: size.width - 110,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                //Go to Full Screen Image View
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: InteractiveViewer(
                                          child: Image.network(
                                            images[index],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      Palette.backgroundColor.withOpacity(0.3),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(images[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: TextDecor.robo24Bold,
                          maxLines: 2,
                        ),
                        const Gap(8),
                        // Sử dụng PriceDisplayWidget
                        PriceDisplayWidget(
                          originalPrice: sourcePrice,
                          salePrice: salePrice,
                          salePriceFontSize: 20,
                          originalPriceFontSize: 16,
                          showDiscountBadge: true,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Palette.star,
                              size: 23,
                            ),
                            const Gap(3),
                            Text(
                              Utility.formatRatingValue(rating),
                              style: TextDecor.robo13Medi,
                            ),
                            Expanded(child: Container()),
                            Text(
                              Utility.formatSoldCount(sold),
                              style: TextDecor.robo13Medi,
                            ),
                          ],
                        ),
                        const Gap(10),
                        Text(
                          description,
                          style: TextDecor.robo15,
                          maxLines: 3,
                        ),
                        const Gap(10),
                        Row(
                          children: [
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: Palette.backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.document_scanner_outlined,
                                color: Palette.primaryColor,
                              ),
                            ),
                            const Gap(10),
                            Text(
                              'Product Specifications',
                              style: TextDecor.robo16,
                            ),
                            Expanded(child: Container()),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _detailInfor = !_detailInfor;
                                });
                              },
                              icon: Icon(
                                _detailInfor
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        if (_detailInfor)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              detail,
                              style:
                                  TextDecor.robo15.copyWith(wordSpacing: 1.5),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 42,
                                  width: 42,
                                  decoration: BoxDecoration(
                                    color: Palette.backgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.palette_outlined,
                                    color: Palette.primaryColor,
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  'Color',
                                  style: TextDecor.robo16,
                                ),
                              ],
                            ),
                            const Gap(10),
                            // Sử dụng ColorSelectionWidget
                            ColorSelectionWidget(
                              colors:
                                  _presenter?.itemWithSeller?.item.colors ?? [],
                              selectedColorIndex: selectedColorIndex,
                              onColorSelected: (index) {
                                setState(() {
                                  selectedColorIndex = index;
                                  // Cập nhật PageView để hiển thị hình ảnh theo màu được chọn
                                  _updateImageForSelectedColor(index);
                                });
                              },
                              containerHeight: 45,
                              containerWidth: 120,
                            ),
                          ],
                        ),
                        const Gap(20),
                        // Chỉ hiển thị section shop khi KHÔNG phải là shop (isShop = false)
                        if (!isShop)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Palette.borderBackBtn),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 110,
                                  width: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(80),
                                    image: shopAvatar.isEmpty
                                        ? const DecorationImage(
                                            image:
                                                AssetImage(AssetHelper.shopAvt),
                                            fit: BoxFit.cover,
                                          )
                                        : DecorationImage(
                                            image: NetworkImage(shopAvatar),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                const Gap(16),
                                SizedBox(
                                  height: 110,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: size.width - 180,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                shopName,
                                                style: TextDecor.robo18Semi,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () {
                                                //Go to Shop view
                                                _presenter?.handleViewShop();
                                              },
                                              child: Container(
                                                height: 24,
                                                width: 85,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.red,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  'View Shop',
                                                  style:
                                                      TextDecor.robo14.copyWith(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        shopPhone,
                                        style: TextDecor.robo16,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                          Text(
                                            location,
                                            style: TextDecor.robo16,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "$productsCount",
                                            style: TextDecor.robo16.copyWith(
                                              color: Colors.red,
                                            ),
                                          ),
                                          const Gap(5),
                                          Text(
                                            'Products',
                                            style: TextDecor.robo16,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!isShop) const Gap(20),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                        ),
                        const Gap(8),
                        Text("Product's Reviews", style: TextDecor.robo18Semi),
                        Row(
                          children: [
                            RatingBar.builder(
                              initialRating: rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 18,
                              unratedColor: const Color(0xffDADADA),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              onRatingUpdate: (value) {},
                              ignoreGestures: true,
                            ),
                            const Gap(6),
                            Text(
                              '$rating/5',
                              style: TextDecor.robo16.copyWith(
                                color: Colors.red,
                              ),
                            ),
                            const Gap(3),
                            Text(
                              '(${reviews.length} Reviews)',
                              style: TextDecor.robo16.copyWith(
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        reviews.isEmpty
                            ? UtilWidgets.getCenterTextWithContainer(
                                width: size.width,
                                height: 30,
                                text: "No review",
                                color: Palette.primaryColor,
                                fontSize: 16)
                            : ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(0),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reviews.length,
                                itemBuilder: (context, index) {
                                  final review = reviews[index];
                                  final rating = review.rating!;
                                  final user = review.user!;

                                  return ReviewItem(
                                    name: user.name!,
                                    date: rating.date!,
                                    comment: rating.comment ?? '',
                                    rating: rating.rating,
                                    avatarUrl: user.avatarUrl,
                                    response: rating.response,
                                    isShop: isShop,
                                    onResponseSubmit: (responseText) {
                                      _presenter!.onSendResponse(rating, responseText);
                                    },
                                  );
                                },
                              ),
                        const Gap(30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      // Chỉ hiển thị bottomNavigationBar khi KHÔNG phải là shop (isShop = false)
      bottomNavigationBar: !isShop && !isLoading
          ? Container(
              height: 55,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      _showProductActionDialog(
                        context: context,
                        title: 'Add to Cart',
                        buttonText: 'Add to Cart',
                        buttonColor: Colors.blueGrey,
                        onAction: () {
                          Navigator.pop(context);
                          _presenter?.handleAddToCart(amount: soluong, colorIndex: selectedColorIndex);
                        },
                      );
                    },
                    child: Container(
                      width: size.width / 2,
                      height: 55,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          Text(
                            'Add to Cart',
                            style: TextDecor.robo16Semi.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _showProductActionDialog(
                        context: context,
                        title: 'Buy now',
                        buttonText: 'Buy now',
                        buttonColor: Colors.red,
                        onAction: () {
                          Navigator.pop(context);
                          _presenter?.handleBuyNow(
                              amount: soluong, colorIndex: selectedColorIndex);
                        },
                      );
                    },
                    child: Container(
                      width: size.width / 2,
                      height: 55,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Buy now',
                        style: TextDecor.robo24Medi.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      // Thêm FloatingActionButton khi isShop = true
      floatingActionButton: isShop && !isLoading
          ? FloatingActionButton(
              onPressed: () {
                // Chuyển đến màn hình EditProduct
                Navigator.of(context).pushNamed(
                  EditProduct.routeName,
                  arguments: ItemArgument(data: _presenter!.itemWithSeller!),
                );
              },
              backgroundColor: Palette.primaryColor,
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 24,
              ),
            )
          : null,
    );
  }

  @override
  void onAddToCart() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Tự động đóng dialog sau 3 giây
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop(); // Đóng dialog
          // Hiển thị dialog thông báo thành công
          _showSuccessDialog(context);
        });

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void onBack() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onBuyNow() {
    Navigator.of(context).pushNamed(BillProduct.routeName);
  }

  @override
  void onViewShop(ShopModel seller) {
    Navigator.of(context)
        .pushNamed(ShopHome.routeName, arguments: ShopArgument(shop: seller));
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
  void onError(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onLoadDataSucceeded() {
    if (!mounted) return;

    setState(() {
      // isShop = SessionController.getInstance().isShop(); // Comment để test shop owner view
      productName = _presenter!.itemWithSeller!.item.name!;
      description = _presenter!.itemWithSeller!.item.description!;
      detail = _presenter!.itemWithSeller!.item.detail!;
      stock = _presenter!.itemWithSeller!.item.stock!;
      price = _presenter!.itemWithSeller!.item.price!;
      sourcePrice = _presenter!.itemWithSeller!.item.price!;
      salePrice = _presenter!.itemWithSeller!.item.discountPrice ??
          _presenter!.itemWithSeller!.item.price!;
      sold = _presenter!.itemWithSeller!.item.sold!;
      rating = _presenter!.itemWithSeller!.item.rating ?? 0;
      shopName = _presenter!.itemWithSeller!.seller.name!;
      location = _presenter!.itemWithSeller!.seller.location!;
      shopAvatar = _presenter!.itemWithSeller!.seller.image ?? "";
      productsCount = _presenter!.shopProductsCount;
      reviews = _presenter!.ratingsData;
      images = _presenter!.itemWithSeller!.item.reviewImages!;

      isLoading = false;
    });
  }

  // Helper method để lấy hình ảnh của màu được chọn
  String _getSelectedColorImage() {
    if (_presenter?.itemWithSeller?.item.colors != null &&
        _presenter!.itemWithSeller!.item.colors!.isNotEmpty &&
        selectedColorIndex < _presenter!.itemWithSeller!.item.colors!.length) {
      final selectedColor =
          _presenter!.itemWithSeller!.item.colors![selectedColorIndex];
      if (selectedColor.image != null && selectedColor.image!.isNotEmpty) {
        return selectedColor.image!;
      }
    }
    // Fallback về hình ảnh đầu tiên nếu không có hình ảnh màu
    return images.isNotEmpty ? images.first : '';
  }

  // Method để cập nhật hình ảnh khi chọn màu
  void _updateImageForSelectedColor(int colorIndex) {
    if (_presenter?.itemWithSeller?.item.colors != null &&
        _presenter!.itemWithSeller!.item.colors!.isNotEmpty &&
        colorIndex < _presenter!.itemWithSeller!.item.colors!.length) {
      final selectedColor =
          _presenter!.itemWithSeller!.item.colors![colorIndex];

      // Nếu màu có hình ảnh riêng
      if (selectedColor.image != null && selectedColor.image!.isNotEmpty) {
        // Tạo danh sách images mới bao gồm ảnh màu + reviewImages
        List<String> combinedImages = [];

        // Thêm ảnh của màu được chọn vào đầu
        combinedImages.add(selectedColor.image!);

        // Thêm các reviewImages (loại bỏ duplicate nếu có)
        for (String reviewImage
            in _presenter!.itemWithSeller!.item.reviewImages!) {
          if (!combinedImages.contains(reviewImage)) {
            combinedImages.add(reviewImage);
          }
        }

        // Cập nhật danh sách images và jump đến ảnh màu (index 0)
        setState(() {
          images = combinedImages;
        });
        _pageController.jumpToPage(0);
        return;
      }

      // Nếu màu không có hình ảnh riêng, về lại reviewImages gốc
      setState(() {
        images = _presenter!.itemWithSeller!.item.reviewImages!;
      });

      // Map theo index màu nếu có đủ ảnh, ngược lại về ảnh đầu
      int targetIndex = colorIndex < images.length ? colorIndex : 0;
      _pageController.jumpToPage(targetIndex);
    }
  }

  // Method để hiển thị ProductActionDialog
  void _showProductActionDialog({
    required BuildContext context,
    required String title,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onAction,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ProductActionDialog(
          title: title,
          buttonText: buttonText,
          buttonColor: buttonColor,
          productImages: images, // Truyền toàn bộ danh sách hình ảnh
          price: salePrice,
          stock: stock,
          initialQuantity: soluong,
          initialSelectedColorIndex:
              selectedColorIndex, // Truyền màu hiện tại như khởi tạo
          colors: _presenter?.itemWithSeller?.item.colors ?? [],
          onAction: onAction,
          onQuantityChanged: (quantity) {
            setState(() {
              soluong = quantity; // Chỉ cập nhật quantity, không cập nhật màu
            });
          },
        );
      },
    );
  }

  @override
  void onResponseRatingFailed(String message) {
    // TODO: implement onResponseRatingFailed
  }

  @override
  void onResponseRatingSuccess() {
    UtilWidgets.createSnackBar(
      context,
      'Phản hồi đã được gửi thành công!',
      backgroundColor: Colors.green,
    );
  }
}
