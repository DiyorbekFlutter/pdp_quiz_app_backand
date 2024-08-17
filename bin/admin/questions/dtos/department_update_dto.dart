class DepartmentUpdateDto {
  final String id;
  final String title;

  const DepartmentUpdateDto({
    required this.id,
    required this.title
  });

  factory DepartmentUpdateDto.fromJson(Map<String, dynamic> json) => DepartmentUpdateDto(
      id: json["id"] as String,
      title: json["title"] as String
  );

  Map<String, dynamic> get toJson => {
    "id": id,
    "title": title
  };

  static bool isValid(Map<String, dynamic> json){
    try {
      DepartmentUpdateDto.fromJson(json);
      return json.length == 2;
    } catch(e) {
      return false;
    }
  }
}