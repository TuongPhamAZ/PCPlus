import 'package:flutter/cupertino.dart';

abstract class WidgetBuilderInterface {
  void reset();
  Widget? createWidget();
}