import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/user.dart';
import 'package:quizletapp/services/providers/current_user_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/text.dart';

import '../services/firebase_auth.dart';
import '../widgets/elevatedButton.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  FirebaseAuthService auth = FirebaseAuthService();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: AppTheme.primaryBackgroundColor,
        title: CustomText(
          text: "Cài đặt",
          type: TextStyleEnum.large,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                child: CustomText(
                  text: "Thông tin cá nhân",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              decoration: createBoxDecoration(),
              child: Column(
                children: [
                  createInkWell(context.watch<CurrentUserProvider>().currentUser?.username ?? '', "Tên người dùng", () {
                    Navigator.pushNamed(context, "/changeUserName");
                  }),
                  const Divider(thickness: 1.0),
                  createInkWell(context.watch<CurrentUserProvider>().currentUser?.email ?? '', "Email", () {
                    // thực hiện show bottom sheet check password rồi mới đổi email
                    if (auth.getIsSignInGG()) {
                      showNotAllowAction();
                    } else {
                      showPasswordCheckBottomSheet(context);
                    }
                  }),
                  const Divider(thickness: 1.0),
                  createInkWell('', "Đổi mật khẩu", () {
                    if (auth.getIsSignInGG()) {
                      showNotAllowAction();
                    } else {
                      Navigator.pushNamed(context, "/changePassword");
                    }
                  }),
                ],
              ),
            ),
            const Expanded(child: SizedBox(height: 1)),
            createElevatedButton("Đăng xuất", () async {
              showConfirmDialog(context, "đăng xuất", () async {
                try {
                  // Đăng xuất khỏi Firebase Authentication
                  await auth.signOut();
                  context.read<CurrentUserProvider>().setCurrentUser = null;
                  Navigator.pushNamedAndRemoveUntil(context, '/intro',
                      (route) => route.settings.name == '/intro');
                } catch (error) {}
              });
            }),
            // const SizedBox(height: 20),
            // createElevatedButton(
            //     "Xóa tài khoản",
            //     () => {
            //           showConfirmDialog(context, "xóa tài khoản", () async {
            //             try {
            //               await auth.deleteAccount();
            //               Navigator.pushNamedAndRemoveUntil(
            //                   context,
            //                   '/intro',
            //                   (route) => route.settings.name == '/intro');
            //             } catch (e) {}
            //           })
            //         })
          ],
        ),
      ),
    );
  }

  createElevatedButton(String text, Function()? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: CustomText(
            text: text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  createInkWell(String text, String info, void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.white.withOpacity(0),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          children: [
            createCheckText(text, info),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  createCheckText(String text, String info) {
    if (text.isEmpty) {
      return CustomText(
        text: info,
        type: TextStyleEnum.large,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: info,
          type: TextStyleEnum.large,
        ),
        const SizedBox(height: 5),
        CustomText(
          text: text,
          style: const TextStyle(fontSize: 15.0),
        ),
      ],
    );
  }

  void checkPassword(void Function(void Function()) setStateBottomSheet) async {
    try {
      String password = passwordController.text;
      setStateBottomSheet(() {
        isLoading = true;
      });
      bool isCorrect = await auth.checkPassword(password);
      setStateBottomSheet(() {
        isLoading = false;
      });
      if (isCorrect) {
        Navigator.pushReplacementNamed(context, "/changeEmail");
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              icon: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 45,
              ),
              title: CustomText(
                text: 'Mật khẩu sai. Vui lòng thử lại',
                type: TextStyleEnum.large,
                style: const TextStyle(color: Colors.black),
              ),
            );
          },
        );
        await Future.delayed(const Duration(seconds: 2));
      }
      passwordController.clear();
    } catch (e) {}
  }

  showPasswordCheckBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: AppTheme.primaryBackgroundColor,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Stack(children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        text: "Vui lòng xác minh tài khoản của bạn",
                        type: TextStyleEnum.xl,
                      ),
                      const SizedBox(height: 15),
                      CustomText(
                        text:
                            "Để xác thực đây là bạn, vui lòng xác minh mật khẩu Quizlet của bạn.",
                        type: TextStyleEnum.large,
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        onSubmitted: (value) {
                          checkPassword(setStateBottomSheet);
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          label: CustomText(
                            text: "Vui lòng nhập mật khẩu của bạn",
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white), // Màu viền khi focus
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      CustomElevatedButton(
                        onPressed: () {
                          checkPassword(setStateBottomSheet);
                        },
                        text: 'Gửi',
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          fixedSize: const MaterialStatePropertyAll(
                              Size(double.maxFinite, 50.0)),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          )),
                        ),
                        child: CustomText(
                          text: "Hủy",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
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
        });
      },
    );
  }

  createBoxDecoration() {
    return BoxDecoration(
        border: Border.all(width: 1.0, color: Colors.grey),
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.elliptical(10, 10)));
  }

  showConfirmDialog(BuildContext context, String text, Function() onPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: 'Thông báo',
            type: TextStyleEnum.xl,
          ),
          content: CustomText(
            text: 'Bạn có chắc chắn muốn $text?',
          ),
          backgroundColor: AppTheme.primaryBackgroundColor,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
              },
              child: CustomText(
                text: 'Không',
                type: TextStyleEnum.large,
              ),
            ),
            TextButton(
              onPressed: onPressed,
              child: CustomText(
                text: 'Có',
                type: TextStyleEnum.large,
              ),
            ),
          ],
        );
      },
    );
  }

  showNotAllowAction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: "Thông báo",
            type: TextStyleEnum.xl,
          ),
          content: CustomText(
            text:
                'Bạn đang đăng nhập bằng tài khoản Google nên không thể thực hiện chức năng này!',
          ),
          backgroundColor: AppTheme.primaryBackgroundColor,
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white)),
                  child: CustomText(
                    text: "Ok",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  )),
            ),
          ],
        );
      },
    );
  }
}
