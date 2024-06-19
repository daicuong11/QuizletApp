import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quizletapp/utils/app_theme.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final double height;
  final double width;
  final TextStyle textStyle;
  final String text;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    this.backgroundColor = AppTheme.primaryColor,
    this.height = 50.0,
    this.width = double.maxFinite,
    this.textStyle = const TextStyle(
        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
    required this.text,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        alignment: Alignment.center,
        fixedSize: MaterialStatePropertyAll(Size(width, height)),
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        )),
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
