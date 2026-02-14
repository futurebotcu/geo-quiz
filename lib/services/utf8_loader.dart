import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadUtf8Asset(String path) async {
  final bytes = (await rootBundle.load(path)).buffer.asUint8List();
  return utf8.decode(bytes);
}
