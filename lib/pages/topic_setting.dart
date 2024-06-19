import 'package:flutter/material.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopicSettingPage extends StatefulWidget {
  bool isPublic;
  TopicSettingPage({
    required this.isPublic,
    Key? key,
  }) : super(key: key);

  @override
  State<TopicSettingPage> createState() => _TopicSettingPageState();
}

class _TopicSettingPageState extends State<TopicSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: AppTheme.primaryBackgroundColor,
        title: CustomText(
          text: 'Cài đặt',
          type: TextStyleEnum.large,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              var prefs = await SharedPreferences.getInstance();

              await prefs.setBool('isPublic', widget.isPublic);
              Navigator.pop(context);
            },
            child: CustomText(
              text: 'Lưu',
              type: TextStyleEnum.large,
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 32,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 24),
              alignment: Alignment.centerLeft,
              child: CustomText(
                text: 'Quyền riêng tư',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade300.withOpacity(0.9)),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
              ),
              color: AppTheme.primaryBackgroundColorAppbar,
              child: ListTile(
                title: CustomText(text: 'Công khai học phần này'),
                trailing: Switch(
                  value: widget.isPublic,
                  onChanged: (value) {
                    setState(() {
                      widget.isPublic = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
