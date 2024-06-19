import 'package:flutter/material.dart';
import 'package:quizletapp/utils/app_theme.dart';

class ButtonActive extends StatefulWidget {
  final bool initValue;
  final Widget? title;
  final String titleText;
  final Icon? icon;
  final IconData? iconData;
  final double? size;
  final Color? colorActive;
  final Color? colorInActive;
  final double? gap;
  final Function(bool state)? onChange;

  const ButtonActive({
    this.initValue = false,
    this.title,
    this.titleText = 'title text',
    this.icon,
    this.iconData = Icons.shuffle,
    this.size = 52,
    this.colorActive = AppTheme.primaryColor,
    this.colorInActive = Colors.black,
    this.gap = 16,
    this.onChange,
    Key? key,
  }) : super(key: key);

  @override
  State<ButtonActive> createState() => _ButtonActiveState();
}

class _ButtonActiveState extends State<ButtonActive> {
  late bool currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initValue;
  }

  void _handleTap() {
    setState(() {
      currentValue = !currentValue;
    });
    if (widget.onChange != null) {
      widget.onChange!(currentValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              color: currentValue ? widget.colorActive : widget.colorInActive,
              shape: BoxShape.circle,
              border: Border.all(width: 1, color: Colors.white),
            ),
            child: widget.icon ??
                Icon(
                  widget.iconData,
                  color: Colors.white,
                  size: 38,
                ),
          ),
          SizedBox(height: widget.gap),
          widget.title ??
              Text(
                widget.titleText,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
        ],
      ),
    );
  }
}
