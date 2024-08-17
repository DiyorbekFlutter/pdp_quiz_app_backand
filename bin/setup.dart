import 'package:postgres/postgres.dart';

import 'core/postgres_config.dart';

enum Tables {
  users,
  images,
  technologies,
  modules,
  departments,
  questions
}

class SetUp {
  Future<void> init() async {
    final Connection connection = await Connection.open(
      PostgresConfig.endpoint,
      settings: PostgresConfig.connectionSettings
    );

    await _createTableIfNotExists(Tables.users, connection);
    await _createTableIfNotExists(Tables.images, connection);
    await _createTableIfNotExists(Tables.technologies, connection);
    await _createTableIfNotExists(Tables.modules, connection);
    await _createTableIfNotExists(Tables.departments, connection);
    await _createTableIfNotExists(Tables.questions, connection);

    connection.close();
  }

  Future<void> _createTableIfNotExists(Tables table, Connection connection) async {
    try {
      if(!await _tableExists(table, connection)){
        await connection.execute(Sql.named(_tableCreation(table)));
        print("${table.name} table is successfully created");
      }
    } catch(e) {
      return Future.error(PostgresConfig.errorText);
    }
  }

  Future<bool> _tableExists(Tables table, Connection connection) async {
    try {
      Result result = await connection.execute(Sql.named("select to_regclass('public.${table.name}')"));
      return result.first.toList().first != null;
    } catch(e) {
      return Future.error(PostgresConfig.errorText);
    }
  }

  String _tableCreation(Tables table) {
    switch(table){
      case Tables.users: return _users;
      case Tables.images: return _images;
      case Tables.technologies: return _technologies;
      case Tables.modules: return _modules;
      case Tables.departments: return _departments;
      case Tables.questions: return _questions;
    }
  }

  final String _users = """
    create table users(    
      uid varchar primary key,
      email varchar unique not null,
      password varchar not null,
      isActiveAccount boolean not null default true,
      firstname varchar not null,
      lastname varchar,
      profileImageUrl varchar,
      totalScores jsonb[] not null
    )
  """;

  final String _images = """
    create table users(    
      id varchar primary key,
      imageBytes text not null
    )
  """;

  final String _technologies = """
    create table users(    
      id varchar primary key,
      imageUrl varchar not null,
      title varchar not null
    )
  """;

  final String _modules = """
    create table users(    
      id varchar primary key,
      technologyId varchar references technologies(id) on delete cascade,
      title varchar not null,
      stage varchar not null
    )
  """;

  final String _departments = """
    create table users(    
      id varchar primary key,
      moduleId varchar references modules(id) on delete cascade,
      title varchar not null
    )
  """;

  final String _questions = """
    create table users(    
      id varchar primary key,
      departmentId varchar references departments(id) on delete cascade,
      question varchar not null,
      answer varchar not null,
      option1 varchar not null,
      option2 varchar not null,
      option3 varchar not null
    )
  """;
}
