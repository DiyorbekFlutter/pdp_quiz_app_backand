class ScoresSystemModel {
  final String technologyId;
  final String stage;
  final int ball;

  const ScoresSystemModel({
    required this.technologyId,
    required this.stage,
    required this.ball
  });

  factory ScoresSystemModel.fromJson(Map<String, dynamic> json) => ScoresSystemModel(
    technologyId: json["technologyId"] as String,
    stage: json["stage"] as String,
    ball: json["ball"] as int
  );

  Map<String, dynamic> get toJson => {
    "technologyId": technologyId,
    "stage": stage,
    "ball": ball
  };

  static bool isValid(Map<String, dynamic> json) {
    return json.length == 3
      && json.containsKey("technologyId")
      && json.containsKey("stage")
      && json.containsKey("ball")
      && json["technologyId"].runtimeType == String
      && json["stage"].runtimeType == String
      && json["ball"].runtimeType == int
      && (json["stage"] as String).isNotEmpty
      && (json["technologyId"] as String).isNotEmpty;
  }
}
