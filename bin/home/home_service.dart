import 'package:postgres/postgres.dart';

import '../auth/auth_dtos/user_dto_register.dart';
import '../core/postgres_config.dart';
import '../functions/calculate_and_set_ball.dart';
import '../models/total_score_model.dart';
import '../models/modules.dart';
import 'models/scores_system_model.dart';
import '../models/technology.dart';

class HomeService {
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

  static Future<UserDtoRegister> getUserInfoByUid(String uid) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named('select * from users where uid = @uid'),
        parameters: {"uid": uid}
      );

      await connection.close();
      List dataList = result.first;

      UserDtoRegister user = UserDtoRegister(
        email: dataList[1] as String,
        password: dataList[2] as String,
        firstname: dataList[4] as String,
        lastname: dataList[5] as String?,
        profileImageUrl: dataList[6] as String?,
        totalScores: List<TotalScoreModel>.from(dataList[7].map((e) => TotalScoreModel.fromJson(e)))
      );

      user.uid = dataList[0] as String;

      return user;
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<List<Technology>> getAllTechnologies() async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named('select * from technologies'),
      );

      await connection.close();

      return List<Technology>.from(result.map((e) => Technology(
        id: e[0] as String,
        imageUrl: e[1] as String,
        title: e[2] as String
      )));
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<(String, String)> getTechnologyInfoById(String id) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named('select imageUrl, title from technologies where id = @id'),
        parameters: {"id": id}
      );

      await connection.close();
      return (result.first[1] as String, result.first.first as String);
    } catch(e) {
      await connection.close();
      return Future.error(e.toString());
    }
  }

  static Future<Modules> getModules(String technologyId, String stage) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named("select * from modules where technologyId = @technologyId and stage = @stage"),
        parameters: {
          "technologyId": technologyId,
          "stage": stage,
        }
      );

      await connection.close();
      return Modules([
        for(List moduleRow in result)...{
          Module(
            id: moduleRow[0],
            technologyId: moduleRow[1],
            title: moduleRow[2],
            stage: moduleRow[3],
            departments: await HomeService.getDepartments(moduleRow.first)
          )
        }
      ]);
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<List<Department>> getDepartments(String moduleId) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named("select * from departments where moduleId = @moduleId"),
        parameters: {"moduleId": moduleId}
      );

      await connection.close();
      return [
        for(List departmentsRow in result)...{
          Department(
            id: departmentsRow[0],
            moduleId: departmentsRow[1],
            title: departmentsRow[2],
            questions: await HomeService.getQuestions(departmentsRow.first)
          )
        }
      ];
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<List<Question>> getQuestions(String departmentId) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named("select * from questions where departmentId = @departmentId"),
        parameters: {"departmentId": departmentId}
      );

      await connection.close();
      return List<Question>.generate(result.length, (index) {
        return Question(
          id: result[index][0] as String,
          departmentId: result[index][1] as String,
          question: result[index][2] as String,
          answer: result[index][3] as String,
          option1: result[index][4] as String,
          option2: result[index][5] as String,
          option3: result[index][6] as String
        );
      });
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> addBall(String uid, ScoresSystemModel scoresSystemModel) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named("select totalScores from users where uid = @uid"),
        parameters: {"uid": uid}
      );

      final Result technologyTitle = await connection.execute(
        Sql.named("select title from technologies where id = @id"),
        parameters: {"id": scoresSystemModel.technologyId}
      );

      await connection.execute(
        Sql.named("update users set totalScores = @totalScores where uid = @uid"),
        parameters: {
          "uid": uid,
          "totalScores": calculateAndSetBall(
            totalScore: TotalScoreModel(
              technologyId: scoresSystemModel.technologyId,
              title: technologyTitle.first.first.toString(),
              scores: Scores(
                easy: scoresSystemModel.stage == "easy" ? scoresSystemModel.ball : 0,
                medium: scoresSystemModel.stage == "medium" ? scoresSystemModel.ball : 0,
                hard: scoresSystemModel.stage == "hard" ? scoresSystemModel.ball : 0
              )
            ),
            totalScores: List<TotalScoreModel>.from((result.first.first as List).map((e) => TotalScoreModel.fromJson(e)))
          ),
        }
      );

      await connection.close();
    } catch(e){
      print("Error manashu: $e");
      throw Exception(e);
    }
  }
}
