import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  Future<void> _saveNote() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.123:8888/notes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': titleController.text,
          'content': contentController.text,
        }),
      );
      if (response.statusCode == 200) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ghi chú đã lưu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
            context); // Pop the editor screen and return to the main screen
      } else {
        throw Exception('Failed to save note');
      }
    } catch (e) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu ghi chú. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error saving note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252525),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 10), // Cách lề trái 20
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // Màu nền trong suốt
              borderRadius: BorderRadius.circular(8), // Bo góc
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 6,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: 20, top: 10), // Cách lề phải 20
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1), // Màu nền trong suốt
                borderRadius: BorderRadius.circular(8), // Bo góc
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _saveNote,
                icon: const Icon(Icons.save, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white, fontSize: 48),
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
                border: InputBorder.none,
              ),
            ),
            Expanded(
              child: TextField(
                controller: contentController,
                style: const TextStyle(color: Colors.white70, fontSize: 23),
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Type something...',
                  hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
