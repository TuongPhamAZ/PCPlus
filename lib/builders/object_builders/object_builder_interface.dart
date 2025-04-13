import 'package:pcplus/objects/data_object_interface.dart';

abstract class ObjectBuilderInterface {
  void reset();
  IDataObject build();
}

abstract class ListObjectBuilderInterface {
  void reset();
  List<IDataObject> createList();
}