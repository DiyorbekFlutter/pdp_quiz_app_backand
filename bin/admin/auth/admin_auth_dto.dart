class AdminLoginDto {
  final String email;
  final String password;

  const AdminLoginDto({
    required this.email,
    required this.password
  });

  factory AdminLoginDto.fromJson(Map<String, dynamic> json) => AdminLoginDto(
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
        && json["email"] is String
        && json["password"] is String;
  }
}
