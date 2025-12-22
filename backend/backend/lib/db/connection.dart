import 'package:postgres/postgres.dart';

class DB {
  static final connection = PostgreSQLConnection(
    'localhost',
    5432,
    'carservice_lab3',
    username: 'postgres',
    password: 'olegsemo18',
  );

  static Future<void> connect() async {
    await connection.open();
    print("CONNECTED");
  }
}
