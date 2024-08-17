import '../../models/technology.dart';

class Technologies {
  String userName;
  String? userProfileImageUrl;
  List<Technology> technologies;

  Technologies({
    required this.userName,
    this.userProfileImageUrl,
    required this.technologies
  });

  factory Technologies.fromJson(Map<String, dynamic> json) => Technologies(
    userName: json["userName"] as String,
    userProfileImageUrl: json["userProfileImageUrl"] as String?,
    technologies: List<Technology>.from(json["technologies"].map((e) => Technology.fromJson(e)))
  );

  Map<String, dynamic> get toJson => {
    "userName": userName,
    "userProfileImageUrl": userProfileImageUrl,
    "technologies": technologies.map((e) => e.toJson).toList(),
  };
}
