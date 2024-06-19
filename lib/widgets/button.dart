import 'package:flutter/material.dart';
import 'package:quizletapp/utils/app_theme.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final TextStyle? textStyle;
  final String text;
  Widget? iconLeft;
  Widget? iconRight;
  bool? disable;

  CustomButton({
    Key? key,
    this.onTap,
    this.backgroundColor = AppTheme.primaryColor,
    this.height = 50.0,
    this.width = double.infinity,
    this.iconLeft,
    this.iconRight,
    this.disable,
    this.textStyle = const TextStyle(
        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: (disable == true)? Colors.grey.withOpacity(0.6) : backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconLeft != null) iconLeft!,
            const SizedBox(
              width: 8,
            ),
            Text(
              text,
              style: textStyle,
            ),
            const SizedBox(
              width: 8,
            ),
            if (iconRight != null) iconRight!,
          ],
        ),
      ),
    );
  }
}
