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

  // ✅ Thêm controller cho exact matching
  StreamController<List<ItemWithSeller>>? _exactMatchController;
  StreamSubscription<List<ItemWithSeller>>? _exactMatchSubscription;

  // ✅ Lưu danh sách fuzzy search ban đầu
  List<ItemWithSeller> _fuzzySearchResults = [];

  // Getter cho stream
  Stream<List<ItemWithSeller>>? get searchItemStream =>
      _searchItemController?.stream;

  // ✅ Getter để UI có thể lấy fuzzy search results để sort
  List<ItemWithSeller> get fuzzySearchResults => List.from(_fuzzySearchResults);

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
      _exactMatchController =
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

            // ✅ CHỈ emit khi filter mode là DEFAULT hoặc chưa có filter nào được set
            if (filterMode == ItemFilter.DEFAULT) {
              _searchItemController!.add(limitedData);
            }
            // ✅ Nếu filter khác DEFAULT, chờ user chọn filter mới emit
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

      // ✅ Nếu filter là RELATED, cũng tạo exact match stream
      if (filterMode == ItemFilter.RELATED) {
        _exactMatchSubscription =
            _itemRepo.getItemsWithSellerExactMatch(searchQuery: input).listen(
          (data) {
            if (!_isDisposed &&
                _searchItemController != null &&
                !_searchItemController!.isClosed) {
              final limitedData = data.take(100).toList();
              _searchItemController!
                  .add(limitedData); // ✅ Emit exact match results
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
      }

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

    // ✅ Nếu chọn "Liên quan" và có search query, trigger exact matching
    if (filterMode == ItemFilter.RELATED && _currentSearchQuery.isNotEmpty) {
      _startExactMatching();
    } else {
      // ✅ Với các filter khác, KHÔNG emit data, chỉ báo UI sort
      // ✅ Cancel exact match subscription để không bị conflict
      _exactMatchSubscription?.cancel();
      _exactMatchSubscription = null;

      // ✅ CHỈ thông báo cho UI sort, KHÔNG emit data mới
      _view.onChangeFilter();
    }
  }

  // ✅ Method riêng để bắt đầu exact matching
  Future<void> _startExactMatching() async {
    if (_isDisposed || _currentSearchQuery.isEmpty) return;

    try {
      // Dispose exact match subscription cũ nếu có
      await _exactMatchSubscription?.cancel();

      // ✅ Emit empty list trước để clear UI
      if (_searchItemController != null && !_searchItemController!.isClosed) {
        _searchItemController!.add([]);
      }

      _exactMatchSubscription = _itemRepo
          .getItemsWithSellerExactMatch(searchQuery: _currentSearchQuery)
          .listen(
        (data) {
          if (!_isDisposed &&
              _searchItemController != null &&
              !_searchItemController!.isClosed) {
            final limitedData = data.take(100).toList();
            _searchItemController!.add(limitedData);
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
    } catch (e) {
      // Error handling
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

    await _exactMatchSubscription?.cancel();
    _exactMatchSubscription = null;

    if (_exactMatchController != null && !_exactMatchController!.isClosed) {
      await _exactMatchController!.close();
    }
    _exactMatchController = null;
  }
}
