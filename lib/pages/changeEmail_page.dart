import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/firebase_auth.dart';

import '../enums/text_style_enum.dart';
import '../utils/app_theme.dart';
import '../widgets/text.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  FirebaseAuthService auth = FirebaseAuthService();
  var flag = false;
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String newEmail = '';
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
            text: "Đổi email",
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
                    newEmail = value;
                  },
                  onSaved: (newEmail) {
                    newEmail = newEmail!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Vui lòng nhập email của bạn";
                    }
                    if (!value.contains('@')) {
                      return "Email không hợp lệ";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: CustomText(
                      text: "Nhập email mới",
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
      if (newEmail.isNotEmpty) {
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
        var t = await auth.changeEmail(newEmail);
        setState(() {
          isLoading = false;
        });
        if (t == '') {
          // hiển thị thông báo đổi email thành công
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                    size: 45,
                  ),
                  title: CustomText(
                    textAlign: TextAlign.center,
                    text:
                        'Chúng tôi đã gửi email đến $newEmail. Vui lòng kiểm tra hòm thư đến của bạn để xác nhận thay đổi email và đăng nhập lại ứng dụng',
                    type: TextStyleEnum.large,
                    style: const TextStyle(color: Colors.black),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        auth.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/intro", (route) => false);
                      },
                      child: Center(
                        child: CustomText(
                          text: 'OK',
                          type: TextStyleEnum.large,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ]);
            },
          );
        } else {
          // hiển thị thông báo đổi email thành công
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  icon: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.blue,
                    size: 45,
                  ),
                  content: CustomText(
                    textAlign: TextAlign.center,
                    text: 'Email không tồn tại. Vui lòng thử lại sau!',
                    type: TextStyleEnum.large,
                  ),
                  backgroundColor: AppTheme.primaryBackgroundColor,
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // Đóng dialog
                      },
                      child: Center(
                        child: CustomText(
                          text: 'OK',
                          type: TextStyleEnum.large,
                        ),
                      ),
                    ),
                  ]);
            },
          );
        }
      } catch (error) {
        // Xử lý khi có lỗi xác thực từ Firebase
        print('Error signing in: $error');
      }
    }
  }
}
