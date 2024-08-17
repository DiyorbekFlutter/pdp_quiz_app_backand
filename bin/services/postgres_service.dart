import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:postgres/legacy.dart';
import 'package:postgres/postgres.dart';

import '../auth/auth_dtos/user_dto_register.dart';
import '../core/postgres_config.dart';
import '../functions/id_generator.dart';
import '../models/technology.dart';

void main() async {
  // final List<String> id = [
  //   "998a43da-d8d6-4925-9ec2-7951f782b2f1", // flutter
  //   "fb267320-f277-467a-a8a8-4859e4f5ab85", // python
  //   "fbabac66-8d47-4837-92cb-c0dc731d773e", // frontend
  //   "25349b98-04b3-4ae8-bb5a-b66a2eff5d46", // java
  //   "7e282066-1e97-4bb5-9ae7-95770afaedc4", // c++
  //   "1118a4c2-8a75-4829-8108-e63d911a6578", // c$
  //   "74c183d9-3929-4c1a-96ca-a066a473991f", // ios
  //   "3d46738a-630d-4427-a892-9f35f8105fc9", // android
  // ];
  //
  // const List<String> name = ["Flutter", "Python", "Frontend", "Java", "C++", "C#", "Android", "IOS"];

  // for(List e in await PostgresService.getAllImages()){
  //   id.add(e.first);
  // }
  //
  // print(id);

  // for(int i=0; i<id.length; i++){
  //   await PostgresService.storageTechnology(
  //     Technology(
  //       id: idGenerator(),
  //       imageUrl: "http://localhost:8080/api/v1/images/${id[i]}",
  //       title: name[i]
  //     )
  //   );
  //   print(name[i]);
  // }

  // List<Technology> result = await PostgresService.getAllTechnologies();
  // print(result[0].title);


  // for(String path in await getAllPaths("assets")){
  //   String result = await PostgresService.storageImage(path);
  //   print(result);
  // }

  /// storage module
  // print(await PostgresService.storageModule(
  //   technologyId: "e87e755e-7c48-4f90-8280-6d6aef677ca3",
  //   title: "4-module",
  //   stage: "hard"
  // ));

  /// storage department
  // print(await PostgresService.storageDepartment(
  //   moduleId: "680ce92e-3410-4b53-b771-42d8c1bff967",
  //   title: "2-department"
  // ));

  /// storage question
  // print(await PostgresService.storageQuestion(
  //   departmentId: "f5af170a-c22e-437f-bb99-5bb13232dd19",
  //   question: "question 4",
  //   answer: "answer",
  //   option1: "option1",
  //   option2: "option2",
  //   option3: "option3"
  // ));

  // var result = await PostgresService.getInfo("e87e755e-7c48-4f90-8280-6d6aef677ca3", "easy");
  // print(result);
}

Future<List<String>> getAllPaths(String path) async {
  final List<String> pathsList = [];
  final Directory directory = Directory(path);

  await for (FileSystemEntity entity in directory.list(recursive: true)) {
    if (entity is File) {
      pathsList.add(entity.path);
    }
  }

  return pathsList;
}





