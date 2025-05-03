import 'package:pcplus/const/item_filter.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/search/search_screen_contract.dart';
import 'package:pcplus/models/items/item_repo.dart';

class SearchScreenPresenter {
  final SearchScreenContract _view;
  SearchScreenPresenter(this._view);

  final ItemRepository _itemRepo = ItemRepository();

  Stream<List<ItemWithSeller>>? searchItemStream;

  String filterMode = ItemFilter.RELATED;

  void handleBack() {
    _view.onBack();
  }

  Future<void> handleSearch(String input) async {
    _view.onStartSearching();

    if (input.isEmpty) {
      _view.onFinishSearching();
      return;
    }

    searchItemStream = _itemRepo.getItemsWithSeller(searchQuery: input);

    _view.onFinishSearching();
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
    _view.onSelectItem();
  }
}