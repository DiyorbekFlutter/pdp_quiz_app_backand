class QuestionUpdateDto {
  final String id;
  final String question;
  final String answer;
  final String option1;
  final String option2;
  final String option3;

  const QuestionUpdateDto({
    required this.id,
    required this.question,
    required this.answer,
    required this.option1,
    required this.option2,
    required this.option3
  });

  factory QuestionUpdateDto.fromJson(Map<String, dynamic> json) => QuestionUpdateDto(
    id: json["id"] as String,
    question: json["question"] as String,
    answer: json["answer"] as String,
    option1: json["option1"] as String,
    option2: json["option2"] as String,
    option3: json["option3"] as String
  );

  Map<String, dynamic> get toJson => {
    "id": id,
    "question": question,
    "answer": answer,
    "option1": option1,
    "option2": option2,
    "option3": option3
  };

  static bool isValid(Map<String, dynamic> json) {
    try {
      QuestionUpdateDto.fromJson(json);
      return json.length == 6;
    } catch(e) {
      return false;
    }
  }
}