import 'package:get/get_utils/src/extensions/string_extensions.dart';

extension StringExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}'.split('_').join(" ");
  String get allInCaps => toUpperCase().split('_').join(" ");
  // String get capitalizeFirstOfEach => this.split(" ").map((str) => str.capitalize).join(" ").split('_').join(" ");
  String get capitalizeFirstOfEach => split('_').join(" ").split(" ").map((str) => str.capitalize).join(" ");
}