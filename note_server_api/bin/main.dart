import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:io'; // Thêm import này để sử dụng InternetAddress
import 'note_api.dart';

// Middleware CORS tùy chỉnh
Middleware corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      final response = await handler(request);

      // Thêm các header CORS vào response
      return response.change(headers: {
        'Access-Control-Allow-Origin':
            '*', // Cho phép mọi nguồn (có thể thay thế theo yêu cầu)
        'Access-Control-Allow-Methods':
            'GET, POST, PUT, DELETE, OPTIONS', // Các phương thức được phép
        'Access-Control-Allow-Headers':
            'Origin, Content-Type, Accept, Authorization', // Các header được phép
        'Access-Control-Allow-Credentials': 'true', // Cho phép cookie nếu cần
      });
    };
  };
}

Future<void> main() async {
  final router = Router();

  // Thiết lập API của bạn
  await setupApi(router);

  // Thêm middleware CORS
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders()) // Sử dụng middleware CORS tùy chỉnh
      .addHandler(router);

  // Thêm route xử lý OPTIONS requests cho pre-flight
  router.options('/<any|.*>', (Request request) async {
    return Response.ok('', headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
    });
  });

  // Chạy server trên tất cả các địa chỉ IPv4
  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Server running on http://${server.address.host}:${server.port}');
}
