import 'package:flutter/material.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/widgets/text.dart';

class GroupList extends StatefulWidget {
  final bool isList;
  final int itemCount;
  final double? itemHeight;
  final String title;
  final Axis listViewAxis;
  final bool isShowOption;
  final Function()? onShowAll;
  final Widget Function(BuildContext context, int index)? buildItem;
  final Widget Function(int index)? builList;

  const GroupList({
    required this.itemCount,
    required this.title,
    this.builList,
    this.buildItem,
    this.isList = false,
    this.itemHeight = 170,
    this.listViewAxis = Axis.horizontal,
    this.isShowOption = true,
    this.onShowAll,
    super.key,
  });

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomText(
                  text: widget.title,
                  type: TextStyleEnum.large,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (widget.isShowOption)
                GestureDetector(
                  onTap: widget.onShowAll != null ? widget.onShowAll! : () {},
                  child: CustomText(
                    text: 'Xem tất cả',
                    style: TextStyle(
                      color: Colors.indigo.shade200,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
          height: (widget.itemHeight),
          child: (widget.isList) ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(widget.itemCount, (index) => widget.builList!(index)).toList(),
            ),
          ) : ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: widget.listViewAxis,
            itemCount: widget.itemCount,
            separatorBuilder: (context, index) => const SizedBox(
              width: 16,
            ),
            itemBuilder: widget.buildItem!,
          ),
        ),
      ],
    );
  }
}
