import '../../const/item_filter.dart';
import '../../models/items/item_repo.dart';
import '../../models/items/item_with_seller.dart';
import '../../models/shops/shop_repo.dart';
import 'image_search_result_contract.dart';

class ImageSearchResultPresenter {
  final ImageSearchResultContract _view;
  ImageSearchResultPresenter(this._view);

  final ItemRepository _itemRepo = ItemRepository();
  final ShopRepository _shopRepo = ShopRepository();

  List<ItemWithSeller> allItems = [];
  List<ItemWithSeller> filteredItems = [];
  String currentFilter = ItemFilter.RELATED;

  Future<void> loadProductsByIds(List<String> productIds) async {
    try {
      if (productIds.isEmpty) {
        allItems = [];
        filteredItems = [];
        _view.onLoadDataSucceed();
        return;
      }

      // Lấy thông tin sản phẩm từ database dựa trên danh sách ID
      List<ItemWithSeller> items = [];
      for (String productId in productIds) {
        try {
          final itemWithSeller = await _getItemWithSellerById(productId);
          if (itemWithSeller != null) {
            items.add(itemWithSeller);
          }
        } catch (e) {
          print('Error loading product $productId: $e');
          // Tiếp tục với các sản phẩm khác
        }
      }

      allItems = items;
      filteredItems = List.from(allItems);

      // Áp dụng filter mặc định
      setFilter(currentFilter);

      _view.onLoadDataSucceed();
    } catch (e) {
      print('Error loading products: $e');
      _view.onLoadDataFailed('Lỗi khi tải danh sách sản phẩm: $e');
    }
  }

  Future<ItemWithSeller?> _getItemWithSellerById(String productId) async {
    try {
      final item = await _itemRepo.getItemById(productId);
      if (item == null) return null;

      final seller = await _shopRepo.getShopById(item.sellerID!);
      if (seller == null) return null;

      return ItemWithSeller(item: item, seller: seller);
    } catch (e) {
      print('Error getting item with seller: $e');
      return null;
    }
  }

  void setFilter(String filter) {
    currentFilter = filter;
    filteredItems = List.from(allItems);

    switch (filter) {
      case ItemFilter.RELATED:
        // Giữ nguyên thứ tự từ API (đã được sắp xếp theo độ tương đồng)
        break;
      case ItemFilter.NEWEST:
        filteredItems.sort((a, b) => (b.item.addDate ?? DateTime.now())
            .compareTo(a.item.addDate ?? DateTime.now()));
        break;
      case ItemFilter.PRICE_ASCENDING:
        filteredItems.sort((a, b) => (a.item.discountPrice ?? a.item.price ?? 0)
            .compareTo(b.item.discountPrice ?? b.item.price ?? 0));
        break;
      case ItemFilter.PRICE_DESCENDING:
        filteredItems.sort((a, b) => (b.item.discountPrice ?? b.item.price ?? 0)
            .compareTo(a.item.discountPrice ?? a.item.price ?? 0));
        break;
      default:
        break;
    }
  }

  void handleItemPressed(ItemWithSeller item) {
    _view.onItemPressed(item);
  }

  void handleBack() {
    _view.onBack();
  }
}
