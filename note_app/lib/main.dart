import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Hàm gọi API để lấy danh sách các ghi chú (GET)
  Future<List<dynamic>> fetchNotes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/notes'), // Địa chỉ API của BE
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Giải mã JSON từ response
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      print('Error fetching notes: $e');
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  // Hàm gọi API để thêm một ghi chú mới (POST)
  Future<void> createNote(String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/notes'), // Địa chỉ API của BE
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'content': content}),
      );

      if (response.statusCode == 200) {
        print('Note created');
      } else {
        throw Exception('Failed to create note');
      }
    } catch (e) {
      print('Error creating note: $e');
    }
  }

  // Hàm gọi API để xóa ghi chú (DELETE)
  Future<void> deleteNote(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://localhost:8080/notes/$id'), // Địa chỉ API của BE với id ghi chú
      );

      if (response.statusCode == 200) {
        print('Note deleted');
      } else {
        throw Exception('Failed to delete note');
      }
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  // Hàm gọi API để sửa ghi chú (PUT)
  Future<void> updateNote(int id, String title, String content) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:8080/notes/$id'), // Địa chỉ API của BE với id ghi chú
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'content': content}),
      );

      if (response.statusCode == 200) {
        print('Note updated');
      } else {
        throw Exception('Failed to update note');
      }
    } catch (e) {
      print('Error updating note: $e');
    }
  }

  // Hàm hiển thị giao diện nhập ghi chú
  Widget buildAddNoteForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          SizedBox(height: 8.0),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(labelText: 'Content'),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text;
              final content = _contentController.text;
              if (title.isNotEmpty && content.isNotEmpty) {
                createNote(title, content);
                _titleController.clear();
                _contentController.clear();
              }
            },
            child: Text('Add Note'),
          ),
        ],
      ),
    );
  }

  // Giao diện sửa ghi chú
  void _editNote(int id, String currentTitle, String currentContent) {
    _titleController.text = currentTitle;
    _contentController.text = currentContent;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateNote(id, _titleController.text, _contentController.text);
                Navigator.pop(context); // Đóng dialog
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes App'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildAddNoteForm(), // Giao diện nhập ghi chú
            FutureBuilder<List<dynamic>>(
              future: fetchNotes(), // Gọi API để lấy danh sách ghi chú
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<dynamic> notes = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      var note = notes[index];
                      return ListTile(
                        title: Text(note['title']),
                        subtitle: Text(note['content']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editNote(
                                    note['id'], note['title'], note['content']);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                deleteNote(note['id']);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No notes available'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
