class ProfileModel {
  final String email;
  final String firstname;
  final String? lastname;
  final String? profileImageUrl;

  const ProfileModel({
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.profileImageUrl
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    email: json["email"] as String,
    firstname: json["firstname"] as String,
    lastname: json["lastname"] as String?,
    profileImageUrl: json["profileImageUrl"] as String?
  );

  Map<String, dynamic> get toJson => {
    "email": email,
    "firstname": firstname,
    "lastname": lastname,
    "profileImageUrl": profileImageUrl
  };
}
