import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/pages/home_page.dart';
import 'package:quizletapp/pages/library_page.dart';
import 'package:quizletapp/pages/multifunction_page.dart';
import 'package:quizletapp/pages/profile_page.dart';
import 'package:quizletapp/pages/forum_page.dart';
import 'package:quizletapp/services/firebase.dart';
import 'package:quizletapp/services/firebase_auth.dart';
import 'package:quizletapp/services/providers/index_of_app_provider.dart';
import 'package:quizletapp/services/providers/index_of_library_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/button_listtile.dart';
import 'package:quizletapp/widgets/text.dart';

class AppPage extends StatefulWidget {
  const AppPage({
    super.key,
  });

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  FirebaseAuthService firebaseAuthService = FirebaseAuthService();
  FirebaseService firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return Consumer<IndexOfAppProvider>(
      builder: (context, indexOfAppProvider, child) {
        return Scaffold(
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
                border: Border(
              top: BorderSide(color: Colors.grey, width: 0.3),
            )),
            child: BottomNavigationBar(
              onTap: (value) {
                if (value == 2) {
                  showModalBottomSheet(
                    backgroundColor: const Color.fromARGB(255, 44, 63, 79),
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(160, 127, 144, 155),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            ButtonListTile(
                              title: CustomText(
                                text: 'Học phần',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                              icon: const Icon(
                                Icons.filter,
                                color: Colors.white,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/topic/create');
                              },
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            ButtonListTile(
                              title: CustomText(
                                text: 'Thư mục',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                              icon: const Icon(
                                Icons.folder_outlined,
                                color: Colors.white,
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                var result = await Navigator.pushNamed(
                                    context, '/folder/create');
                                if (result == 201) {
                                  //xữ lý ở trang này nếu thêm topic thành công
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  setState(() {
                    indexOfAppProvider.changeIndex(value);
                  });
                }
              },
              currentIndex: indexOfAppProvider.indexSelected,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppTheme.primaryBackgroundColor,
              unselectedItemColor: Colors.grey.shade600,
              selectedItemColor: Colors.white,
              elevation: 10,
              iconSize: 36,
              items: const [
                BottomNavigationBarItem(
                  label: 'Trang chủ',
                  icon: Icon(Icons.search_rounded),
                ),
                BottomNavigationBarItem(
                  label: 'Diễn đàn',
                  icon: Icon(Icons.my_library_books_outlined),
                ),
                BottomNavigationBarItem(
                  label: '',
                  icon: Icon(Icons.add_circle_outline_rounded),
                ),
                BottomNavigationBarItem(
                  label: 'Thư viện',
                  icon: Icon(Icons.folder_copy_outlined),
                ),
                BottomNavigationBarItem(
                  label: 'Hồ sơ',
                  icon: Icon(Icons.supervised_user_circle_outlined),
                ),
              ],
            ),
          ),
          body: IndexedStack(
            index: indexOfAppProvider.indexSelected,
            children: [
              const HomePage(),
              const ForumPage(),
              const MultifunctionPage(),
              LibraryPage(),
              const ProfilePage(),
            ],
          ),
        );
      },
    );
  }
}
