import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/models/items/color_model.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

class ColorSelectionWidget extends StatelessWidget {
  final List<ColorModel> colors;
  final int selectedColorIndex;
  final Function(int) onColorSelected;
  final bool isHorizontalScrollable;
  final bool useWrapLayout;
  final double containerHeight;
  final double containerWidth;

  const ColorSelectionWidget({
    super.key,
    required this.colors,
    required this.selectedColorIndex,
    required this.onColorSelected,
    this.isHorizontalScrollable = true,
    this.useWrapLayout = false,
    this.containerHeight = 45,
    this.containerWidth = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> colorItems = List.generate(
      colors.length,
      (index) {
        final color = colors[index];
        final isSelected = selectedColorIndex == index;

        return GestureDetector(
          onTap: () => onColorSelected(index),
          child: Container(
            margin: EdgeInsets.only(
              right: useWrapLayout ? 8 : 10,
              bottom: useWrapLayout ? 8 : 0,
            ),
            height: containerHeight,
            width: containerWidth,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    isSelected ? Palette.primaryColor : Palette.borderBackBtn,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  // ignore: deprecated_member_use
                  ? Palette.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Palette.primaryColor
                          : Palette.borderBackBtn,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    image: color.image != null && color.image!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(color.image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: color.image == null || color.image!.isEmpty
                        ? _getDefaultColor(index)
                        : null,
                  ),
                ),
                const Gap(5),
                Expanded(
                  child: Text(
                    color.name ?? 'Màu ${index + 1}',
                    style: TextDecor.robo14.copyWith(
                      color: isSelected ? Palette.primaryColor : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (useWrapLayout) {
      return Wrap(
        children: colorItems,
      );
    }

    Widget colorList = Row(children: colorItems);

    if (isHorizontalScrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: colorList,
      );
    }

    return colorList;
  }

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
}
