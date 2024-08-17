import 'package:postgres/postgres.dart';

import '../core/postgres_config.dart';
import '../functions/id_generator.dart';
import 'profile_change_info_dto.dart';
import 'profile_model.dart';

class ProfileService {
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

  static Future<ProfileModel> getUserInfoByUid(String uid) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named('select email, firstname, lastname, profileImageUrl from users where uid = @uid'),
        parameters: {"uid": uid}
      );

      await connection.close();

      return ProfileModel(
        email: result.first[0] as String,
        firstname: result.first[1] as String,
        lastname: result.first[2] as String?,
        profileImageUrl: result.first[3] as String?
      );
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> changeProfileInfo(String uid, ProfileChangeInfoDto profileChangeInfoDto) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named("update users set firstname = @firstname, lastname = @lastname where uid = @uid"),
        parameters: {
          "uid": uid,
          "firstname": profileChangeInfoDto.firstname,
          "lastname": profileChangeInfoDto.lastname
        }
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> changeProfileImage(String uid, String imageBytes) async {
    final Connection connection = await Connection.open(
        PostgresConfig.endpoint,
        settings: PostgresConfig.connectionSettings
    );

    try {
      final String? profileImageUrl = (await connection.execute(
        Sql.named("select profileImageUrl from users where uid = @uid"),
        parameters: {"uid": uid}
      )).first.first as String?;

      if(profileImageUrl != null){
        final Uri uri = Uri.parse(profileImageUrl);
        final List<String> segments = uri.pathSegments;
        final String id = segments.isNotEmpty ? segments.last : "";

        await connection.execute(
          Sql.named("update images set imageBytes = @imageBytes where id = @id"),
          parameters: {"id": id, "imageBytes": imageBytes}
        );
      } else {
        final String id = idGenerator();

        await connection.execute(
          Sql.named("insert into images (id, imageBytes) values (@id, @imageBytes)"),
          parameters: {"id": id, "imageBytes": imageBytes}
        );

        await connection.execute(
          Sql.named("update users set profileImageUrl = @profileImageUrl where uid = @uid"),
          parameters: {"uid": uid, "profileImageUrl": "http://localhost:8080/api/v1/images/$id"}
        );
      }

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> deleteProfileImage(String uid) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final String? profileImageUrl = (await connection.execute(
        Sql.named("select profileImageUrl from users where uid = @uid"),
        parameters: {"uid": uid}
      )).first.first as String?;

      if(profileImageUrl != null){
        final Uri uri = Uri.parse(profileImageUrl);
        final List<String> segments = uri.pathSegments;
        final String id = segments.isNotEmpty ? segments.last : "";

        await connection.execute(
          Sql.named("delete from images where id = @id"),
          parameters: {"id": id}
        );

        await connection.execute(
          Sql.named("update users set profileImageUrl = @profileImageUrl where uid = @uid"),
          parameters: {"uid": uid, "profileImageUrl": null}
        );
      }

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }
}
