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
    try {
      var noteId = int.parse(id); // Chuyển đổi id thành số
      var result = await _connection.query('SELECT * FROM notes WHERE id = @id',
          substitutionValues: {'id': noteId});
      if (result.isEmpty) {
        return Response.notFound('Note not found');
      }
      return Response.ok(
        jsonEncode(_mapRowToJson(result.first)),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
          body: 'Invalid ID format', headers: {'Content-Type': 'text/plain'});
    }
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
    return Response.ok(jsonEncode({'message': 'Note created successfully'}),
        headers: {'Content-Type': 'application/json'});
  });

// Cập nhật ghi chú (PUT)
  router.put('/notes/<id>', (Request request, String id) async {
    try {
      var noteId = int.parse(id);
      var payload = await request.readAsString();
      var data = jsonDecode(payload);

      var title = data['title'];
      var content = data['content'];

      await _connection.query(
          'UPDATE notes SET title = @title, content = @content WHERE id = @id',
          substitutionValues: {
            'title': title,
            'content': content,
            'id': noteId
          });

      return Response.ok(jsonEncode({'message': 'Note updated successfully'}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.badRequest(
          body: 'Invalid ID format', headers: {'Content-Type': 'text/plain'});
    }
  });

// Xóa ghi chú (DELETE)
  router.delete('/notes/<id>', (Request request, String id) async {
    try {
      var noteId = int.parse(id);
      var result = await _connection.query('DELETE FROM notes WHERE id = @id',
          substitutionValues: {'id': noteId});

      if (result.affectedRowCount == 0) {
        return Response.notFound(jsonEncode({'message': 'Note not found'}),
            headers: {'Content-Type': 'application/json'});
      }

      return Response.ok(jsonEncode({'message': 'Note deleted successfully'}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.badRequest(
          body: 'Invalid ID format', headers: {'Content-Type': 'text/plain'});
    }
  });
}
