import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quizletapp/utils/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});
  //tạo appbar cho page login, register
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: true,
      backgroundColor: AppTheme.primaryBackgroundColorAppbar,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
