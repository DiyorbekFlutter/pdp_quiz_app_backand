class ProfileChangeInfoDto {
  final String firstname;
  final String? lastname;

  const ProfileChangeInfoDto({
    required this.firstname,
    required this.lastname
  });

  factory ProfileChangeInfoDto.from(Map<String, dynamic> json) => ProfileChangeInfoDto(
    firstname: json["firstname"] as String,
    lastname: json["lastname"] as String?
  );

  Map<String, dynamic> get toJson => {
    "firstname": firstname,
    "lastname": lastname
  };

  static bool isValid(Map<String, dynamic> json){
    return json.length == 2
        && json.containsKey("firstname")
        && json.containsKey("lastname")
        && json["firstname"].runtimeType == String
        && (json["lastname"].runtimeType == String || json["lastname"] == null);
  }
}
