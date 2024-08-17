import 'package:uuid/uuid.dart';

String idGenerator() {
  return Uuid().v4();
}
