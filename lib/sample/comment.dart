import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:firebase_core/firebase_core.dart';

class SampleComment extends StatefulWidget {
  const SampleComment({super.key});
  static const String routeName = '/sample/comment';

  @override
  State<SampleComment> createState() => _SampleCommentState();
}

class _SampleCommentState extends State<SampleComment> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _comments = [];
  final ProfanityFilter _filter = ProfanityFilter();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeRemoteConfig();
  }

  Future<void> _initializeRemoteConfig() async {
    try {
      // Khởi tạo Firebase
      await Firebase.initializeApp();

      // Cấu hình Remote Config
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Fetch và kích hoạt config
      await remoteConfig.fetchAndActivate();

      // Lấy danh sách từ cấm từ Remote Config
      final badWordsString = remoteConfig.getString('bad_words');
      final badWordsList = badWordsString.split(',');

      // Cập nhật bộ lọc
      _filter.wordsToFilterOutList = badWordsList;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi khi khởi tạo Remote Config: $e');
      _filter.wordsToFilterOutList = _getDefaultBadWords();
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _getDefaultBadWords() {
    return ['địt', 'lồn', 'cặc'];
  }

  void _submitComment() {
    if (_isLoading) {
      _showAlert('Hệ thống đang khởi tạo...');
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_filter.hasProfanity(text)) {
      _showAlert('Bình luận chứa từ ngữ không phù hợp!');
    } else {
      setState(() {
        _comments.insert(0, text);
      });
      _controller.clear();
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cảnh báo'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm duyệt bình luận')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nhập bình luận...',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitComment,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Gửi'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Danh sách bình luận hợp lệ:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (_, index) => ListTile(
                        leading: const Icon(Icons.comment),
                        title: Text(_comments[index]),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
