import 'package:flutter/material.dart';
import 'package:pcplus/services/fcm_noti.dart';

class ThongBaoScreen extends StatefulWidget {
  const ThongBaoScreen({super.key});

  @override
  State<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends State<ThongBaoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Vui lòng nhập đầy đủ tiêu đề và nội dung';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final bool success = await FCMNotificationService().sendNotification(
        topic: 'test_topic', //Lấy user ID làm tên topic
        title: _titleController.text,
        body: _contentController.text,
        data: {
          'type': 'test_notification',
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      setState(() {
        _isLoading = false;
        _statusMessage =
            success ? 'Gửi thông báo thành công!' : 'Gửi thông báo thất bại!';
      });

      if (success) {
        _titleController.clear();
        _contentController.clear();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Lỗi: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gửi thông báo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendNotification,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Gửi thông báo'),
            ),
            const SizedBox(height: 16),
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('thành công')
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('thành công')
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
