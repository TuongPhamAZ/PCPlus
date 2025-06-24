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

  // Getter cho stream
  Stream<List<ItemWithSeller>>? get searchItemStream =>
      _searchItemController?.stream;

  String filterMode = ItemFilter.RELATED;
  bool _isDisposed = false;

  void handleBack() {
    _view.onBack();
  }

  Future<void> handleSearch(String input) async {
    if (_isDisposed) return;

    _view.onStartSearching();

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

      // ✅ FIX: Tạo subscription mới với controller mới
      _searchItemSubscription =
          _itemRepo.getItemsWithSeller(searchQuery: input).listen(
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
    _view.onChangeFilter();
  }

  List<ItemWithSeller> filter(List<ItemWithSeller> itemWithSellers) {
    switch (filterMode) {
      case ItemFilter.RELATED:
        {
          itemWithSellers.sort((item1, item2) {
            return item1.item.name!.compareTo(item2.item.name!);
          });
          break;
        }
      case ItemFilter.NEWEST:
        {
          itemWithSellers.sort((item1, item2) {
            return item1.item.addDate!.compareTo(item2.item.addDate!);
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
