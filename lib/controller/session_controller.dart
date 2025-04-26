
import 'package:pcplus/models/interactions/interaction_model.dart';
import 'package:pcplus/models/interactions/interaction_repo.dart';

import '../models/users/user_model.dart';

class SessionController {
  static SessionController? _instance;
  static SessionController getInstance() {
    _instance ??= SessionController();
    return _instance!;
  }

  String? userID;
  bool isSeller = false;

  bool firstEnter = false;

  Future<void> loadUser(UserModel user) async {
    userID = user.userID;
    firstEnter = true;

    isSeller = user.isSeller!;
  }

  Future<void> signOut() async {

  }

  bool isShop() {
    return isSeller;
  }

  Future<InteractionModel> getInteractionModel(String itemID) async {
    InteractionRepository interactionRepo = InteractionRepository();

    InteractionModel? model = await interactionRepo.getInteractionByUserIDAndItemID(userID!, itemID);

    if (model == null) {
      model = InteractionModel(
          userID: userID,
          itemID: itemID,
          clickTimes: 0,
          buyTimes: 0,
          rating: 0,
          isFavor: false
      );
      String? newId = await interactionRepo.addInteractionToFirestore(model);
      model.key = newId;
    }

    return model;
  }
}