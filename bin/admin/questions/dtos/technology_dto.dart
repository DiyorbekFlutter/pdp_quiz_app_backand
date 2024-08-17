import 'dart:typed_data';

class TechnologyDto {
  String title;
  Uint8List imageBytes;

  TechnologyDto({
    required this.title,
    required this.imageBytes
  });

  factory TechnologyDto.fromJson(Map<String, dynamic> json) => TechnologyDto(
    title: json["title"] as String,
    imageBytes: Uint8List.fromList((json["imageBytes"] as List).cast<int>()),
  );

  Map<String, dynamic> get toJson => {
    "title": title,
    "imageBytes": imageBytes,
  };

  static bool isValid(Map<String, dynamic> json){
    if(json.length != 2
        || !json.containsKey("title")
        || !json.containsKey("imageBytes")
        || json["title"] is! String
    ) return false;

    try {
      Uint8List.fromList((json["imageBytes"] as List).cast<int>());
      return true;
    } catch(e){
      return false;
    }
  }

  static bool isValidForUpdate(Map<String, dynamic> json){
    return json.isNotEmpty
        && json.containsKey("technologyId")
        && json["technologyId"] is String;
  }
}
