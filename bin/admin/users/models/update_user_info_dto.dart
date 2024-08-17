class UpdateUserInfoDto {
  final String uid;
  final String email;
  final String password;
  final String firstname;
  final String? lastname;
  final bool isActiveAccount;

  const UpdateUserInfoDto({
    required this.uid,
    required this.email,
    required this.password,
    required this.firstname,
    required this.lastname,
    required this.isActiveAccount
  });

  factory UpdateUserInfoDto.fromJson(Map<String, dynamic> json) => UpdateUserInfoDto(
    uid: json["uid"] as String,
    email: json["email"] as String,
    password: json["password"] as String,
    firstname: json["firstname"] as String,
    lastname: json["lastname"] as String,
    isActiveAccount: json["isActiveAccount"] as bool
  );

  Map<String, dynamic> get toJson => {
    "uid": uid,
    "email": email,
    "password": password,
    "firstname": firstname,
    "lastname": lastname,
    "isActiveAccount": isActiveAccount
  };

  static bool isValid(Map<String, dynamic> json) =>
      json.containsKey("uid") && json["uid"] is String
      && json.containsKey("email") && json["email"] is String
      && json.containsKey("password") && json["password"] is String
      && json.containsKey("firstname") && json["firstname"] is String
      && json.containsKey("lastname") && json["lastname"] is String?
      && json.containsKey("isActiveAccount") && json["isActiveAccount"] is bool;
}
