import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quizletapp/models/card.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/text.dart';

class GroupFieldCard extends StatefulWidget {
  final int itemIndex;
  final FocusNode? termFieldFocus = FocusNode();
  final FocusNode? defineFieldFocus = FocusNode();
  CardModel cardModel;

  GroupFieldCard({
    required this.itemIndex,
    required this.cardModel,
    super.key,
  });


  @override
  State<GroupFieldCard> createState() => _GroupFieldCardState();
}

class _GroupFieldCardState extends State<GroupFieldCard> {
  late TextEditingController termInputController;
  late TextEditingController defineInputController;

  @override
  void initState() {
    termInputController = TextEditingController(text: widget.cardModel.term);
    defineInputController =
        TextEditingController(text: widget.cardModel.define);

    print(
        'Card: index= ${widget.itemIndex}, cardModel: ${widget.cardModel.term + widget.cardModel.define}');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: (widget.itemIndex != 0) ? const EdgeInsets.only(top: 8) : null,
      padding: const EdgeInsets.all(12),
      color: AppTheme.primaryBackgroundColorAppbar,
      child: Column(
        children: [
          Wrap(
            children: [
              CupertinoTextField(
                controller: termInputController,
                focusNode: widget.termFieldFocus,
                onChanged: (value) {
                  widget.cardModel.term = value ?? '';
                },
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                cursorColor: Colors.white,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.8),
                      width: 2.0,
                    ),
                  ),
                ),
                placeholderStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                alignment: Alignment.centerLeft,
                child: CustomText(
                  text: 'Thuật ngữ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            children: [
              CupertinoTextField(
                controller: defineInputController,
                focusNode: widget.defineFieldFocus,
                onChanged: (value) {
                  widget.cardModel.define = value ?? '';
                },
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                cursorColor: Colors.white,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.8),
                      width: 2.0,
                    ),
                  ),
                ),
                placeholderStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                alignment: Alignment.centerLeft,
                child: CustomText(
                  text: 'Định nghĩa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
