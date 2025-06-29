import 'package:pcplus/component/conversation_argument.dart';

import '../../../models/shops/shop_model.dart';

abstract class DetailProductContract {
  void onLoadDataSucceeded();
  void onAddToCart();
  void onBuyNow();
  void onBack();
  void onWaitingProgressBar();
  void onPopContext();
  void onViewShop(ShopModel seller);
  void onError(String message);
  void onResponseRatingFailed(String message);
  void onResponseRatingSuccess();
  void onChatWithShop(ConversationArgument argument);
}
