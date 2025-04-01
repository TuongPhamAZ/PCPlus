import 'package:pcplus/objects/suggest_item_data.dart';

abstract class SearchScreenContract {
  void onStartSearching();
  void onFinishSearching();
  void onChangeFilter(List<ItemData> result);
  void onBack();
  void onSelectItem();
  void onPopContext();
  void onWaitingProgressBar();
}