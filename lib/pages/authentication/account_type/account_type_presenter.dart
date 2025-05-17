import 'account_type_contract.dart';

class AccountTypePresenter {
  final AccountTypeContract? _view;
  AccountTypePresenter(this._view);

  void onSelectAccountType(String userType) {
    _view?.onSelectUserType(userType);
  }
}
