import 'package:pcplus/const/item_filter.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/search/search_screen_contract.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'dart:async';

class SearchScreenPresenter {
  final SearchScreenContract _view;
  SearchScreenPresenter(this._view);

  final ItemRepository _itemRepo = ItemRepository();

  // StreamController để quản lý lifecycle
  StreamController<List<ItemWithSeller>>? _searchItemController;
  StreamSubscription<List<ItemWithSeller>>? _searchItemSubscription;

  // ✅ Lưu danh sách fuzzy search ban đầu
  List<ItemWithSeller> _fuzzySearchResults = [];

  // Getter cho stream
  Stream<List<ItemWithSeller>>? get searchItemStream =>
      _searchItemController?.stream;

  // ✅ Getter để UI có thể lấy fuzzy search results để sort
  List<ItemWithSeller> get fuzzySearchResults => List.from(_fuzzySearchResults);

  // ✅ Method để apply exact matching lên fuzzy search results
  List<ItemWithSeller> _applyExactMatching(
      List<ItemWithSeller> items, String searchQuery) {
    if (searchQuery.isEmpty) return items;

    final searchLower = searchQuery.toLowerCase();
    return items.where((itemWithSeller) {
      // Kiểm tra tên sản phẩm
      if (itemWithSeller.item.name!.toLowerCase().contains(searchLower)) {
        return true;
      }

      // Kiểm tra loại sản phẩm
      if (itemWithSeller.item.itemType!.toLowerCase().contains(searchLower)) {
        return true;
      }

      // Kiểm tra tên shop
      if (itemWithSeller.seller.name!.toLowerCase().contains(searchLower)) {
        return true;
      }

      return false;
    }).toList();
  }

  String filterMode = ItemFilter.DEFAULT;
  bool _isDisposed = false;
  String _currentSearchQuery = '';

  void handleBack() {
    _view.onBack();
  }

  Future<void> handleSearch(String input) async {
    if (_isDisposed) return;

    _view.onStartSearching();
    _currentSearchQuery = input;

    if (input.isEmpty) {
      _view.onFinishSearching();
      return;
    }

    try {
      // ✅ FIX: Dispose stream cũ hoàn toàn trước khi tạo mới
      await _disposeStreams();

      // ✅ FIX: Tạo controller mới cho mỗi lần search
      _searchItemController =
          StreamController<List<ItemWithSeller>>.broadcast();

      // ✅ Luôn bắt đầu với fuzzy search để lưu danh sách gốc
      _searchItemSubscription =
          _itemRepo.getItemsWithSeller(searchQuery: input).listen(
        (data) {
          if (!_isDisposed &&
              _searchItemController != null &&
              !_searchItemController!.isClosed) {
            final limitedData = data.take(100).toList();
            _fuzzySearchResults = limitedData; // ✅ Lưu danh sách fuzzy search

            // ✅ CHỈ emit khi filter mode là DEFAULT
            if (filterMode == ItemFilter.DEFAULT) {
              _searchItemController!.add(limitedData);
            } else if (filterMode == ItemFilter.RELATED) {
              // ✅ Nếu đang ở mode RELATED, apply exact matching ngay
              final exactMatchResults = _applyExactMatching(limitedData, input);
              _searchItemController!.add(exactMatchResults);
            }
            // ✅ Các filter khác sẽ được xử lý khi user trigger onChangeFilter
          }
        },
        onError: (error) {
          if (!_isDisposed &&
              _searchItemController != null &&
              !_searchItemController!.isClosed) {
            _searchItemController!.addError(error);
          }
        },
      );

      _view.onFinishSearching();
    } catch (e) {
      // ✅ Error handling để tránh crash
      if (!_isDisposed) {
        _view.onFinishSearching();
      }
    }
  }

  void setFilter(String filterMode) {
    this.filterMode = filterMode;

    // ✅ Nếu chọn "Liên quan", apply exact matching lên fuzzy search results
    if (filterMode == ItemFilter.RELATED &&
        _currentSearchQuery.isNotEmpty &&
        _fuzzySearchResults.isNotEmpty) {
      // ✅ Apply exact matching lên fuzzy search results
      final exactMatchResults =
          _applyExactMatching(_fuzzySearchResults, _currentSearchQuery);

      // ✅ Emit kết quả exact matching
      if (_searchItemController != null && !_searchItemController!.isClosed) {
        _searchItemController!.add(exactMatchResults);
      }
    } else {
      // ✅ Với các filter khác, KHÔNG emit data, chỉ báo UI sort
      _view.onChangeFilter();
    }
  }

  List<ItemWithSeller> filter(List<ItemWithSeller> itemWithSellers) {
    switch (filterMode) {
      case ItemFilter.RELATED:
        {
          // ✅ Khi dùng "Liên quan", không cần sort vì đã dùng exact matching
          // Giữ nguyên thứ tự từ exact matching search
          break;
        }
      case ItemFilter.NEWEST:
        {
          itemWithSellers.sort((item1, item2) {
            return item2.item.addDate!.compareTo(item1.item
                .addDate!); // ✅ Sửa từ item1->item2 thành item2->item1 để mới nhất lên đầu
          });
          break;
        }
      case ItemFilter.PRICE_ASCENDING:
        {
          itemWithSellers.sort((item1, item2) {
            return item1.item.price!.compareTo(item2.item.price!);
          });
          break;
        }
      case ItemFilter.PRICE_DESCENDING:
        {
          itemWithSellers.sort((item1, item2) {
            return item1.item.price!.compareTo(item2.item.price!) * -1;
          });
          break;
        }
      default:
        {
          // ✅ DEFAULT case - giữ nguyên thứ tự từ fuzzy search
          break;
        }
    }
    return itemWithSellers;
  }

  Future<void> handleItemPressed(ItemWithSeller item) async {
    _view.onWaitingProgressBar();
    //
    _view.onPopContext();
    _view.onSelectItem(item);
  }

  Future<void> dispose() async {
    _isDisposed = true;
    _fuzzySearchResults.clear(); // ✅ Clear danh sách fuzzy search
    await _disposeStreams();
  }

  Future<void> _disposeStreams() async {
    await _searchItemSubscription?.cancel();
    _searchItemSubscription = null;

    if (_searchItemController != null && !_searchItemController!.isClosed) {
      await _searchItemController!.close();
    }
    _searchItemController = null;
  }
}
