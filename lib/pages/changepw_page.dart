import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/firebase_auth.dart';

import '../enums/text_style_enum.dart';
import '../utils/app_theme.dart';
import '../widgets/text.dart';

class ChangePassWord extends StatefulWidget {
  const ChangePassWord({super.key});

  @override
  State<ChangePassWord> createState() => _ChangePassWordState();
}

class _ChangePassWordState extends State<ChangePassWord> {
  FirebaseAuthService auth = FirebaseAuthService();
  var flag = false;
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String currentPassword = '';
  String newPassWord = '';
  String confirmPassWord = '';
  String? errorMessage;
  String? errorCfMessage;
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
            text: "Đổi mật khẩu",
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
                  textInputAction: TextInputAction.next,
                  onSaved: (currentPassword) {
                    currentPassword = currentPassword!;
                  },
                  onChanged: (value) {
                    currentPassword = value;
                  },
                  decoration: InputDecoration(
                    label: CustomText(
                      text: "Nhập mật khẩu hiện tại",
                      style: const TextStyle(color: Colors.white),
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white), // Màu viền khi focus
                    ),
                    focusColor: Colors.white,
                    errorText: errorMessage,
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  onSaved: (newPassWord) {
                    newPassWord = newPassWord!;
                  },
                  onChanged: (value) {
                    newPassWord = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Vui lòng nhập mật khẩu";
                    }
                    // Kiểm tra độ dài mật khẩu
                    if (value.length < 7) {
                      return "Mật khẩu phải có ít nhất 7 ký tự";
                    }
                    if (value.length > 64) {
                      return "Mật khẩu phải ít hơn 64 ký tự";
                    }
                    // Kiểm tra xem mật khẩu có chứa ít nhất một ký tự hoa không
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return "Mật khẩu phải chứa ít nhất một ký tự hoa";
                    }
                    // Kiểm tra xem mật khẩu có chứa ít nhất một ký tự thường không
                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return "Mật khẩu phải chứa ít nhất một ký tự thường";
                    }
                    // Kiểm tra xem mật khẩu có chứa ít nhất một ký tự đặc biệt không
                    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                      return "Mật khẩu phải chứa ít nhất một ký tự đặc biệt";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: CustomText(
                      text: "Nhập mật khẩu mới",
                      style: const TextStyle(color: Colors.white),
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white), // Màu viền khi focus
                    ),
                    focusColor: Colors.white,
                    errorText: errorCfMessage,
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  onSaved: (cfNewPassWord) {
                    confirmPassWord = cfNewPassWord!;
                  },
                  onChanged: (value) {
                    confirmPassWord = value;
                  },
                  decoration: InputDecoration(
                    label: CustomText(
                      text: "Xác nhận mật khẩu mới",
                      style: const TextStyle(color: Colors.white),
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white), // Màu viền khi focus
                    ),
                    errorText: errorCfMessage,
                    focusColor: Colors.white,
                  ),
                  obscureText: true,
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
      if (newPassWord.isNotEmpty &&
          currentPassword.isNotEmpty &&
          confirmPassWord.isNotEmpty) {
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
        if (newPassWord == confirmPassWord) {
          setState(() {
            isLoading = true;
          });

          // Thực hiện xác thực từ Firebase
          errorMessage =
              await auth.changePassword(currentPassword, newPassWord);
          setState(() {
            isLoading = false;
          });

          // Nếu xác thực thành công, thực hiện chuyển hướng đến app page
          if (errorMessage == null || errorMessage!.isEmpty) {
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
                    text: 'Đổi mật khẩu thành công',
                    type: TextStyleEnum.large,
                  ),
                  backgroundColor: AppTheme.primaryBackgroundColor,
                );
              },
            );

            await Future.delayed(const Duration(seconds: 2));
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pop(context);
          } else {
            setState(() {
              // Hiển thị lỗi
              errorMessage = errorMessage;
            });
          }
        } else {
          errorCfMessage = "Mật khẩu ở cả hai trường phải khớp nhau";
        }
      } catch (error) {
        // Xử lý khi có lỗi xác thực từ Firebase
        print('Error signing in: $error');
      }
    }
  }
}
