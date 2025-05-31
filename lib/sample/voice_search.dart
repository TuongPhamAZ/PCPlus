import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';

class VoiceSearchSample extends StatefulWidget {
  const VoiceSearchSample({super.key});
  static const String routeName = '/sample/voice_search';

  @override
  State<VoiceSearchSample> createState() => _VoiceSearchSampleState();
}

class _VoiceSearchSampleState extends State<VoiceSearchSample> {
  String _spokenText = '';
  final List<String> _items = [
    'Macbook Pro',
    'Dell XPS 13',
    'Asus Vivobook',
    'iPhone 15 Pro Max',
    'Samsung Galaxy S24 Ultra',
    'Lenovo ThinkPad',
    'HP Pavilion',
  ];
  List<String> _searchResults = [];

  late Fuzzy _fuzzy;

  @override
  void initState() {
    super.initState();
    _fuzzy = Fuzzy(_items, options: FuzzyOptions(threshold: 0.5));
  }

  Future<void> _startListening() async {
    bool isAvailable =
        await SpeechToTextGoogleDialog.getInstance().showGoogleDialog(
      onTextReceived: (text) {
        setState(() {
          _spokenText = text.toString();
          _searchResults =
              _fuzzy.search(_spokenText).map((r) => r.item as String).toList();
        });
      },
      locale: 'vi-VN',
    );

    if (!isAvailable && context.mounted) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở Google Speech Dialog'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm giọng nói + Fuzzy')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _startListening,
              icon: const Icon(Icons.mic),
              label: const Text("Tìm bằng giọng nói"),
            ),
            const SizedBox(height: 20),
            Text(
              "🔎 Bạn đã nói:",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              _spokenText.isEmpty ? "(chưa có)" : "\"$_spokenText\"",
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 30),
            Text(
              "🔎 Kết quả tìm kiếm:",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            if (_searchResults.isEmpty)
              const Text("Không có kết quả.")
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (_, index) => ListTile(
                    title: Text(_searchResults[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
