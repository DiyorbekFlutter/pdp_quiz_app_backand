import '../../../models/total_score_model.dart';

class UserModel {
  final String uid;
  final String email;
  final String password;
  final bool isActiveAccount;
  final String firstname;
  final String? lastname;
  final String? profileImageUrl;
  final List<TotalScoreModel> totalScores;

  const UserModel({
    required this.uid,
    required this.email,
    required this.password,
    required this.isActiveAccount,
    required this.firstname,
    required this.lastname,
    required this.profileImageUrl,
    required this.totalScores
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json["uid"] as String,
    email: json["email"] as String,
    password: json["password"] as String,
    isActiveAccount: json["isActiveAccount"] as bool,
    firstname: json["firstname"] as String,
    lastname: json["lastname"] as String?,
    profileImageUrl: json["profileImageUrl"] as String?,
    totalScores: List<TotalScoreModel>.from(json["totalScores"].map((e) => TotalScoreModel.fromJson(e))),
  );

  Map<String, dynamic> get toJson => {
    "uid": uid,
    "email": email,
    "password": password,
    "isActiveAccount": isActiveAccount,
    "firstname": firstname,
    "lastname": lastname,
    "profileImageUrl": profileImageUrl,
    "totalScores": totalScores.map((e) => e.toJson).toList()
  };
}
