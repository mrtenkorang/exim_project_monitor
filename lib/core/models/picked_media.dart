import 'dart:io';

class PickedMedia{
  final String? name;
  final String? path;
  final String? type;
  final int? size; // The file size in bytes
  final File? file;

  PickedMedia({this.name, this.path, this.type, this.size, this.file});

}

// class MediaType{
//   static String? video = "video";
//   static String? image = "image";
// }