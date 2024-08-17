class TotalScoreModel {
  final String technologyId;
  final String title;
  final Scores scores;

  const TotalScoreModel({
    required this.technologyId,
    required this.title,
    required this.scores
  });

  factory TotalScoreModel.fromJson(Map<String, dynamic> json) => TotalScoreModel(
    technologyId: json["technologyId"] as String,
    title: json["title"] as String,
    scores: Scores.fromJson(json["scores"])
  );

  Map<String, dynamic> get toJson => {
    "technologyId": technologyId,
    "title": title,
    "scores": scores.toJson
  };
}

class Scores {
  int easy;
  int medium;
  int hard;

  Scores({
    required this.easy,
    required this.medium,
    required this.hard
  });

  factory Scores.fromJson(Map<String, dynamic> json) => Scores(
    easy: json["easy"] as int,
    medium: json["medium"] as int,
    hard: json["hard"] as int
  );

  Map<String, dynamic> get toJson => {
    "easy": easy,
    "medium": medium,
    "hard": hard
  };
}
