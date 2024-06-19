import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/pages/topic_detail_page.dart';
import 'package:quizletapp/services/firebase_auth.dart';
import 'package:quizletapp/services/providers/current_user_provider.dart';
import 'package:quizletapp/services/providers/folder_provider.dart';
import 'package:quizletapp/services/providers/index_of_app_provider.dart';
import 'package:quizletapp/services/providers/index_of_library_provider.dart';
import 'package:quizletapp/services/providers/topic_provider.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/button_listtile.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:quizletapp/widgets/group_list.dart';
import 'package:quizletapp/widgets/item_list.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TopicService topicService = TopicService();
  FirebaseAuthService firebaseAuthService = FirebaseAuthService();
  bool isInit = false;
  bool isLoading = false;
  final TextEditingController _textEditingController = TextEditingController();

  // List<TopicModel> myTopics = [];

  List<TopicModel> listTopicOfUser = [];

  var listTopicToFind = [
    {
      'label': 'Nghệ thuật và nhân văn',
      'icon': const Icon(
        Icons.edit_calendar,
        color: Colors.red,
        size: 40,
      ),
    },
    {
      'label': 'Ngôn ngữ',
      'icon': const Icon(
        FontAwesomeIcons.globe,
        color: Colors.purple,
        size: 40,
      ),
    },
    {
      'label': 'Toán học',
      'icon': const Icon(
        Icons.calculate_sharp,
        color: Colors.yellow,
        size: 40,
      ),
    },
  ];

  @override
  void initState() {
    _fetchInitTopicsAndFoldersOfCurrentUser();
    super.initState();
  }

  Future<void> _fetchInitTopicsAndFoldersOfCurrentUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      await context.read<TopicProvider>().reloadListTopic();
      await context.read<FolderProvider>().reloadListFolderOfCurrentUser();
    } catch (e) {
      print('Lỗi lấy danh sách chủ đề: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  // Future<void> _onRefresh() async {
  //   await _fetchInitTopicsAndFoldersOfCurrentUser();
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer5<CurrentUserProvider, TopicProvider, FolderProvider,
        IndexOfAppProvider, IndexOfLibraryProvider>(
      builder: (context, currentUserProvider, topicProvider, folderProvider,
          indexOfAppProvider, indexOfLibraryProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.primaryBackgroundColor,
          appBar: AppBar(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(52),
                bottomRight: Radius.circular(52),
              ),
            ),
            title: CustomText(
              text: 'Quizlet',
              type: TextStyleEnum.xl,
            ),
            //không hiển thị leadding
            automaticallyImplyLeading: false,
            foregroundColor: Colors.white,
            backgroundColor: AppTheme.primaryBackgroundColorAppbar,
            actions: [
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(
                      AppTheme.primaryButtonColor),
                ),
                onPressed: () {
                  toastification.show(
                    context: context,
                    title: CustomText(
                      text:
                          'Tính năng đang được bảo trì.\n Xin lỗi vì sự bất tiện này.',
                      type: TextStyleEnum.large,
                    ),
                    style: ToastificationStyle.fillColored,
                    foregroundColor: Colors.white,
                    showProgressBar: false,
                    type: ToastificationType.warning,
                    autoCloseDuration: const Duration(seconds: 3),
                  );
                },
                child: CustomText(
                  text: 'Nâng cấp',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              if (topicProvider.listTopicOfCurrentUser.isNotEmpty)
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        toastification.show(
                          context: context,
                          title: CustomText(
                            text:
                                'Tính năng đang được bảo trì.\n Xin lỗi vì sự bất tiện này.',
                            type: TextStyleEnum.large,
                          ),
                          style: ToastificationStyle.fillColored,
                          foregroundColor: Colors.white,
                          showProgressBar: false,
                          type: ToastificationType.warning,
                          autoCloseDuration: const Duration(seconds: 3),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        size: 32,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: CustomText(
                          text: '2',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                width: 8,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                margin: const EdgeInsets.only(bottom: 18),
                child: TextField(
                  controller: _textEditingController,
                  onSubmitted: (value) {
                    if (value.trim().isEmpty) return;
                    Navigator.pushNamed(context, '/search-topic', arguments: {
                      'code': 0,
                      'key': _textEditingController.text
                    });
                    _textEditingController.clear();
                  },
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Học phần, sách giáo khoa, câu hỏi',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9999),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 12),
                      child: const Icon(Icons.search),
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: const Icon(Icons.camera_alt_outlined),
                    ),
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: _fetchInitTopicsAndFoldersOfCurrentUser,
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                margin: const EdgeInsets.only(top: 32),
                child: (topicProvider.listTopicOfCurrentUser.isNotEmpty ||
                        folderProvider.listFolderOfCurrentUser.isNotEmpty)
                    ? Column(
                        children: [
                          if (topicProvider.listTopicOfCurrentUser.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 32),
                              child: Skeletonizer(
                                containersColor:
                                    AppTheme.primaryColorSkeletonContainer,
                                enabled: isLoading,
                                child: GroupList(
                                  itemCount: topicProvider
                                      .listTopicOfCurrentUser.length,
                                  title: 'Các học phần',
                                  onShowAll: () {
                                    indexOfLibraryProvider.changeIndex(0);
                                    indexOfAppProvider.changeIndex(3);
                                  },
                                  buildItem: (context, index) {
                                    return ItemList(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TopicDetailPage(
                                              topicId: topicProvider
                                                  .listTopicOfCurrentUser[index]
                                                  .id,
                                            ),
                                          ),
                                        );
                                      },
                                      headText: topicProvider
                                          .listTopicOfCurrentUser[index].title,
                                      bodyText:
                                          '${topicProvider.listTopicOfCurrentUser[index].listCard.length} thuật ngữ',
                                      bottom: Row(
                                        children: [
                                          const CircleAvatar(
                                            backgroundImage:
                                                AppTheme.defaultAvatar,
                                            radius: 14,
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          CustomText(
                                              text: topicProvider
                                                      .listTopicOfCurrentUser[
                                                          index]
                                                      .userCreate
                                                      ?.username ??
                                                  ''),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          if (listTopicOfUser.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 32),
                              child: Skeletonizer(
                                enabled: isLoading,
                                containersColor:
                                    AppTheme.primaryColorSkeletonContainer,
                                child: GroupList(
                                  itemCount: listTopicOfUser.length,
                                  title:
                                      'Tương tự học phần của ${listTopicOfUser[0].userCreate?.username ?? ''}',
                                  isShowOption: false,
                                  buildItem: (context, index) {
                                    return ItemList(
                                      headText: listTopicOfUser[index].title,
                                      bodyText:
                                          '${listTopicOfUser[index].listCard.length} thuật ngữ',
                                      bottom: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                radius: 14,
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              CustomText(
                                                  text: listTopicOfUser[index]
                                                          .userCreate
                                                          ?.username ??
                                                      '')
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              print(index.toString());
                                            },
                                            icon: const Icon(
                                              Icons.more_vert,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          if (folderProvider.listFolderOfCurrentUser.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 32),
                              child: Skeletonizer(
                                enabled: isLoading,
                                containersColor:
                                    AppTheme.primaryColorSkeletonContainer,
                                child: GroupList(
                                  itemCount: folderProvider
                                      .listFolderOfCurrentUser.length,
                                  title: 'Thư mục',
                                  itemHeight: 108,
                                  onShowAll: () {
                                    indexOfLibraryProvider.changeIndex(1);
                                    indexOfAppProvider.changeIndex(3);
                                  },
                                  buildItem: (context, index) {
                                    return ItemList(
                                      height: null,
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/folder/detail',
                                            arguments: folderProvider
                                                .listFolderOfCurrentUser[index]
                                                .id);
                                      },
                                      head: Row(
                                        children: [
                                          Icon(
                                            Icons.folder_outlined,
                                            color: Colors.grey.withOpacity(0.6),
                                            size: 28,
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Expanded(
                                            child: CustomText(
                                              text: folderProvider
                                                  .listFolderOfCurrentUser[
                                                      index]
                                                  .title
                                                  .replaceAll('\n', ' ')
                                                  .replaceAll('\r', ' '),
                                              type: TextStyleEnum.large,
                                              style: const TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      body: Container(
                                        margin: const EdgeInsets.only(top: 12),
                                        child: Row(
                                          children: [
                                            CustomText(
                                                text:
                                                    '${folderProvider.listFolderOfCurrentUser[index].listTopic.length} học phần'),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              color: Colors.grey.shade600
                                                  .withOpacity(0.5),
                                              width: 1,
                                              height: 18,
                                            ),
                                            const CircleAvatar(
                                              backgroundImage:
                                                  AppTheme.defaultAvatar,
                                              backgroundColor: Colors.grey,
                                              radius: 14,
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            CustomText(
                                                text: firebaseAuthService
                                                        .getCurrentUser()
                                                        ?.displayName ??
                                                    '')
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          if (topicProvider.listTopicOfCurrentUser.isNotEmpty &&
                              folderProvider.listFolderOfCurrentUser.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 32),
                              alignment: Alignment.center,
                              child: GestureDetector(
                                  onTap: () {
                                    print('Xem chính sách quyền riêng tư');
                                  },
                                  child: CustomText(
                                    text: 'Chính sách quyền riêng tư',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  )),
                            ),
                        ],
                      )
                    : Skeletonizer(
                        enabled: isLoading,
                        containersColor: AppTheme.primaryColorSkeletonContainer,
                        child: Column(
                          children: [
                            GroupList(
                              itemHeight: null,
                              isList: true,
                              itemCount: 1,
                              title: 'Đây là cách để bắt đầu',
                              isShowOption: false,
                              builList: (index) {
                                return Column(
                                  children: [
                                    if (index != 0)
                                      const SizedBox(
                                        height: 16,
                                      ),
                                    ButtonListTile(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/topic/create');
                                      },
                                      title: CustomText(
                                        text: 'Tạo thẻ ghi nhớ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      icon: const Icon(
                                        Icons.library_add_sharp,
                                        color: Colors.blue,
                                        size: 40,
                                      ),
                                      boxDecoration: BoxDecoration(
                                        color: AppTheme.primaryBackgroundColor,
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 4),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            GroupList(
                              itemHeight: null,
                              isList: true,
                              itemCount: 3,
                              title: 'Duyệt tìm theo chủ đề',
                              isShowOption: false,
                              builList: (index) {
                                return Column(
                                  children: [
                                    if (index != 0)
                                      const SizedBox(
                                        height: 16,
                                      ),
                                    ButtonListTile(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/search-topic',
                                            arguments: {
                                              'code': index,
                                              'key': listTopicToFind[index]
                                                  ['label']
                                            });
                                      },
                                      title: CustomText(
                                        text: listTopicToFind[index]['label']
                                            .toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      icon: listTopicToFind[index]['icon']
                                          as Icon,
                                      boxDecoration: BoxDecoration(
                                        color: AppTheme.primaryBackgroundColor,
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 4),
                                    ),
                                  ],
                                );
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 32),
                              alignment: Alignment.center,
                              child: GestureDetector(
                                  onTap: () {
                                    print('Xem chính sách quyền riêng tư');
                                  },
                                  child: CustomText(
                                    text: 'Chính sách quyền riêng tư',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  )),
                            )
                          ],
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
