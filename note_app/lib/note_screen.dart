import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app/edit_screen.dart';
import 'add_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<dynamic> notes = [];
  final List<Color> noteColors = [
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    const Color.fromARGB(255, 54, 206, 244),
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.123:8888/notes'));
      if (response.statusCode == 200) {
        setState(() {
          notes = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  Future<void> _deleteNote(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('http://192.168.1.123:8888/notes/$id'));

      if (response.statusCode == 200) {
        _fetchNotes(); // Lấy lại danh sách ghi chú
        // Hiển thị SnackBar thông báo xóa thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa ghi chú thành công!'),
            backgroundColor:
                Colors.green, // Màu nền xanh cho thông báo thành công
          ),
        );
      } else {
        throw Exception('Failed to delete note');
      }
    } catch (e) {
      print('Error deleting note: $e');
      // Hiển thị thông báo lỗi khi không xóa được
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete note'),
          backgroundColor: Colors.red, // Màu nền đỏ cho thông báo lỗi
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252525),
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 15.0), // Khoảng cách từ lề trên
          child: Text(
            'Notes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 43,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/rafiki.png',
                    height: 250,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tạo ghi chú đầu tiên của bạn!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                var note = notes[index];
                return Dismissible(
                  key: Key(note['id'].toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteNote(note['id']);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: const Color.fromARGB(255, 50, 166, 233),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Container(
                    height: 120,
                    child: Card(
                      color: noteColors[index % noteColors.length],
                      child: ListTile(
                        title: Text(
                          note['title'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          note['content'],
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          // Khi ấn vào ghi chú, chuyển đến màn hình chỉnh sửa ghi chú
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNoteScreen(note: note),
                            ),
                          ).then((value) {
                            if (value != null && value) {
                              // Nếu note đã được cập nhật, gọi lại _fetchNotes() để tải lại danh sách ghi chú
                              _fetchNotes();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

      // add_note ----------------------------------------------------------------
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF252525),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
          ).then((value) =>
              _fetchNotes()), // Refresh notes after returning from the editor screen
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
          shape: const CircleBorder(), // Đảm bảo nút là hình tròn
          elevation: 10, // Tạo bóng đổ cho nút
        ),
      ),
    );
  }
}
