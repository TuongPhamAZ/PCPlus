import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/text_decor.dart';

class PriceDisplayWidget extends StatelessWidget {
  final int originalPrice;
  final int? salePrice;
  final double salePriceFontSize;
  final double originalPriceFontSize;
  final bool showDiscountBadge;

  const PriceDisplayWidget({
    super.key,
    required this.originalPrice,
    this.salePrice,
    this.salePriceFontSize = 20,
    this.originalPriceFontSize = 16,
    this.showDiscountBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = salePrice != null && salePrice! < originalPrice;
    final displayPrice = salePrice ?? originalPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sale price - always show prominently
        Text(
          Utility.formatCurrency(displayPrice),
          style: TextDecor.robo18Semi.copyWith(
            color: Colors.red,
            fontSize: salePriceFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),

        if (hasDiscount) ...[
          const Gap(4),
          Row(
            children: [
              // Original price with strikethrough
              Text(
                Utility.formatCurrency(originalPrice),
                style: TextDecor.robo16.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: originalPriceFontSize,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.grey.shade600,
                  decorationThickness: 2,
                ),
              ),

              if (showDiscountBadge) ...[
                const Gap(8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "-${_calculateDiscountPercentage()}%",
                    style: TextDecor.robo12.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  int _calculateDiscountPercentage() {
    if (salePrice == null || salePrice! >= originalPrice) return 0;
    return ((originalPrice - salePrice!) * 100 / originalPrice).round();
  }
}
