import 'package:pcplus/builders/model_builders/model_builder_interface.dart';
import 'package:pcplus/models/users/user_model.dart';

class UserBuilder implements ModelBuilderInterface<UserModel> {
  late UserModel _model;

  UserBuilder() {
    reset();
  }

  void setUserID(String id) {
    _model.userID = id;
  }

  void setName(String name) {
    _model.name = name;
  }

  void setEmail(String email) {
    _model.email = email;
  }

  void setPhone(String phone) {
    _model.phone = phone;
  }

  void setDateOfBirth(DateTime date) {
    _model.dateOfBirth = date;
  }

  void setGender(bool isMale) {
    _model.gender = isMale ? "male" : "female";
  }

  void setSeller(bool value) {
    _model.isSeller = value;
  }

  void setAvatarUrl(String url) {
    _model.avatarUrl = url;
  }

  void setMoney(int money) {
    _model.money = money;
  }

  void setLocation(String location) {
    if (_model.isSeller == false) {
      return;
    }
    _model.setLocation(location);
  }

  void setShopName(String shopName) {
    if (_model.isSeller == false) {
      return;
    }
    _model.setShopName(shopName);
  }

  @override
  UserModel createModel() {
    return _model;
  }

  @override
  void reset() {
    _model = UserModel(
        userID: "",
        name: "",
        email: "",
        phone: "",
        dateOfBirth: DateTime.now(),
        gender: "male",
        isSeller: false
    );
  }
}