import 'package:postgres/legacy.dart';
import 'package:postgres/postgres.dart';

import '../core/postgres_config.dart';
import '../models/total_score_model.dart';
import 'auth_dtos/user_dto_register.dart';

class AuthService {
  static Future<UserDtoRegister> storage(UserDtoRegister user) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named(
          "insert into users"
          "(uid, email, password, firstname, lastname, profileImageUrl, totalScores)"
          "values (@uid, @email, @password, @firstname, @lastname, @profileImageUrl, @totalScores)"
        ),
        parameters: {
          "uid": user.uid,
          "email": user.email,
          "password": user.password,
          "firstname": user.firstname,
          "lastname": user.lastname,
          "profileImageUrl": user.profileImageUrl,
          "totalScores": user.totalScores
        }
      );

      await connection.close();
      return user;
    } on PostgreSQLException catch(e) {
      if(e.code.toString() == '23505' && e.toString().contains("already exists")){
        await connection.close();
        return Future.error("Such a user exists");
      } else {
        await connection.close();
        return Future.error("${PostgresConfig.errorText}: $e");
      }
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<bool> userExists(String email) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named('select count(*) from users where email = @email'),
        parameters: {"email": email}
      );

      await connection.close();
      return result[0][0] != 0;
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<UserDtoRegister> getUserInfoByEmail(String email) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named('select * from users where email = @email'),
        parameters: {"email": email}
      );

      await connection.close();
      List dataList = result[0];

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
}
