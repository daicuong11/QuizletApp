import 'package:flutter/material.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/models/user.dart';
import 'package:quizletapp/pages/topic_detail_page.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';
import 'package:quizletapp/services/models_services/user_service.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/group_list.dart';
import 'package:quizletapp/widgets/item_list.dart';
import 'package:quizletapp/widgets/loading.dart';
import 'package:quizletapp/widgets/text.dart';

class SearchTopicPage extends StatefulWidget {
  final Map<String, dynamic> keyWord;

  SearchTopicPage({
    required this.keyWord,
    super.key,
  });

  @override
  State<SearchTopicPage> createState() => _SearchTopicPageState();
}

class _SearchTopicPageState extends State<SearchTopicPage>
    with SingleTickerProviderStateMixin {
  TopicService topicService = TopicService();
  UserService userService = UserService();

  late final TabController _tabController;

  List listTopicToFind = ['Nghệ thuật và nhân văn', 'Ngôn ngữ', 'Toán học'];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<TopicModel>> fetchAllTopicByKeyword() {
    return topicService.searchTopics(widget.keyWord['key']);
  }

  Future<List<Map<String, dynamic>>> fetchAllUserByKeyword() {
    return userService.searchUsers(widget.keyWord['key']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 32),
        automaticallyImplyLeading: true,
        backgroundColor: AppTheme.primaryBackgroundColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: widget.keyWord['key'].toString(),
                  type: TextStyleEnum.xxl,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorWeight: 3,
                  dividerHeight: 3,
                  overlayColor: const MaterialStatePropertyAll(
                      AppTheme.primaryBackgroundColor),
                  dividerColor: Colors.grey.shade600.withOpacity(0.5),
                  indicatorColor: Colors.deepPurpleAccent.shade100,
                  unselectedLabelColor: Colors.grey,
                  labelColor: Colors.white,
                  labelStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.only(right: 32),
                  tabs: const [
                    Tab(
                      text: 'Tất cả',
                    ),
                    Tab(
                      text: 'Học phần',
                    ),
                    Tab(
                      text: 'Người dùng',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder(
            future: fetchAllTopicByKeyword(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: CustomText(
                    text: 'Lỗi truy vấn dữ liệu.',
                    type: TextStyleEnum.large,
                  ),
                );
              } else if (snapshot.hasData) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (snapshot.data!.isNotEmpty)
                          GroupList(
                            itemHeight: null,
                            isList: true,
                            itemCount: snapshot.data!.length,
                            title: 'Học phần',
                            isShowOption: false,
                            builList: (index) {
                              TopicModel currentTopic = snapshot.data![index];
                              return Column(
                                children: [
                                  if (index != 0)
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  ItemList(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TopicDetailPage(
                                            topicId: currentTopic.id,
                                          ),
                                        ),
                                      );
                                    },
                                    width: null,
                                    height: 180,
                                    headText: currentTopic.title,
                                    bodyText:
                                        '${currentTopic.listCard.length} thuật ngữ',
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
                                            text: currentTopic
                                                .userCreate!.username)
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        FutureBuilder(
                          future: fetchAllUserByKeyword(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.hasError) {
                              return Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: CustomText(
                                  text: 'Lỗi truy vấn dữ liệu.',
                                  type: TextStyleEnum.large,
                                ),
                              );
                            } else if (userSnapshot.hasData &&
                                userSnapshot.data!.isEmpty) {
                              if (snapshot.data!.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 200,
                                  ),
                                  alignment: Alignment.center,
                                  child: CustomText(
                                    text: 'Không có kết quả tìm kiếm.',
                                    type: TextStyleEnum.large,
                                  ),
                                );
                              }
                              return Container();
                            } else if (userSnapshot.hasData) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 32),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      (userSnapshot.data!.isEmpty)
                                          ? Container()
                                          : GroupList(
                                              itemHeight: null,
                                              isList: true,
                                              itemCount:
                                                  userSnapshot.data!.length,
                                              title: 'Người dùng',
                                              isShowOption: false,
                                              builList: (index) {
                                                int currentCountTopic =
                                                    userSnapshot.data![index]
                                                        ['countTopic'] as int;

                                                UserModel currentUser =
                                                    userSnapshot.data![index]
                                                        ['user'] as UserModel;
                                                return Column(
                                                  children: [
                                                    if (index != 0)
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                    ItemList(
                                                      onTap: () {
                                                        // Navigator.push(
                                                        //   context,
                                                        //   MaterialPageRoute(
                                                        //     builder: (context) =>
                                                        //         TopicDetailPage(
                                                        //       topicId:
                                                        //           currentTopic.id,
                                                        //     ),
                                                        //   ),
                                                        // );
                                                      },
                                                      width: null,
                                                      height: null,
                                                      head: const CircleAvatar(
                                                        backgroundImage:
                                                            AppTheme
                                                                .defaultAvatar,
                                                        radius: 32,
                                                      ),
                                                      body: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 16),
                                                        child: CustomText(
                                                          text: currentUser
                                                              .username,
                                                          type:
                                                              TextStyleEnum.xl,
                                                        ),
                                                      ),
                                                      bottom: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.filter,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              CustomText(
                                                                text:
                                                                    '$currentCountTopic học phần',
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 32),
                                color: AppTheme.primaryBackgroundColor,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  color: AppTheme.primaryBackgroundColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                );
              }
            },
          ),
          FutureBuilder(
            future: fetchAllTopicByKeyword(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: CustomText(
                    text: 'Lỗi truy vấn dữ liệu.',
                    type: TextStyleEnum.large,
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: CustomText(
                    text: 'Không có kết quả tìm kiếm.',
                    type: TextStyleEnum.large,
                  ),
                );
              } else if (snapshot.hasData) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  child: SingleChildScrollView(
                    child: GroupList(
                      itemHeight: null,
                      isList: true,
                      itemCount: snapshot.data!.length,
                      title: 'Học phần',
                      isShowOption: false,
                      builList: (index) {
                        TopicModel currentTopic = snapshot.data![index];
                        return Column(
                          children: [
                            if (index != 0)
                              const SizedBox(
                                height: 16,
                              ),
                            ItemList(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TopicDetailPage(
                                      topicId: currentTopic.id,
                                    ),
                                  ),
                                );
                              },
                              width: null,
                              height: 180,
                              headText: currentTopic.title,
                              bodyText:
                                  '${currentTopic.listCard.length} thuật ngữ',
                              bottom: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundImage: AppTheme.defaultAvatar,
                                    radius: 14,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  CustomText(
                                      text: currentTopic.userCreate!.username)
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              } else {
                return Container(
                  color: AppTheme.primaryBackgroundColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                );
              }
            },
          ),
          FutureBuilder(
            future: fetchAllUserByKeyword(),
            builder: (context, userSnapshot) {
              if (userSnapshot.hasError) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: CustomText(
                    text: 'Lỗi truy vấn dữ liệu.',
                    type: TextStyleEnum.large,
                  ),
                );
              } else if (userSnapshot.hasData && userSnapshot.data!.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: CustomText(
                    text: 'Không có kết quả tìm kiếm.',
                    type: TextStyleEnum.large,
                  ),
                );
              } else if (userSnapshot.hasData) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (userSnapshot.data!.isNotEmpty)
                          GroupList(
                            itemHeight: null,
                            isList: true,
                            itemCount: userSnapshot.data!.length,
                            title: 'Người dùng',
                            isShowOption: false,
                            builList: (index) {
                              UserModel currentUser = userSnapshot.data![index]
                                  ['user'] as UserModel;
                              int currentCountTopic = userSnapshot.data![index]
                                  ['countTopic'] as int;
                              return Column(
                                children: [
                                  if (index != 0)
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  ItemList(
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         TopicDetailPage(
                                      //       topicId:
                                      //           currentTopic.id,
                                      //     ),
                                      //   ),
                                      // );
                                    },
                                    width: null,
                                    height: null,
                                    head: const CircleAvatar(
                                      backgroundImage: AppTheme.defaultAvatar,
                                      radius: 32,
                                    ),
                                    body: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: CustomText(
                                        text: currentUser.username,
                                        type: TextStyleEnum.xl,
                                      ),
                                    ),
                                    bottom: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.filter,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            CustomText(
                                              text:
                                                  '$currentCountTopic học phần',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  color: AppTheme.primaryBackgroundColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
