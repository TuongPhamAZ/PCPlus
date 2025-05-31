import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pcplus/themes/text_decor.dart';

class ReviewItem extends StatefulWidget {
  final double? rating;
  final String name;
  final DateTime date;
  final String comment;
  final String? avatarUrl;
  final String? response; // Phản hồi từ seller (nếu có)
  final bool isShop; // Có phải shop owner không
  final Function(String)? onResponseSubmit; // Callback khi submit phản hồi

  const ReviewItem({
    super.key,
    required this.name,
    required this.date,
    required this.comment,
    this.avatarUrl,
    this.rating,
    this.response,
    this.isShop = false,
    this.onResponseSubmit,
  });

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  double rating = 3.5;
  bool _showResponseInput = false;
  final TextEditingController _responseController = TextEditingController();

  @override
  void initState() {
    rating = widget.rating ?? 3.5;
    super.initState();
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                        ? NetworkImage(widget.avatarUrl!)
                        : null,
                child: widget.avatarUrl == null || widget.avatarUrl!.isEmpty
                    ? Text(
                        widget.name[0].toUpperCase(),
                        style: TextDecor.robo16Semi.copyWith(
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextDecor.robo16Semi.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RatingBar.builder(
                      initialRating: rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 16,
                      unratedColor: const Color(0xffDADADA),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) {},
                      ignoreGestures: true,
                    ),
                  ],
                ),
              ),
              Text(
                "${widget.date.day}/${widget.date.month}/${widget.date.year}",
                style: TextDecor.robo12.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          // Comment section
          const SizedBox(height: 12),
          Text(
            widget.comment,
            style: TextDecor.robo14.copyWith(
              height: 1.4,
            ),
          ),

          // Seller response (nếu có)
          if (widget.response != null && widget.response!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Phản hồi từ người bán:",
                        style: TextDecor.robo12.copyWith(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.response!,
                    style: TextDecor.robo14.copyWith(
                      color: Colors.blue.shade700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Shop owner response input (chỉ hiển thị khi isShop = true và chưa có response)
          if (widget.isShop &&
              (widget.response == null || widget.response!.isEmpty)) ...[
            const SizedBox(height: 12),
            if (!_showResponseInput) ...[
              // Nút "Phản hồi"
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showResponseInput = true;
                    });
                  },
                  icon: Icon(
                    Icons.reply,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  label: Text(
                    'Phản hồi',
                    style: TextDecor.robo14.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Input box và buttons
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Phản hồi của bạn:",
                          style: TextDecor.robo12.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _responseController,
                      onTapOutside: (value) {
                        FocusScope.of(context).unfocus();
                      },
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Nhập phản hồi của bạn...',
                        hintStyle: TextDecor.robo14.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade300),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextDecor.robo14,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Nút Hủy
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showResponseInput = false;
                              _responseController.clear();
                            });
                          },
                          child: Text(
                            'Hủy',
                            style: TextDecor.robo14.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Nút Phản hồi
                        ElevatedButton(
                          onPressed: () {
                            if (_responseController.text.trim().isNotEmpty) {
                              // Gọi callback để submit phản hồi
                              widget.onResponseSubmit
                                  ?.call(_responseController.text.trim());
                              setState(() {
                                _showResponseInput = false;
                                _responseController.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Phản hồi',
                            style: TextDecor.robo14.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
