import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pcplus/commands/home_command.dart';
import 'package:pcplus/component/item_argument.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/factories/widget_factories/new_item_factory.dart';
import 'package:pcplus/factories/widget_factories/suggest_item_factory.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/home/user_home/home_contract.dart';
import 'package:pcplus/pages/conversations/conversations.dart';
import 'package:pcplus/pages/image_search_result/image_search_result.dart';
import 'package:pcplus/services/image_storage_service.dart';
import 'package:pcplus/services/vector_api_service.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product.dart';
import 'package:pcplus/pages/search/search_screen.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import '../../../component/search_argument.dart';
import '../../widgets/bottom/bottom_bar_custom.dart';
import '../../widgets/util_widgets.dart';
import 'home_presenter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = 'home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeContract {
  HomePresenter? _presenter;
  bool isShop = false;
  bool isLoading = true;
  bool isFirstLoad = true;
  List<Widget> newProducts = [];
  List<Widget> recommendedProducts = [];

  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final VectorApiService _vectorApiService = VectorApiService();
  final ImageStorageService _imageStorageService = ImageStorageService();

  bool init = false;

  @override
  void initState() {
    _presenter = HomePresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (init) return;
    init = true;

    loadData();
  }

  Future<void> loadData() async {
    await _presenter?.getData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading
          ? UtilWidgets.getLoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 42,
                      width: double.infinity,
                      child: TextField(
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        onChanged: (value) {},
                        onSubmitted: (value) {
                          _presenter!
                              .handleSearch(_searchController.text.trim());
                        },
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Palette.primaryColor, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Palette.primaryColor, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.only(top: 4),
                          prefixIcon: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              _presenter!
                                  .handleSearch(_searchController.text.trim());
                            },
                            child: const Icon(
                              FontAwesomeIcons.magnifyingGlass,
                              size: 16,
                              //color: Palette.greenText,
                            ),
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Microphone icon
                              InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  _startListening();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    FontAwesomeIcons.microphone,
                                    size: 16,
                                  ),
                                ),
                              ),
                              // Camera icon
                              InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  _startImageSearch();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    FontAwesomeIcons.camera,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          hintText: 'Tìm kiếm',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.only(top: 12),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            height: 145,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Palette.primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Music and no\nmore",
                                  style: TextDecor.robo24Medi,
                                ),
                                const Gap(0),
                                Text(
                                  "Giảm 10% cho một trong\nnhững tai nghe tốt nhất\nthế giới",
                                  style: TextDecor.robo12,
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            AssetHelper.sampleImage,
                          ),
                        ],
                      ),
                    ),
                    const Gap(30),
                    Text('Sản phẩm mới', style: TextDecor.robo18Bold),
                    const Gap(10),
                    SizedBox(
                      height: 285,
                      width: size.width,
                      child: StreamBuilder<List<ItemWithSeller>>(
                          stream: _presenter!.newestItemStream,
                          builder: (context, snapshot) {
                            Widget? result =
                                UtilWidgets.createSnapshotResultWidget(
                                    context, snapshot);
                            if (result != null) {
                              return result;
                            }

                            final itemsWithSeller = snapshot.data ?? [];

                            if (itemsWithSeller.isEmpty) {
                              return const Center(child: Text('Không có dữ liệu'));
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              itemCount: itemsWithSeller.length,
                              itemBuilder: (context, index) {
                                return NewItemFactory.create(
                                    itemWithSeller: itemsWithSeller[index],
                                    command: HomeItemPressedCommand(
                                        presenter: _presenter!,
                                        item: itemsWithSeller[index]));
                              },
                            );
                          }),
                    ),
                    const Gap(30),
                    Text('Gợi ý cho bạn', style: TextDecor.robo18Bold),
                    const Gap(10),
                    StreamBuilder<List<ItemWithSeller>>(
                        stream: _presenter!.recommendedItemStream,
                        builder: (context, snapshot) {
                          Widget? result =
                              UtilWidgets.createSnapshotResultWidget(
                                  context, snapshot);
                          if (result != null) {
                            return result;
                          }

                          final itemsWithSeller = snapshot.data ?? [];

                          if (itemsWithSeller.isEmpty) {
                            return const Center(child: Text('Không có dữ liệu'));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: itemsWithSeller.length,
                            itemBuilder: (context, index) {
                              return SuggestItemFactory.create(
                                  itemWithSeller: itemsWithSeller[index],
                                  command: HomeItemPressedCommand(
                                      presenter: _presenter!,
                                      item: itemsWithSeller[index]));
                            },
                          );
                        }),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomBarCustom(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, ConversationsScreen.routeName);
        },
        backgroundColor: Palette.primaryColor,
        child: const Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
    );
  }

  // ===========================================================================

  Future<void> _startListening() async {
    bool isAvailable =
        await SpeechToTextGoogleDialog.getInstance().showGoogleDialog(
      onTextReceived: (text) {
        _presenter?.handleSearch(text);
      },
      locale: 'vi-VN',
    );

    if (!mounted) {
      return;
    }

    if (!isAvailable) {
      UtilWidgets.createSnackBar(context, 'Không thể mở Google Speech Dialog',
          backgroundColor: Colors.red);
    }
  }

  // Image search functionality
  Future<void> _startImageSearch() async {
    _showImageSourceBottomSheet();
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chọn nguồn ảnh',
                style: TextDecor.robo18Bold,
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Chụp ảnh',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Thư viện',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                ],
              ),
              const Gap(20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Palette.primaryColor,
            ),
            const Gap(8),
            Text(
              label,
              style: TextDecor.robo14.copyWith(color: Palette.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      // Kiểm tra quyền camera
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        UtilWidgets.createSnackBar(
          context,
          'Cần cấp quyền camera để chụp ảnh',
          backgroundColor: Colors.red,
        );
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        await _processSelectedImage(File(pickedFile.path));
      }
    } catch (e) {
      UtilWidgets.createSnackBar(
        context,
        'Lỗi khi chụp ảnh: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // Kiểm tra quyền storage (Android)
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          final photosStatus = await Permission.photos.request();
          if (!photosStatus.isGranted) {
            UtilWidgets.createSnackBar(
              context,
              'Cần cấp quyền truy cập ảnh để chọn từ thư viện',
              backgroundColor: Colors.red,
            );
            return;
          }
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        await _processSelectedImage(File(pickedFile.path));
      }
    } catch (e) {
      UtilWidgets.createSnackBar(
        context,
        'Lỗi khi chọn ảnh: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _processSelectedImage(File imageFile) async {
    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Upload ảnh lên Cloudinary
      final platformFile =
          await _imageStorageService.convertFileToPlatformFile(imageFile);
      final imageUrl = await _imageStorageService.uploadImage(
        'search',
        platformFile,
        'search_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (imageUrl == null) {
        Navigator.pop(context); // Đóng loading
        UtilWidgets.createSnackBar(
          context,
          'Lỗi khi upload ảnh',
          backgroundColor: Colors.red,
        );
        return;
      }

      // Gọi API tìm kiếm
      final results = await _vectorApiService.searchProducts(
        imageUrl: imageUrl,
        topK: 20,
        similarityThreshold: 0.7,
      );

      Navigator.pop(context); // Đóng loading

      if (results != null) {
        // Chuyển đến trang kết quả
        Navigator.pushNamed(
          context,
          ImageSearchResult.routeName,
          arguments: ImageSearchResultArgument(
            productIds: results,
            searchImageUrl: imageUrl,
            searchImageFile: imageFile,
          ),
        );
      } else {
        // Không có kết quả hoặc lỗi
        Navigator.pushNamed(
          context,
          ImageSearchResult.routeName,
          arguments: ImageSearchResultArgument(
            productIds: [],
            searchImageUrl: imageUrl,
            searchImageFile: imageFile,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Đóng loading
      UtilWidgets.createSnackBar(
        context,
        'Lỗi khi tìm kiếm: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  // ===========================================================================

  @override
  Future<void> onLoadDataSucceed() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  void onItemPressed(ItemWithSeller itemData) {
    Navigator.of(context).pushNamed(
      DetailProduct.routeName,
      arguments: ItemArgument(data: itemData),
    );
  }

  @override
  void onSearch(String text) {
    Navigator.of(context).pushNamed(
      SearchScreen.routeName,
      arguments: SearchArgument(query: text.trim()),
    );
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
