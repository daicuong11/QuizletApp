import 'package:flutter/material.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/text.dart';

class MultifunctionPage extends StatefulWidget {
  const MultifunctionPage({super.key});

  @override
  State<MultifunctionPage> createState() => _MultifunctionPageState();
}

class _MultifunctionPageState extends State<MultifunctionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackgroundColor,
        title: Center(
          child: CustomText(
            text: 'Thêm',
            type: TextStyleEnum.large,
          ),
        ),
      ),
      body: Center(
        child: CustomText(
          text: 'Multifunction page',
        ),
      ),
    );
  }
}
