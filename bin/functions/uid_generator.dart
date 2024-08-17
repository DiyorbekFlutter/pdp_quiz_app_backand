import '../core/utils/extension.dart';

String uidGenerator(Map map){
  String input = "";

  map.forEach((key, value) {
    value is List
        ? input += value.join()
        : input += value.toString();
  });

  return input.toMd5;
}
