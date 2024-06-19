import 'package:flutter/material.dart';

class ButtonListTile extends StatelessWidget {
  final Widget? title;
  final Icon? icon;
  final Icon? iconRight;
  final double borderRadius;
  final BoxDecoration? boxDecoration;
  final EdgeInsets? padding;
  final Alignment? alignment;
  final Function()? onTap;
  ButtonListTile({
    this.title,
    this.icon,
    this.iconRight,
    this.boxDecoration,
    this.padding,
    this.borderRadius = 16,
    this.alignment,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        alignment: alignment,
        decoration: (boxDecoration == null)
            ? BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
                color: const Color.fromARGB(159, 108, 123, 132).withOpacity(0.5),
              )
            : boxDecoration,
        child: ListTile(
          leading: icon,
          title: title,
          trailing: iconRight,
        ),
      ),
    );
  }
}