class PostgresService {
  static Future<Technology> storageTechnology(Technology technology) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
        Sql.named("""
          insert into technologies
          (id, imageUrl, title)
          values (@id, @imageUrl, @title)
        """),
        parameters: technology.toJson
      );

      await connection.close();
      return technology;
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

  static Future<String> storageModule({required String technologyId, required String title, required String stage}) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      String id = idGenerator();
      await connection.execute(
        Sql.named("insert into modules (id, technologyId, title, stage) values (@id, @technologyId, @title, @stage)"),
        parameters: {
          "id": id,
          "technologyId": technologyId,
          "title": title,
          "stage": stage,
        }
      );

      await connection.close();
      return id;
    } on PostgreSQLException catch(e) {
      if(e.code.toString() == '23505' && e.toString().contains("already exists")){
        await connection.close();
        return Future.error("Already exists");
      } else {
        await connection.close();
        return Future.error("${PostgresConfig.errorText}: $e");
      }
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<String> storageDepartment({required String moduleId, required String title}) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      String id = idGenerator();
      await connection.execute(
        Sql.named("insert into departments (id, moduleId, title) values (@id, @moduleId, @title)"),
        parameters: {
          "id": id,
          "moduleId": moduleId,
          "title": title,
        }
      );

      await connection.close();
      return id;
    } on PostgreSQLException catch(e) {
      if(e.code.toString() == '23505' && e.toString().contains("already exists")){
        await connection.close();
        return Future.error("Already exists");
      } else {
        await connection.close();
        return Future.error("${PostgresConfig.errorText}: $e");
      }
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<String> storageQuestion({
    required String departmentId,
    required String question,
    required String answer,
    required String option1,
    required String option2,
    required String option3
  }) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      String id = idGenerator();
      await connection.execute(
        Sql.named(
          """
            insert into questions(id, departmentId, question, answer, option1, option2, option3)
            values (@id, @departmentId, @question, @answer, @option1, @option2, @option3)
          """
        ),
        parameters: {
          "id": id,
          "departmentId": departmentId,
          "question": question,
          "answer": answer,
          "option1": option1,
          "option2": option2,
          "option3": option3,
        }
      );

      await connection.close();
      return id;
    } on PostgreSQLException catch(e) {
      if(e.code.toString() == '23505' && e.toString().contains("already exists")){
        await connection.close();
        return Future.error("Already exists");
      } else {
        await connection.close();
        return Future.error("${PostgresConfig.errorText}: $e");
      }
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future getInfo(String technologyId, String stage) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    try {
      final Result result = await connection.execute(
        Sql.named(
          """
            select
                t.id as technology_id,
                t.imageUrl as technology_imageUrl,
                t.title as technology_title,
                m.id as module_id,
                m.title as module_title,
                m.stage as module_stage,
                d.id as department_id,
                d.title as department_title,
                q.id as question_id,
                q.question as questions_text,
                q.answer as question_answer,
                q.option1 as question_option1,
                q.option2 as question_option2,
                q.option3 as question_option3
            from technologies t
                join modules m on t.id = m.technologyId
                join departments d on m.id = d.moduleId
                join questions q on d.id = q.departmentId
            where t.id = @technologyId and m.stage = @stage;
          """
        ),
        parameters: {
          "technologyId": technologyId,
          "stage": stage
        }
      );

      await connection.close();

      return result;
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<String> storageImage(String path) async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    // id generate
    final String id = idGenerator();

    // image to bytes
    final File file = File(path);
    final Uint8List imageBytes = file.readAsBytesSync();

    await connection.execute(
      Sql.named("insert into images (id, imageBytes) values (@id, @imageBytes)"),
      parameters: {
        "id": id,
        "imageBytes": jsonEncode(imageBytes)
      }
    );

    await connection.close();
    return id;
  }

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









  static Future<UserDtoRegister> update(UserDtoRegister user) async {
    final Connection connection = await Connection.open(
        PostgresConfig.endpoint,
        settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
          Sql.named(
              """
            update users
            set
              email = @email,
              password = @password,
              fullname = @fullname,
              profileImageUrl = @profileImageUrl,
              totalScores = @totalScores
            where uid = @uid
          """
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
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }

  static Future<void> delete(String uid) async {
    final Connection connection = await Connection.open(
        PostgresConfig.endpoint,
        settings: PostgresConfig.connectionSettings
    );

    try {
      await connection.execute(
          Sql.named("delete from users where uid = @uid"),
          parameters: {"uid": uid}
      );

      await connection.close();
    } catch(e) {
      await connection.close();
      return Future.error("${PostgresConfig.errorText}: $e");
    }
  }
}


