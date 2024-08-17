extension Trimmer on Map {
  Map<String, dynamic> get trimmer {
    return map((key, value) {
      return value is String
          ? MapEntry(key, value.trim())
          : MapEntry(key, value);
    });
  }
}
