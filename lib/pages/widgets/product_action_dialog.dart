import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/models/items/color_model.dart';
import 'package:pcplus/pages/widgets/color_selection_widget.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

class ProductActionDialog extends StatefulWidget {
  final String title;
  final String buttonText;
  final Color buttonColor;
  final List<String> productImages; // Danh sách tất cả hình ảnh sản phẩm
  final int price;
  final int stock;
  final int initialQuantity;
  final int initialSelectedColorIndex;
  final List<ColorModel> colors;
  final VoidCallback onAction;
  final Function(int) onQuantityChanged;

  const ProductActionDialog({
    super.key,
    required this.title,
    required this.buttonText,
    required this.buttonColor,
    required this.productImages,
    required this.price,
    required this.stock,
    required this.initialQuantity,
    required this.initialSelectedColorIndex,
    required this.colors,
    required this.onAction,
    required this.onQuantityChanged,
  });

  @override
  State<ProductActionDialog> createState() => _ProductActionDialogState();
}

class _ProductActionDialogState extends State<ProductActionDialog> {
  late int quantity;
  late int selectedColorIndex; // State riêng cho dialog

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
    selectedColorIndex =
        widget.initialSelectedColorIndex; // Khởi tạo từ parent nhưng độc lập
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      constraints: BoxConstraints(
        maxHeight: size.height * 0.7,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image and Price Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      alignment: Alignment.topRight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(_getCurrentSelectedImage()),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _showFullScreenImage(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: const Icon(
                            Icons.fullscreen,
                            color: Palette.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utility.formatCurrency(widget.price),
                          style:
                              TextDecor.robo18Semi.copyWith(color: Colors.red),
                        ),
                        const Gap(10),
                        Text(
                          'Tồn kho: ${widget.stock}',
                          style: TextDecor.robo17Medi,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              _buildDivider(),

              // Color Selection Section
              if (widget.colors.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: size.width),
                      Text('Màu:', style: TextDecor.robo16),
                      const Gap(10),
                      ColorSelectionWidget(
                        colors: widget.colors,
                        selectedColorIndex: selectedColorIndex,
                        onColorSelected: (index) {
                          setState(() {
                            selectedColorIndex = index;
                          });
                        },
                        useWrapLayout: true,
                        isHorizontalScrollable: false,
                        containerHeight: 45,
                        containerWidth: 100,
                      ),
                    ],
                  ),
                ),
                _buildDivider(),
              ],

              // Quantity Selection Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text("Số lượng:", style: TextDecor.robo16),
                    Expanded(child: Container()),
                    _buildQuantitySelector(),
                  ],
                ),
              ),

              // Action Button
              _buildDivider(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () {
                    // Cập nhật quantity về parent trước khi đóng
                    widget.onQuantityChanged(quantity);
                    widget.onAction();
                  },
                  child: Container(
                    height: 45,
                    width: size.width - 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.buttonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.buttonText,
                      style: TextDecor.robo24Medi.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Lấy hình ảnh hiện tại dựa trên màu được chọn
  String _getCurrentSelectedImage() {
    // Nếu có màu được chọn và màu có hình ảnh riêng
    if (widget.colors.isNotEmpty &&
        selectedColorIndex < widget.colors.length &&
        widget.colors[selectedColorIndex].image != null &&
        widget.colors[selectedColorIndex].image!.isNotEmpty) {
      return widget.colors[selectedColorIndex].image!;
    }

    // Fallback về hình ảnh đầu tiên trong danh sách sản phẩm
    if (widget.productImages.isNotEmpty) {
      // Nếu có nhiều hình, có thể map theo index màu
      int imageIndex = selectedColorIndex < widget.productImages.length
          ? selectedColorIndex
          : 0;
      return widget.productImages[imageIndex];
    }

    return widget.productImages.isNotEmpty ? widget.productImages.first : '';
  }

  Widget _buildDivider({double height = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height == 1 ? 12 : 16),
      child: Container(
        height: height,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (quantity > 1) {
              setState(() {
                quantity--;
              });
            }
          },
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              color: quantity > 1 ? Colors.white : Colors.grey.shade200,
            ),
            child: Icon(
              Icons.remove,
              size: 20,
              color: quantity > 1 ? Colors.black : Colors.grey,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          height: 32,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            color: Colors.white,
          ),
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: TextDecor.robo16.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (quantity < widget.stock) {
              setState(() {
                quantity++;
              });
            }
          },
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              color:
                  quantity < widget.stock ? Colors.white : Colors.grey.shade200,
            ),
            child: Icon(
              Icons.add,
              size: 20,
              color: quantity < widget.stock ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Color _getDefaultColor(int index) {
    switch (index % 3) {
      case 0:
        return Colors.black;
      case 1:
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              child: Image.network(
                _getCurrentSelectedImage(),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}
