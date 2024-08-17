import 'package:postgres/postgres.dart';

void main() async {
  // final Connection connection = await connectionOpen();
  //
  // print(connection.isOpen);
  // connection.close();
  // print(connection.isOpen);

  // final user = User(name: 'Botir', age: 25, phoneNumber: '+998993573231');
  // await user.insert();

  User(id: "id", email: "diyorbek@gmail.com", username: "Diyorbek", age: 20).delete(conditionsAnd: ["id"]);
}


class User extends DB {
  final String id;
  final String email;
  final String username;
  final int age;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.age
  });

  @override
  Map<String, dynamic> get toJson => {
    "id": id,
    "email": email,
    "username": username,
    "age": age
  };
}


abstract class DB {
  Map<String, dynamic> get toJson;

  Future<Connection> connectionOpen() async => await Connection.open(
    Endpoint(
      host: "localhost",
      database: "postgres",
      username: "postgres",
      password: "root"
    ),
    settings: ConnectionSettings(
      sslMode: SslMode.disable
    )
  );


  Future<void> insert() async {
    final Connection connection = await connectionOpen();
    final String tableName = "${runtimeType.toString()[0].toLowerCase() + runtimeType.toString().substring(1)}s";
    final String columnNames = toJson.keys.join(", ");
    final String values = toJson.keys.map((e) => "@$e").join(", ");
    final String query  = "insert into $tableName ($columnNames) values ($values)";

    try {
      await connection.execute(Sql.named(query), parameters: toJson);
    } catch(e) {
      await connection.close();
      return Future.error(e);
    }

    await connection.close();
  }

  Future<void> select({List<String>? columns, List<String>? conditionsAnd, List<String>? conditionsOr, String? conditionsNamed}) async {
    final Connection connection = await connectionOpen();
    final String tableName = "${runtimeType.toString()[0].toLowerCase() + runtimeType.toString().substring(1)}s";
    final String columnNames = columns?.isNotEmpty == true ? columns!.join(", ") : "*";
    late final String conditions;

    if(conditionsAnd?.isNotEmpty == true) {
      conditions = conditionsAnd!.map((e) => "$e = @$e").join(" and ");
    } else if(conditionsOr?.isNotEmpty == true) {
      conditions = conditionsOr!.map((e) => "$e = @$e").join(" or ");
    } else if((conditionsNamed??"").isNotEmpty) {
      conditions = conditionsNamed!;
    } else {
      conditions = "";
    }

    /// order by
    final String query  = "(select $columnNames from $tableName${conditions.isNotEmpty ? " where $conditions" : ""})";

    try {
      await connection.execute(Sql.named(query), parameters: toJson);
    } catch(e) {
      await connection.close();
      return Future.error(e);
    }

    await connection.close();
  }

  Future<void> update({List<String>? columns, List<String>? conditionsAnd, List<String>? conditionsOr, String? conditionsNamed}) async {
    final Connection connection = await connectionOpen();
    final String tableName = "${runtimeType.toString()[0].toLowerCase() + runtimeType.toString().substring(1)}s";
    final String columnNames = columns?.isNotEmpty == true ? columns!.map((e) => "$e = @$e").join(", ") : toJson.keys.map((e) => "$e = @$e").join(", ");
    late final String conditions;

    if(conditionsAnd?.isNotEmpty == true) {
      conditions = conditionsAnd!.map((e) => "$e = @$e").join(" and ");
    } else if(conditionsOr?.isNotEmpty == true) {
      conditions = conditionsOr!.map((e) => "$e = @$e").join(" or ");
    } else if((conditionsNamed??"").isNotEmpty) {
      conditions = conditionsNamed!;
    } else {
      return Future.error("No conditions");
    }

    final String query  = "update $tableName set $columnNames where $conditions";

    try {
      await connection.execute(Sql.named(query), parameters: toJson);
    } catch(e) {
      await connection.close();
      return Future.error(e);
    }

    await connection.close();
  }

  Future<void> delete({List<String>? conditionsAnd, List<String>? conditionsOr, String? conditionsNamed}) async {
    final Connection connection = await connectionOpen();
    final String tableName = "${runtimeType.toString()[0].toLowerCase() + runtimeType.toString().substring(1)}s";
    late final String conditions;

    if(conditionsAnd?.isNotEmpty == true) {
      conditions = conditionsAnd!.map((e) => "$e = @$e").join(" and ");
    } else if(conditionsOr?.isNotEmpty == true) {
      conditions = conditionsOr!.map((e) => "$e = @$e").join(" or ");
    } else if((conditionsNamed??"").isNotEmpty) {
      conditions = conditionsNamed!;
    } else {
      return Future.error("No conditions");
    }

    final String query  = "delete from $tableName where $conditions";

    try {
      await connection.execute(Sql.named(query), parameters: toJson);
    } catch(e) {
      await connection.close();
      return Future.error(e);
    }

    await connection.close();
  }
}
