import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/models/user.dart';
import 'package:quizletapp/services/models_services/user_service.dart';
import 'package:quizletapp/services/providers/current_user_provider.dart';
import '../services/firebase_auth.dart';

import '../enums/text_style_enum.dart';
import '../utils/app_theme.dart';
import '../widgets/text.dart';

class ChangeUserName extends StatefulWidget {
  const ChangeUserName({super.key});

  @override
  State<ChangeUserName> createState() => _ChangeUserNameState();
}

class _ChangeUserNameState extends State<ChangeUserName> {
  FirebaseAuthService auth = FirebaseAuthService();
  var flag = false;
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String newUserName = '';
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: AppTheme.primaryBackgroundColor,
        appBar: AppBar(
          foregroundColor: Colors.white,
          centerTitle: true,
          backgroundColor: AppTheme.primaryBackgroundColor,
          title: CustomText(
            text: "Đổi tên người dùng",
            type: TextStyleEnum.large,
          ),
          actions: [
            TextButton(
                onPressed: flag
                    ? () {
                        setState(() {
                          _save();
                        });
                      }
                    : null,
                child: CustomText(
                  text: "Lưu",
                  type: TextStyleEnum.large,
                  style: TextStyle(
                    color: flag ? Colors.white : Colors.grey,
                  ),
                )),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(25, 35, 25, 0),
          child: Form(
            onChanged: () {
              setState(() {
                check();
              });
            },
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  onChanged: (value) {
                    newUserName = value;
                  },
                  onSaved: (newUserName) {
                    newUserName = newUserName!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Vui lòng nhập tên người dùng của bạn";
                    }
                    if (value.length < 7) {
                      return "Tên người dùng phải có ít nhất 7 ký tự";
                    }
                    if (value.length > 64) {
                      return "Tên người dùng phải ít hơn 64 ký tự";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: CustomText(
                      text: "Nhập tên người dùng mới",
                      style: const TextStyle(color: Colors.white),
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white), // Màu viền khi focus
                    ),
                    focusColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      if (isLoading)
        Container(
          color: Colors.transparent.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
    ]);
  }

  check() {
    formKey.currentState?.setState(() {
      if (newUserName.isNotEmpty) {
        flag = true;
      } else {
        flag = false;
      }
    });
  }

  Future<void> _save() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState?.save();
      try {
        setState(() {
          isLoading = true;
        });
        // Thực hiện xác thực từ Firebase
        var t = await auth.changeUserName(newUserName);
        await context.read<CurrentUserProvider>().changeUserName(newUserName);
        setState(() {
          isLoading = false;
        });
        if (t == '') {
          // hiển thị thông báo đổi mật khẩu thành công
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                icon: const Icon(
                  Icons.check_circle_outline_outlined,
                  color: Colors.green,
                  size: 45,
                ),
                content: CustomText(
                  textAlign: TextAlign.center,
                  text: "Thay đổi tên người dùng thành công",
                  type: TextStyleEnum.large,
                ),
                backgroundColor: AppTheme.primaryBackgroundColor,
              );
            },
          );
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context);
          Navigator.pop(context, newUserName);
        }
      } catch (error) {
        // Xử lý khi có lỗi xác thực từ Firebase
        print('Error signing in: $error');
      }
    }
  }
}
