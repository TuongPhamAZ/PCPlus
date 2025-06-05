import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

class PaymentChoice extends StatefulWidget {
  final String initialMethod;
  const PaymentChoice({super.key, this.initialMethod = 'Cash on delivery'});
  static const String routeName = 'payment_choice';

  @override
  State<PaymentChoice> createState() => _PaymentChoiceState();
}

class _PaymentChoiceState extends State<PaymentChoice> {
  late String method;

  @override
  void initState() {
    super.initState();
    method = widget.initialMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'PHƯƠNG THỨC THANH TOÁN',
          style: TextDecor.robo18Bold.copyWith(
            color: Palette.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 26,
            color: Palette.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Cash on Delivery
            InkWell(
              onTap: () {
                setState(() {
                  method = 'Cash on delivery';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: method == 'Cash on delivery'
                      ? Border.all(color: Palette.primaryColor, width: 2)
                      : Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.money,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thanh toán khi nhận hàng',
                            style: TextDecor.robo16Medi.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Thanh toán bằng tiền mặt khi nhận được hàng',
                            style: TextDecor.robo14.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    if (method == 'Cash on delivery')
                      Icon(
                        Icons.check_circle,
                        color: Palette.primaryColor,
                        size: 24,
                      )
                    else
                      Icon(
                        Icons.circle_outlined,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
            const Gap(16),

            // ZaloPay
            InkWell(
              onTap: () {
                setState(() {
                  method = 'Pay with ZaloPay';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: method == 'Pay with ZaloPay'
                      ? Border.all(color: Palette.primaryColor, width: 2)
                      : Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.payment,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Thanh toán với ZaloPay',
                                style: TextDecor.robo16Medi.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Gap(8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Khuyến nghị',
                                  style: TextDecor.robo11.copyWith(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(4),
                          Text(
                            'Thanh toán nhanh chóng, bảo mật qua ZaloPay',
                            style: TextDecor.robo14.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    if (method == 'Pay with ZaloPay')
                      Icon(
                        Icons.check_circle,
                        color: Palette.primaryColor,
                        size: 24,
                      )
                    else
                      Icon(
                        Icons.circle_outlined,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),

            const Gap(24),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      'Bạn có thể thay đổi phương thức thanh toán bất kỳ lúc nào trước khi xác nhận đơn hàng.',
                      style: TextDecor.robo13Medi.copyWith(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Thêm khoảng trống để tránh che khuất bởi bottomNavigationBar
            const Gap(100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, method),
            style: ElevatedButton.styleFrom(
              backgroundColor: Palette.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Xác nhận',
              style: TextDecor.robo16Medi.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
