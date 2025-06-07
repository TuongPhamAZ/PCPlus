class Delegate<T> {
  final List<void Function(T)> _handlers = [];

  void add(void Function(T) handler) {
    _handlers.add(handler);
  }

  void remove(void Function(T) handler) {
    _handlers.remove(handler);
  }

  void invoke(T value) {
    for (final handler in _handlers) {
      handler(value);
    }
  }
}