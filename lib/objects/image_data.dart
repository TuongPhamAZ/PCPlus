import 'dart:io';
import 'package:pcplus/objects/data_object_interface.dart';

class ImageData extends IDataObject {
  String path;
  File? file;
  bool isNew;
  
  ImageData({
    required this.path,
    required this.isNew,
    this.file,
  });
}