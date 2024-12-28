import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';

final _connection = PostgreSQLConnection(
  'localhost',
  5432,
  'notes_app',
  username: 'postgres',
  password: 'trung253',
);

Future<void> setupApi(Router router) async {
  await _connection.open();

  // Lấy tất cả các ghi chú (GET)
  router.get('/notes', (Request request) async {
    var result = await _connection.query('SELECT * FROM notes');
    var notes = result.map((row) {
      return {
        'id': row[0],
        'title': row[1],
        'content': row[2],
        'created_at': row[3].toString(),
      };
    }).toList();
    return Response.ok(jsonEncode(notes),
        headers: {'Content-Type': 'application/json'});
  });

  // Hàm chung để tạo dữ liệu từ result
  Map<String, dynamic> _mapRowToJson(List<dynamic> row) {
    return {
      'id': row[0],
      'title': row[1],
      'content': row[2],
      'created_at': row[3].toString(),
    };
  }

  // Lấy một ghi chú theo id (GET)
  router.get('/notes/<id>', (Request request, String id) async {
    var result = await _connection.query('SELECT * FROM notes WHERE id = @id',
        substitutionValues: {'id': int.parse(id)});
    if (result.isEmpty) {
      return Response.notFound('Note not found');
    }
    return Response.ok(
      jsonEncode(_mapRowToJson(result.first)),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Thêm một ghi chú mới (POST)
  router.post('/notes', (Request request) async {
    var payload = await request.readAsString();
    var data = jsonDecode(payload);

    var title = data['title'];
    var content = data['content'];

    await _connection.query(
        'INSERT INTO notes (title, content) VALUES (@title, @content)',
        substitutionValues: {'title': title, 'content': content});
    return Response.ok('Note created', headers: {'Content-Type': 'text/plain'});
  });

  router.put('/notes/<id>', (Request request, String id) async {
    print('PUT request received for id: $id'); // Logging
    var payload = await request.readAsString();
    var data = jsonDecode(payload);

    var title = data['title'];
    var content = data['content'];

    await _connection.query(
        'UPDATE notes SET title = @title, content = @content WHERE id = @id',
        substitutionValues: {
          'title': title,
          'content': content,
          'id': int.parse(id)
        });
    return Response.ok('Note updated', headers: {'Content-Type': 'text/plain'});
  });

// Xóa ghi chú (DELETE)
  router.delete('/notes/<id>', (Request request, String id) async {
    var result = await _connection.query('DELETE FROM notes WHERE id = @id',
        substitutionValues: {'id': int.parse(id)});

    if (result.affectedRowCount == 0) {
      return Response.notFound('Note not found');
    }

    return Response.ok('Note deleted', headers: {'Content-Type': 'text/plain'});
  });
}
