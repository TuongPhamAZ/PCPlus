import 'package:pcplus/builders/object_builders/list_item_data_builder.dart';
import 'package:pcplus/builders/object_builders/list_object_builder_director.dart';
import 'package:pcplus/const/item_filter.dart';
import 'package:pcplus/contract/search_screen_contract.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/objects/suggest_item_data.dart';
import 'package:pcplus/services/test_tool.dart';
import 'package:pcplus/singleton/view_item_singleton.dart';

import '../models/items/item_model.dart';
import '../models/users/user_model.dart';

class SearchScreenPresenter {
  final SearchScreenContract _view;
  SearchScreenPresenter(this._view);

  final ViewItemSingleton _itemSingleton = ViewItemSingleton.getInstance();
  final ItemRepository _itemRepo = ItemRepository();
  final ListItemDataBuilder builder = ListItemDataBuilder();

  List<ItemData> searchItemData = [];

  String filterMode = ItemFilter.RELATED;

  void handleBack() {
    _view.onBack();
  }

  Future<void> handleSearch(String input) async {
    _view.onStartSearching();

    List<ItemModel> searchResults = [];
    Map<String, UserModel> shops = {};

    if (input.isEmpty) {
      setFilter(filterMode);
      _view.onFinishSearching();
      return;
    }

    ListObjectBuilderDirector director = ListObjectBuilderDirector();

    searchResults = await _itemRepo.getItemsBySearchInput(input);

    await director.makeListItemData(builder: builder, items: searchResults, shops: shops);
    searchItemData = builder.createList().cast();

    //searchResults = await _itemRepo.getItemsBySearchInput(input);

    setFilter(filterMode);
    _view.onFinishSearching();
  }

  void setFilter(String filterMode) {
    this.filterMode = filterMode;
    List<ItemData> showResults = List.from(searchItemData);
    switch (filterMode) {
      case ItemFilter.RELATED:
        {
          showResults.sort((item1, item2) {
            return item1.product!.name!.compareTo(item2.product!.name!);
          });
          break;
        }
      case ItemFilter.NEWEST:
        {
          showResults.sort((item1, item2) {
            return item1.product!.addDate!.compareTo(item2.product!.addDate!);
          });
          break;
        }
      case ItemFilter.PRICE_ASCENDING:
        {
          showResults.sort((item1, item2) {
            return item1.product!.price!.compareTo(item2.product!.price!);
          });
          break;
        }
      case ItemFilter.PRICE_DESCENDING:
        {
          showResults.sort((item1, item2) {
            return item1.product!.price!.compareTo(item2.product!.price!) * -1;
          });
          break;
        }
      default:
        {
          break;
        }
    }
    _view.onChangeFilter(showResults);
  }

  Future<void> handleItemPressed(ItemData itemData) async {
    _view.onWaitingProgressBar();
    await _itemSingleton.storeItemData(itemData);
    _view.onPopContext();
    _view.onSelectItem();
  }
}