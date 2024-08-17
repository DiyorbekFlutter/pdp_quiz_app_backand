class ModuleDto {
  final String technologyId;
  final String title;
  final String stage;

  const ModuleDto({
    required this.technologyId,
    required this.title,
    required this.stage
  });

  factory ModuleDto.fromJson(Map<String, dynamic> json) => ModuleDto(
    technologyId: json["technologyId"] as String,
    title: json["title"] as String,
    stage: json["stage"] as String
  );

  Map<String, dynamic> get toJson => {
    "technologyId": technologyId,
    "title": title,
    "stage": stage
  };

  static bool isValid(Map<String, dynamic> json){
    try {
      ModuleDto.fromJson(json);
      return json.length == 3;
    } catch(e) {
      return false;
    }
  }
}