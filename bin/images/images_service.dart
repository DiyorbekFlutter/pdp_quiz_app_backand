import 'dart:convert';
import 'dart:typed_data';

import 'package:postgres/postgres.dart';

import '../core/postgres_config.dart';

void main() async {
  var result = await ImagesService.getImageBytesById("32cc8abb-8564-47e3-8709-2c71b3a41f3c");
  print(result);
}

class ImagesService {
  static Future<Result> getAllImages() async {
    final Connection connection = await Connection.open(
        PostgresConfig.endpoint,
        settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named('select * from images'),
      );

      await connection.close();

      return result;
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<bool> checkImageExistsById(String id) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named('select count(*) from images where id = @id'),
        parameters: {"id": id}
      );

      await connection.close();
      return result[0][0] != 0;
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<Uint8List> getImageBytesById(String id) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named('select imageBytes from images where id = @id'),
        parameters: {"id": id}
      );

      await connection.close();
      return Uint8List.fromList(List<int>.from(jsonDecode(result.first.first as String)));
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }
}
