import 'package:postgres/postgres.dart';
import 'models/message.dart';

import '../core/postgres_config.dart';
import '../functions/id_generator.dart';

class WebSockedService {
  static Future<Message> storageMessage(Message message) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final String id = idGenerator();
      await connection.execute(
        Sql.named(
          "insert into"
          " messages(id, status, _from, _to, content, timestamp)"
          " values (@id, @status, @_from, @_to, @content, @timestamp)"
        ),
        parameters: {
          "id": id,
          "status": "sent",
          "_from": message.from,
          "_to": message.to,
          "content": message.content,
          "timestamp": message.timestamp
        }
      );

      await connection.close();
      return message.copyWith(id: id, status: "sent");
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> updateStatusMessage(String id, String newStatus) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings,
    );

    try {
      await connection.execute(
        Sql.named("update messages set status = @status where id = @id"),
        parameters: {
          "id": id,
          "status": newStatus,
        },
      );

      await connection.close();
    } catch (e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> updateMessage(Message message) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings,
    );

    try {
      await connection.execute(
        Sql.named(
          "update messages set"
          " status = @status,"
          " content = @content"
          " where id = @id"
        ),
        parameters: {
          "id": message.id,
          "status": message.status,
          "content": message.content,
        },
      );

      await connection.close();
    } catch (e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> deleteMessage(String id) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings,
    );

    try {
      await connection.execute(
        Sql.named("delete from messages where id = @id"),
        parameters: {"id": id},
      );

      await connection.close();
    } catch (e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> updateUserActive(String uid, bool isActiveAccount) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named("update users set isActiveAccount = @isActiveAccount where uid = @uid"),
        parameters: {
          "uid": uid,
          "isActiveAccount": isActiveAccount
        }
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<List<Message>> getAllMessages(String from, String to) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named("select * from messages where (_from = @from and _to = @to) or (_from = @to and _to = @from) order by sort_order"),
        parameters: {"from": from, "to": to}
      );

      await connection.close();
      return List<Message>.generate(result.length, (index) => Message(
        id: result[index][0] as String,
        status: result[index][1] as String,
        from: result[index][2] as String,
        to: result[index][3] as String,
        content: result[index][4] as String,
        timestamp: result[index][5] as String
      )).reversed.toList();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }
}
