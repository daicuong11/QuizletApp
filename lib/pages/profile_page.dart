import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/services/providers/current_user_provider.dart';
import '../enums/text_style_enum.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';
import '../widgets/text.dart';

import '../services/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseAuthService auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppTheme.primaryBackgroundColor,
        title: Center(
          child: CustomText(
            text: 'Tài khoản của bạn',
            type: TextStyleEnum.large,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    child: CircleAvatar(
                      backgroundImage: AppTheme.defaultAvatar,
                      radius: 45,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  CustomText(
                    text: context.watch<CurrentUserProvider>().currentUser?.username ?? '',
                    type: TextStyleEnum.large,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/settings");
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(20.0)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.settings,
                    size: 32.0,
                  ),
                  const SizedBox(width: 10.0),
                  CustomText(
                    text: "Cài đặt của bạn",
                    type: TextStyleEnum.large,
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.white,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
