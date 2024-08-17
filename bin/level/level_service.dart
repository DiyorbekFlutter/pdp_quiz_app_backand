import 'package:postgres/postgres.dart';

import '../core/postgres_config.dart';
import '../models/total_score_model.dart';
import 'level_user_info_model.dart';

class LevelService {
  static Future<bool> checkUserExistsByUid(String uid) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named('select count(*) from users where uid = @uid'),
        parameters: {"uid": uid}
      );

      await connection.close();
      return result[0][0] != 0;
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<bool> checkTechnologyExists(String id) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named("select count(*) from technologies where id = @id"),
        parameters: {"id": id}
      );

      await connection.close();
      return result.first.first != 0;
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<List<LevelUserInfoModel>> leaderboard(String uid, String stage, String technologyId) async {
    final List<LevelUserInfoModel> users = [];
    LevelUserInfoModel? currentUserLevelInfo;

    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(Sql.named("select uid, firstname, lastname, profileImageUrl, totalScores from users"));
      await connection.close();

      for(List row in result){
        final List<TotalScoreModel> totalScores = List<TotalScoreModel>.from(row[4].map((e) => TotalScoreModel.fromJson(e)));

        for(TotalScoreModel totalScoreModel in totalScores){
          int totalScore = stage == "easy"
              ? totalScoreModel.scores.easy
              : stage == "medium"
              ? totalScoreModel.scores.medium
              : totalScoreModel.scores.hard;

          if(technologyId == totalScoreModel.technologyId && totalScore != 0){
            final bool isCurrentUser = (row[0] as String) == uid;
            final LevelUserInfoModel levelUserInfoModel = LevelUserInfoModel(
              username: isCurrentUser ? "You" : "${row[1]}${row[2] == null ? "" : " ${row[2]}"}",
              imageUrl: row[3] as String?,
              totalScore: totalScore,
              isCurrentUser: isCurrentUser
            );

            users.add(levelUserInfoModel);
            if(isCurrentUser) currentUserLevelInfo = levelUserInfoModel;
            break;
          }
        }
      }

      users.sort((a, b) => b.totalScore.compareTo(a.totalScore));

      for(int i=0; i<users.length; i++){
        users[i].position = i+1;
      }

      if(currentUserLevelInfo != null){
        users.insert(0, currentUserLevelInfo);
      }

      for(int i=1; i<users.length; i++){
        if(users[i].isCurrentUser){
          users[0].position = users[i].position;
        }
      }

      return users;
    } catch(e) {
      print(e);
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }
}
