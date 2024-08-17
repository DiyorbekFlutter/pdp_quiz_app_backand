class LevelUserInfoModel {
  final String username;
  final String? imageUrl;
  final int totalScore;
  final bool isCurrentUser;
  late int position;

  LevelUserInfoModel({
    required this.username,
    required this.imageUrl,
    required this.totalScore,
    required this.isCurrentUser
  });

  factory LevelUserInfoModel.fromJson(Map<String, dynamic> json) => LevelUserInfoModel(
    username: json["username"] as String,
    imageUrl: json["imageUrl"] as String?,
    totalScore: json["totalScore"] as int,
    isCurrentUser: json["isCurrentUser"] as bool
  );

  Map<String, dynamic> get toJson => {
    "username": username,
    "imageUrl": imageUrl,
    "totalScore": totalScore,
    "position": position,
    "isCurrentUser": isCurrentUser
  };
}