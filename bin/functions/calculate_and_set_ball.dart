import 'dart:convert';

import '../models/total_score_model.dart';

List<String> calculateAndSetBall({required TotalScoreModel totalScore, required List<TotalScoreModel> totalScores}){
  int? index;

  int? contains(){
    for(int i=0; i<totalScores.length; i++){
      if(totalScores[i].technologyId == totalScore.technologyId){
        return i;
      }
    }
    return null;
  }

  index = contains();

  if(index != null){
    for(int i=0; i<totalScores.length; i++){
      if(i == index){
        totalScores[i].scores.easy += totalScore.scores.easy;
        totalScores[i].scores.medium += totalScore.scores.medium;
        totalScores[i].scores.hard += totalScore.scores.hard;
      }
    }
  } else {
    totalScores.add(totalScore);
  }

  return totalScores.map((e) => jsonEncode(e.toJson)).toList();
}