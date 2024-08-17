class UserDtoLogin {
  String email;
  String password;

  UserDtoLogin({
    required this.email,
    required this.password
  });

  factory UserDtoLogin.fromJson(Map<String, dynamic> json) => UserDtoLogin(
    email: json["email"] as String,
    password: json["password"] as String
  );

  Map<String, dynamic> get toJson => {
    "email": email,
    "password": password
  };

  static bool isValid(Map<String, dynamic> json) {
    return json.length == 2
        && json.containsKey("email")
        && json.containsKey("password")
        && json["email"].runtimeType == String
        && json["password"].runtimeType == String;
  }
}
