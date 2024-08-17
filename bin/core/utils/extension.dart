import 'dart:convert';

import 'package:crypto/crypto.dart';

extension ExtensionString on String {
  String get toMd5 => md5.convert(utf8.encode(this)).toString();
  String get errorStatus => jsonEncode({"error": this});
}
