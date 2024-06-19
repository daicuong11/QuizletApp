import 'package:flutter/material.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/text.dart';

class ItemList extends StatefulWidget {
  final double? width;
  final String headText;
  final String bodyText;
  final Widget? head;
  final Widget? body;
  final Widget? bottom;
  final double? height;
  final BoxDecoration? decoration;
  final Function()? onTap;

  const ItemList({
    this.onTap,
    this.width = 328,
    this.headText = '',
    this.bodyText = '',
    this.head,
    this.body,
    this.bottom,
    this.height,
    this.decoration,
    super.key,
  });

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.all(16),
        width: widget.width,
        height: widget.height,
        decoration: widget.decoration ??
            BoxDecoration(
              color: AppTheme.primaryBackgroundColor,
              border: Border.all(
                color: Colors.grey.withOpacity(0.4),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (widget.head == null)
                    ? CustomText(
                        text: widget.headText,
                        type: TextStyleEnum.large,
                      )
                    : widget.head!,
                (widget.body == null)
                    ? (widget.bodyText.isEmpty)
                        ? const SizedBox()
                        : Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(9999999)),
                            child: CustomText(
                              text: widget.bodyText,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          )
                    : widget.body!,
              ],
            ),
            if (widget.bottom != null) widget.bottom!
          ],
        ),
      ),
    );
  }
}
