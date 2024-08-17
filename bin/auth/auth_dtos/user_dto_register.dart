import '../../core/utils/extension.dart';
import '../../models/total_score_model.dart';

class UserDtoRegister {
  late String uid;
  String email;
  String password;
  String firstname;
  String? lastname;
  String? profileImageUrl;
  List<TotalScoreModel> totalScores;

  UserDtoRegister({
    required this.email,
    required this.password,
    required this.firstname,
    this.lastname,
    this.profileImageUrl,
    required this.totalScores
  });

  factory UserDtoRegister.fromJson(Map<String, dynamic> json) => UserDtoRegister(
    email: json["email"] as String,
    // password md5 ko'rinishiga o'tkaziladi
    password: (json["password"] as String).toMd5,
    firstname: json["firstname"] as String,
    lastname: json["lastname"] as String?,
    profileImageUrl: json["profileImageUrl"] as String?,
    totalScores: List<TotalScoreModel>.from((json["totalScores"] ?? []).map((e) => TotalScoreModel.fromJson(e)))
  );

  Map<String, dynamic> get toJson => {
    "uid": uid,
    "email": email,
    "password": password,
    "firstname": firstname,
    "lastname": lastname,
    "profileImageUrl": profileImageUrl,
    "totalScores": totalScores.map((e) => e.toJson).toList()
  };

  static bool isValid(Map<String, dynamic> json) {
    if(json.length == 3) {
      return json.containsKey("email")
          && json.containsKey("password")
          && json.containsKey("firstname")
          && json["email"].runtimeType == String
          && json["password"].runtimeType == String
          && json["firstname"].runtimeType == String;
    } else if(json.length == 4) {
      return json.containsKey("email")
          && json.containsKey("password")
          && json.containsKey("firstname")
          && json.containsKey("lastname")
          && json["email"].runtimeType == String
          && json["password"].runtimeType == String
          && json["firstname"].runtimeType == String
          && json["lastname"].runtimeType == String;
    } else {
      return false;
    }
  }
}
