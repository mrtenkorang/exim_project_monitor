import 'dart:io';
import 'dart:convert';

class PickedMedia {
  final String? name;
  final String? path;
  final String? type;
  final String? base64String;
  // final int? size;
  final File? file;

  PickedMedia({
    this.name,
    this.path,
    this.type,
    this.file,
    this.base64String,
  });

  // Convert image file to base64 string
  static Future<String> fileToBase64(File file) async {
    List<int> imageBytes = await file.readAsBytes();
    return base64Encode(imageBytes);
  }
}

// class MediaType{
//   static String? video = "video";
//   static String? image = "image";
// }