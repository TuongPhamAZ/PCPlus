import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../interfaces/command.dart';

class ConfirmNoti extends StatefulWidget {
  final String image;
  final String title;
  final String content;
  final DateTime date;
  final bool isView;
  final ICommand onPressed;

  const ConfirmNoti({
    super.key,
    required this.image,
    required this.title,
    required this.content,
    required this.date,
    required this.isView,
    required this.onPressed,
  });

  @override
  State<ConfirmNoti> createState() => _ConfirmNotiState();
}

class _ConfirmNotiState extends State<ConfirmNoti> {
  bool isViewed = false;

  @override
  void initState() {
    isViewed = widget.isView;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            if (!isViewed) {
              widget.onPressed.execute();
              isViewed = true;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isViewed ? Colors.white : Palette.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
              top: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(widget.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Gap(10),
              SizedBox(
                width: size.width - 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextDecor.robo15Medi,
                    ),
                    const Gap(8),
                    Text(
                      widget.content,
                      style: TextDecor.robo15,
                    ),
                    const Gap(8),
                    Text(
                      Utility.formatDetailDateFromDateTime(widget.date),
                      style: TextDecor.robo14.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
