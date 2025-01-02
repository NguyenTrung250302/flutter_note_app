import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  EditNoteScreen({required this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title']);
    _contentController = TextEditingController(text: widget.note['content']);
  }

  Future<void> _updateNote() async {
    final url =
        Uri.parse('http://192.168.1.123:8888/notes/${widget.note['id']}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _titleController.text,
        'content': _contentController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Thông báo cập nhật thành công và quay lại màn hình Notes
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã chỉnh sửa ghi chú thành công!')));
      Navigator.pop(context, true); // Trả về true khi ghi chú đã được cập nhật
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update note!')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC4C4C4),
      appBar: AppBar(
        backgroundColor: Color(0xFFC4C4C4),
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Text('Content:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
