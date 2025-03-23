import 'package:pcplus/objects/data_object_interface.dart';

abstract class ObjectBuilderInterface {
  void reset();
  DataObjectInterface build();
}

abstract class ListObjectBuilderInterface {
  void reset();
  List<DataObjectInterface> createList();
}