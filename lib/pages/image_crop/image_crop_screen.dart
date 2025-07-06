import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image/image.dart' as img;
import 'package:pcplus/pages/widgets/profile/button_profile.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/themes/palette/palette.dart';

class ImageCropScreen extends StatefulWidget {
  final File imageFile;
  final Function(File croppedImageFile) onImageCropped;

  const ImageCropScreen({
    super.key,
    required this.imageFile,
    required this.onImageCropped,
  });

  static const String routeName = 'image_crop_screen';

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  late ui.Image _image;
  bool _imageLoaded = false;

  // Crop box properties
  Rect _cropRect = const Rect.fromLTWH(50, 50, 200, 200);
  final double _minCropSize = 50.0;

  // Screen and image dimensions
  Size _screenSize = Size.zero;
  Size _imageDisplaySize = Size.zero;
  Offset _imageDisplayOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    setState(() {
      _image = frame.image;
      _imageLoaded = true;
    });

    // Initialize crop rect after image is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCropRect();
    });
  }

  void _initializeCropRect() {
    if (!_imageLoaded) return;

    final screenSize = MediaQuery.of(context).size;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    // Simple approach: use full screen for image display
    final appBarHeight = kToolbarHeight;
    final bottomBarHeight = 100.0; // Space for bottom controls

    // Available space for image (use most of screen)
    final availableHeight =
        screenSize.height - safeAreaTop - appBarHeight - bottomBarHeight;
    final availableWidth = screenSize.width - 20; // 10px padding each side

    // Calculate image size to fit screen while maintaining aspect ratio
    final imageAspectRatio = _image.width / _image.height;
    final screenAspectRatio = availableWidth / availableHeight;

    if (imageAspectRatio > screenAspectRatio) {
      // Image is wider - fit to width
      _imageDisplaySize =
          Size(availableWidth, availableWidth / imageAspectRatio);
    } else {
      // Image is taller - fit to height
      _imageDisplaySize =
          Size(availableHeight * imageAspectRatio, availableHeight);
    }

    // Center image on screen
    _imageDisplayOffset = Offset(
      (screenSize.width - _imageDisplaySize.width) / 2,
      safeAreaTop +
          appBarHeight +
          (availableHeight - _imageDisplaySize.height) / 2,
    );

    // Default crop rect: small rectangle in center of image (matching actual top: 10)
    final defaultCropSize = Size(150, 150); // Small default size
    final cropLeft = _imageDisplayOffset.dx +
        (_imageDisplaySize.width - defaultCropSize.width) / 2;
    final cropTop =
        10.0 + (_imageDisplaySize.height - defaultCropSize.height) / 2;

    setState(() {
      _cropRect = Rect.fromLTWH(
          cropLeft, cropTop, defaultCropSize.width, defaultCropSize.height);
      _screenSize = screenSize;
    });
  }

  Future<void> _cropImage() async {
    if (!_imageLoaded) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Read original image
      final bytes = await widget.imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi xử lý ảnh')),
        );
        return;
      }

      // Calculate crop coordinates relative to original image
      final scaleX = originalImage.width / _imageDisplaySize.width;
      final scaleY = originalImage.height / _imageDisplaySize.height;

      final cropX = ((_cropRect.left - _imageDisplayOffset.dx) * scaleX)
          .round()
          .clamp(0, originalImage.width);
      final cropY =
          ((_cropRect.top - 10.0) * scaleY) // Use actual image top position
              .round()
              .clamp(0, originalImage.height);
      final cropWidth = (_cropRect.width * scaleX)
          .round()
          .clamp(1, originalImage.width - cropX);
      final cropHeight = (_cropRect.height * scaleY)
          .round()
          .clamp(1, originalImage.height - cropY);

      // Crop the image
      final croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // Save cropped image to temporary file
      final tempDir = Directory.systemTemp;
      final tempPath =
          '${tempDir.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 80));

      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close crop screen

      // Call callback with cropped image
      widget.onImageCropped(tempFile);
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cắt ảnh: $e')),
      );
    }
  }

  void _updateCropRect(Rect newRect) {
    // Keep crop rect within image boundaries (matching actual top: 10)
    final imageLeft = _imageDisplayOffset.dx;
    final imageTop = 10.0; // Actual image top position
    final imageRight = imageLeft + _imageDisplaySize.width;
    final imageBottom = imageTop + _imageDisplaySize.height;

    final left = newRect.left.clamp(imageLeft, imageRight - _minCropSize);
    final top = newRect.top.clamp(imageTop, imageBottom - _minCropSize);
    final right = newRect.right.clamp(left + _minCropSize, imageRight);
    final bottom = newRect.bottom.clamp(top + _minCropSize, imageBottom);

    setState(() {
      _cropRect = Rect.fromLTRB(left, top, right, bottom);
    });
  }

  void _resetCrop() {
    if (!_imageLoaded) return;

    // Reset to small rectangle in center of image (matching actual top: 10)
    final defaultCropSize = Size(150, 150);
    final cropLeft = _imageDisplayOffset.dx +
        (_imageDisplaySize.width - defaultCropSize.width) / 2;
    final cropTop =
        10.0 + (_imageDisplaySize.height - defaultCropSize.height) / 2;

    setState(() {
      _cropRect = Rect.fromLTWH(
          cropLeft, cropTop, defaultCropSize.width, defaultCropSize.height);
    });
  }

  void _expandCropToFullImage() {
    if (!_imageLoaded) return;

    setState(() {
      _cropRect = Rect.fromLTWH(
        _imageDisplayOffset.dx,
        10.0, // Actual image top position
        _imageDisplaySize.width,
        _imageDisplaySize.height,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cắt ảnh để tìm kiếm',
          style: TextDecor.robo18Bold.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.crop_free, color: Colors.white),
            onPressed: _expandCropToFullImage,
            tooltip: 'Chọn toàn bộ ảnh',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetCrop,
            tooltip: 'Đặt lại khung cắt',
          ),
        ],
      ),
      body: !_imageLoaded
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Image display
                Positioned(
                  left: _imageDisplayOffset.dx,
                  top: 10,
                  child: SizedBox(
                    width: _imageDisplaySize.width,
                    height: _imageDisplaySize.height,
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Crop overlay
                CustomPaint(
                  painter: CropOverlayPainter(
                    cropRect: _cropRect,
                    imageRect: Rect.fromLTWH(
                      _imageDisplayOffset.dx,
                      10.0, // Actual image top position
                      _imageDisplaySize.width,
                      _imageDisplaySize.height,
                    ),
                  ),
                  child: SizedBox(
                    width: _screenSize.width,
                    height: _screenSize.height,
                  ),
                ),
                // Crop handles
                if (_imageLoaded) ..._buildCropHandles(),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.black,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kéo thả các góc để thay đổi khung cắt, hoặc kéo giữa khung để di chuyển',
                style: TextDecor.robo12.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const Gap(10),
              ButtonProfile(
                name: 'Tìm kiếm với vùng đã chọn',
                onPressed: _cropImage,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCropHandles() {
    const handleSize = 20.0;
    return [
      // Top-left handle
      Positioned(
        left: _cropRect.left - handleSize / 2,
        top: _cropRect.top - handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            _updateCropRect(Rect.fromLTRB(
              _cropRect.left + details.delta.dx,
              _cropRect.top + details.delta.dy,
              _cropRect.right,
              _cropRect.bottom,
            ));
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: const BoxDecoration(
              color: Palette.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      // Top-right handle
      Positioned(
        left: _cropRect.right - handleSize / 2,
        top: _cropRect.top - handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            _updateCropRect(Rect.fromLTRB(
              _cropRect.left,
              _cropRect.top + details.delta.dy,
              _cropRect.right + details.delta.dx,
              _cropRect.bottom,
            ));
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: const BoxDecoration(
              color: Palette.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      // Bottom-left handle
      Positioned(
        left: _cropRect.left - handleSize / 2,
        top: _cropRect.bottom - handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            _updateCropRect(Rect.fromLTRB(
              _cropRect.left + details.delta.dx,
              _cropRect.top,
              _cropRect.right,
              _cropRect.bottom + details.delta.dy,
            ));
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: const BoxDecoration(
              color: Palette.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      // Bottom-right handle
      Positioned(
        left: _cropRect.right - handleSize / 2,
        top: _cropRect.bottom - handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            _updateCropRect(Rect.fromLTRB(
              _cropRect.left,
              _cropRect.top,
              _cropRect.right + details.delta.dx,
              _cropRect.bottom + details.delta.dy,
            ));
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: const BoxDecoration(
              color: Palette.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      // Move handle (center)
      Positioned(
        left: _cropRect.center.dx - handleSize / 2,
        top: _cropRect.center.dy - handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            final newLeft = _cropRect.left + details.delta.dx;
            final newTop = _cropRect.top + details.delta.dy;
            _updateCropRect(Rect.fromLTWH(
              newLeft,
              newTop,
              _cropRect.width,
              _cropRect.height,
            ));
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: Palette.primaryColor.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.drag_indicator,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ),
    ];
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final Rect imageRect;

  CropOverlayPainter({
    required this.cropRect,
    required this.imageRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw semi-transparent overlay outside crop area
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Create path for the overlay (everything except crop area)
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw crop rect border
    final borderPaint = Paint()
      ..color = Palette.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(cropRect, borderPaint);

    // Draw grid lines inside crop rect
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Vertical grid lines
    final gridWidth = cropRect.width / 3;
    for (int i = 1; i < 3; i++) {
      final x = cropRect.left + gridWidth * i;
      canvas.drawLine(
        Offset(x, cropRect.top),
        Offset(x, cropRect.bottom),
        gridPaint,
      );
    }

    // Horizontal grid lines
    final gridHeight = cropRect.height / 3;
    for (int i = 1; i < 3; i++) {
      final y = cropRect.top + gridHeight * i;
      canvas.drawLine(
        Offset(cropRect.left, y),
        Offset(cropRect.right, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.imageRect != imageRect;
  }
}
