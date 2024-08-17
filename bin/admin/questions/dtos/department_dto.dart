class DepartmentDto {
  final String moduleId;
  final String title;

  const DepartmentDto({
    required this.moduleId,
    required this.title
  });

  factory DepartmentDto.fromJson(Map<String, dynamic> json) => DepartmentDto(
    moduleId: json["moduleId"] as String,
    title: json["title"] as String
  );

  Map<String, dynamic> get toJson => {
    "moduleId": moduleId,
    "title": title
  };

  static bool isValid(Map<String, dynamic> json){
    try {
      DepartmentDto.fromJson(json);
      return json.length == 2;
    } catch(e) {
      return false;
    }
  }
}