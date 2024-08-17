import 'package:postgres/postgres.dart';

class PostgresConfig {
  static final Endpoint endpoint = Endpoint(
    host: "localhost",
    database: "postgres",
    username: "postgres",
    password: "root"
  );

  static final ConnectionSettings connectionSettings = ConnectionSettings(
    sslMode: SslMode.disable
  );

  static const String errorText = "Xatolik yuz berdi";
}
