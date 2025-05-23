import 'package:flutter/cupertino.dart';

class NavService {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static NavigatorState? get nav => key.currentState;
  static BuildContext? get context => key.currentContext;
}