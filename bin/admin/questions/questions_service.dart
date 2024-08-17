import 'dart:convert';
import 'dart:typed_data';

import 'package:postgres/postgres.dart';

import '../../models/technology.dart';
import '../../core/postgres_config.dart';
import '../../admin/questions/dtos/technology_dto.dart';
import '../../functions/id_generator.dart';
import '../../admin/questions/dtos/question_dto.dart';
import '../../admin/questions/dtos/question_update_dto.dart';
import '../../admin/questions/dtos/module_dto.dart';
import '../../admin/questions/dtos/department_dto.dart';
import '../../admin/questions/dtos/department_update_dto.dart';

class QuestionsService {
  /// technology

  static Future<List<Map<String, dynamic>>> getAllTechnologies() async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(Sql.named('select * from technologies'));
      await connection.close();

      final List<Technology> technologies = List<Technology>.from(result.map((e) => Technology(
        id: e[0] as String,
        imageUrl: e[1] as String,
        title: e[2] as String
      )));

      return List<Map<String, dynamic>>.from(technologies.map((e) => e.toJson));
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> storageTechnology(TechnologyDto dto) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final String imageId = idGenerator();

      final Technology technology = Technology(
        id: idGenerator(),
        title: dto.title,
        imageUrl: "http://localhost:8080/api/v1/images/$imageId"
      );

      await connection.execute(
        Sql.named("insert into images (id, imageBytes) values (@id, @imageBytes)"),
        parameters: {"id": imageId, "imageBytes": jsonEncode(dto.imageBytes)}
      );

      await connection.execute(
        Sql.named("insert into technologies(id, title, imageUrl) values (@id, @title, @imageUrl)"),
        parameters: technology.toJson
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> updateTechnology(Map<String, dynamic> json) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      // if title exists
      if(json.containsKey("title") && json["title"] is String){
        await connection.execute(
          Sql.named("update technologies set title = @title where id = @id"),
          parameters: {"id": json["technologyId"] as String, "title": json["title"] as String}
        );
      }


      // if imageBytes exists
      if(json.containsKey("imageBytes") && json["imageBytes"] is List){
        // get imageUrl from technologies
        final String imageUrl = (await connection.execute(
          Sql.named("select imageUrl from technologies where id = @id"),
          parameters: {"id": json["technologyId"] as String}
        )).first.first as String;

        // get image id from technology imageUrl
        final Uri uri = Uri.parse(imageUrl);
        final List<String> segments = uri.pathSegments;
        final String imageId = segments.isNotEmpty ? segments.last : "";

        // update image
        await connection.execute(
          Sql.named("update images set imageBytes = @imageBytes where id = @id"),
          parameters: {"id": imageId, "imageBytes": jsonEncode(Uint8List.fromList((json["imageBytes"] as List).cast<int>()))}
        );
      }

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> deleteTechnology(String id) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      // get imageUrl from technologies
      final String imageUrl = (await connection.execute(
        Sql.named("select imageUrl from technologies where id = @id"),
        parameters: {"id": id}
      )).first.first as String;

      // get image id from technology imageUrl
      final Uri uri = Uri.parse(imageUrl);
      final List<String> segments = uri.pathSegments;
      final String imageId = segments.isNotEmpty ? segments.last : "";

      await connection.execute(
        Sql.named("delete from images where id = @id"),
        parameters: {"id": imageId}
      );

      await connection.execute(
        Sql.named("delete from technologies where id = @id"),
        parameters: {"id": id}
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }



  /// module

  static Future<void> storageModule(ModuleDto dto) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named("insert into modules (id, technologyId, title, stage) values (@id, @technologyId, @title, @stage)"),
        parameters: {
          "id": idGenerator(),
          "technologyId": dto.technologyId,
          "title": dto.title,
          "stage": dto.stage,
        }
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> deleteModule(String id) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named("delete from modules where id = @id"),
        parameters: {"id": id}
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }



  /// department

  static Future<void> storageDepartment(DepartmentDto dto) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named("insert into departments (id, moduleId, title) values (@id, @moduleId, @title)"),
        parameters: {
          "id": idGenerator(),
          "moduleId": dto.moduleId,
          "title": dto.title,
        }
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> updateDepartment(DepartmentUpdateDto dto) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named("update departments set title = @title where id = @id"),
        parameters: {"id": dto.id, "title": dto.title}
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> deleteDepartment(String id) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named("delete from departments where id = @id"),
        parameters: {"id": id}
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }



  /// question

  static Future<void> storageQuestion(QuestionDto dto) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named("""
          insert into questions(id, departmentId, question, answer, option1, option2, option3)
          values (@id, @departmentId, @question, @answer, @option1, @option2, @option3)
        """),
        parameters: {
          "id": idGenerator(),
          "departmentId": dto.departmentId,
          "question": dto.question,
          "answer": dto.answer,
          "option1": dto.option1,
          "option2": dto.option2,
          "option3": dto.option3,
        }
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> updateQuestion(QuestionUpdateDto dto) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named(
          "update questions set"
          " question = @question,"
          " answer = @answer,"
          " option1 = @option1,"
          " option2 = @option2,"
          " option3 = @option3"
          " where id = @id"
        ),
        parameters: {
          "id": dto.id,
          "question": dto.question,
          "answer": dto.answer,
          "option1": dto.option1,
          "option2": dto.option2,
          "option3": dto.option3,
        }
      );

      await connection.close();
    } catch(e) {
      print(e);
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> deleteQuestion(String id) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named("delete from questions where id = @id"),
        parameters: {"id": id}
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }
}
