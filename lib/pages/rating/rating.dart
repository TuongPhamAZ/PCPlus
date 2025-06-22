import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:pcplus/pages/rating/rating_contract.dart';
import 'package:pcplus/pages/rating/rating_presenter.dart';
import 'package:pcplus/services/utility.dart';
import 'package:profanity_filter/profanity_filter.dart';
import '../../commands/rating_item/rating_item_on_submit_command.dart';
import '../../models/await_ratings/await_rating_model.dart';
import '../../themes/text_decor.dart';
import '../widgets/listItem/rating_item.dart';
import '../widgets/util_widgets.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});
  static const String routeName = 'rating_screen';

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    implements RatingScreenContract {
  RatingPresenter? _presenter;
  final ProfanityFilter _filter = ProfanityFilter();
  bool _isLoading = true;
  bool _isFirstLoad = true;

  @override
  void initState() {
    _presenter = RatingPresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      loadData();
      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    _presenter?.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (mounted) {
      if (_isLoading) {
        await _initializeRemoteConfig();
        await _presenter?.getData();
      }
    }
  }

  Future<void> _initializeRemoteConfig() async {
    try {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gửi đánh giá',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? UtilWidgets.getLoadingWidget()
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.5),
              ),
              child: SingleChildScrollView(
                child: StreamBuilder<List<AwaitRatingModel>>(
                  stream: _presenter!.awaitRatingStream,
                  builder: (context, snapshot) {
                    Widget? result = UtilWidgets.createSnapshotResultWidget(
                        context, snapshot);
                    if (result != null) {
                      return result;
                    }

                    final awaitRatings = snapshot.data ?? [];

                    if (awaitRatings.isEmpty) {
                      return const Center(child: Text(''));
                    }

                    List<AwaitRatingModel> items = [];

                    for (AwaitRatingModel model in awaitRatings) {
                      if (Utility.calculateDuration(
                                  model.createdAt!, DateTime.now())
                              .inDays <=
                          30) {
                        items.add(model);
                      }
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return RatingItem(
                          shopName: items[index].shopName!,
                          productName: items[index].item!.name!,
                          color: items[index].item!.color!.name!,
                          image: items[index].item!.color!.image!,
                          dayRemain: 30 -
                              Utility.calculateDuration(
                                      items[index].createdAt!, DateTime.now())
                                  .inDays,
                          buyAmount: items[index].item!.amount!,
                          onSubmit: RatingItemOnSubmitCommand(
                            presenter: _presenter!,
                            model: items[index],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }

  @override
  bool submitComment(String? message) {
    if (_isLoading) {
      _showAlert('Hệ thống đang khởi tạo...');
      return false;
    }

    if (message == null || message.isEmpty) return false;

    if (_filter.hasProfanity(message)) {
      _showAlert('Bình luận chứa từ ngữ không phù hợp!');
      return false;
    }

    return true;
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
  void onLoadDataSucceeded() {
    // TODO: implement onLoadDataSucceeded
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }
}
