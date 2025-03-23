class SearchSingleton {
  static SearchSingleton? _instance;
  static SearchSingleton getInstance() {
    _instance ??= SearchSingleton();
    return _instance!;
  }

  String storedSearchInput = "";
  bool needSearch = false;

  void reset() {
    storedSearchInput = "";
    needSearch = false;
  }
}