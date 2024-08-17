import 'package:postgres/postgres.dart';

import '../../core/postgres_config.dart';
import '../../admin/users/models/user_model.dart';
import '../../models/total_score_model.dart';
import '../../admin/users/models/update_user_info_dto.dart';

class UsersService {
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(Sql.named("select * from users"));
      await connection.close();

      return List<Map<String, dynamic>>.from(result.map((List row) => UserModel(
        uid: row[0] as String,
        email: row[1] as String,
        password: row[2] as String,
        isActiveAccount: row[3] as bool,
        firstname: row[4] as String,
        lastname: row[5] as String?,
        profileImageUrl: row[6] as String?,
        totalScores: List<TotalScoreModel>.from(row[7].map((e) => TotalScoreModel.fromJson(e))),
      ).toJson));
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<Map<String, dynamic>> getUserInfo(String uid) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named(
          "select email,"
          " password,"
          " firstname,"
          " lastname,"
          " isActiveAccount"
          " from users where uid = @uid"
        ),
        parameters: {"uid": uid}
      );

      await connection.close();
      final List row = result.first;

      return UpdateUserInfoDto(
        uid: uid,
        email: row[0],
        password: row[1],
        firstname: row[2],
        lastname: row[3],
        isActiveAccount: row[4],
      ).toJson;
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> updateUserInfo(UpdateUserInfoDto dto) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named(
          "update users set"
          " email = @email,"
          " password = @password,"
          " firstname = @firstname,"
          " lastname = @lastname,"
          " isActiveAccount = @isActiveAccount"
          " where uid = @uid"
        ),
        parameters: {
          "uid": dto.uid,
          "email": dto.email,
          "password": dto.password,
          "firstname": dto.firstname,
          "lastname": dto.lastname,
          "isActiveAccount": dto.isActiveAccount
        }
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }
}
