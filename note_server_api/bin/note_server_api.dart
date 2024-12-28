import 'dart:async';
import 'package:postgres/postgres.dart';

// Hàm kết nối đến cơ sở dữ liệu
Future<PostgreSQLConnection> connectToDatabase() async {
  final connection = PostgreSQLConnection(
    'localhost', // Địa chỉ máy chủ PostgreSQL (thường là localhost)
    5432, // Cổng mặc định của PostgreSQL
    'notes_app', // Tên database
    username: 'postgres', // Tên người dùng PostgreSQL
    password: 'trung253', // Mật khẩu PostgreSQL của bạn
  );

  // Kết nối đến cơ sở dữ liệu
  await connection.open();
  return connection;
}

// Hàm tạo bảng nếu chưa tồn tại
Future<void> createNotesTable(PostgreSQLConnection connection) async {
  final createTableQuery = '''
  CREATE TABLE IF NOT EXISTS notes (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
  );
  ''';

  await connection.query(createTableQuery);
  print('Table "notes" created or already exists.');
}

Future<void> main() async {
  final connection = await connectToDatabase();

  // Tạo bảng `notes` nếu chưa tồn tại
  await createNotesTable(connection);

  print('Database and table setup completed.');
}
