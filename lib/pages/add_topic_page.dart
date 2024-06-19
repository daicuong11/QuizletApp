import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/folder.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/services/models_services/folder_service.dart';
import 'package:quizletapp/services/providers/current_user_provider.dart';
import 'package:quizletapp/services/providers/folder_provider.dart';
import 'package:quizletapp/services/providers/topic_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/item_list.dart';
import 'package:quizletapp/widgets/loading.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class AddTopicPage extends StatefulWidget {
  FolderModel folder;
  AddTopicPage({
    required this.folder,
    super.key,
  });

  @override
  State<AddTopicPage> createState() => _AddTopicPageState();
}

class _AddTopicPageState extends State<AddTopicPage>
    with SingleTickerProviderStateMixin {
  FolderService folderService = FolderService();
  late final TabController _tabController;
  bool isLoading = false;
  bool onLoading = false;

  late List<String> listTopicIdPicked = [];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    fetchLoadListPicked();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchLoadListPicked() {
    setState(() {
      listTopicIdPicked = widget.folder.listTopicId;
    });
  }

  Future<void> _fetchTopics() async {
    setState(() {
      isLoading = true;
    });
    await context.read<TopicProvider>().reloadListTopic();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchFolders() async {
    setState(() {
      isLoading = true;
    });
    await context.read<FolderProvider>().reloadListFolderOfCurrentUser();
    setState(() {
      isLoading = false;
    });
  }

  bool checkTopicContains(String topicId) {
    return listTopicIdPicked.contains(topicId);
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
          text: 'Thêm học phần',
          type: TextStyleEnum.large,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              setState(() {
                onLoading = true;
              });
              widget.folder.listTopicId = listTopicIdPicked;
              await folderService.updateFolder(widget.folder);
              await context
                  .read<FolderProvider>()
                  .reloadListFolderOfCurrentUser();
              toastification.show(
                context: context,
                title: CustomText(text: 'Đã lưu thay đổi', type: TextStyleEnum.large,),
                style: ToastificationStyle.fillColored,
                foregroundColor: Colors.white,
                showProgressBar: false,
                type: ToastificationType.success,
                autoCloseDuration: const Duration(seconds: 3),
              );
              setState(() {
                onLoading = false;
              });
              Navigator.pop(context);
            },
            child: CustomText(
              text: 'Xong',
              type: TextStyleEnum.large,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TabBar(
              controller: _tabController,
              indicatorWeight: 3,
              dividerHeight: 3,
              overlayColor: const MaterialStatePropertyAll(
                  AppTheme.primaryBackgroundColor),
              dividerColor: Colors.grey.shade600.withOpacity(0.5),
              indicatorColor: Colors.deepPurpleAccent.shade100,
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.white,
              labelStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              labelPadding: const EdgeInsets.only(right: 32),
              tabs: const [
                Tab(
                  text: 'Đã tạo',
                ),
                Tab(
                  text: 'Đã học',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildViewTopicsCreated(),
              _buildViewTopicsStudied(),
            ],
          ),
          if (onLoading) Loading(),
        ],
      ),
    );
  }

  Widget _buildViewTopicsCreated() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: RefreshIndicator(
        onRefresh: _fetchTopics,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.8),
            child: Consumer<TopicProvider>(
              builder: (context, topicProvider, child) {
                return Skeletonizer(
                  enabled: isLoading,
                  containersColor: AppTheme.primaryColorSkeletonContainer,
                  child: Column(
                    children: [
                      const Row(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        margin: const EdgeInsets.only(bottom: 24),
                        child: TextButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await Navigator.pushNamed(context, '/topic/create',
                                arguments: true);
                            await topicProvider.reloadListTopic();
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: CustomText(
                            text: '+ Tạo học phần mới',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 207, 177, 255),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ...List.generate(
                          topicProvider.listTopicOfCurrentUser.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ItemList(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBackgroundColor,
                              border: Border.all(
                                color: (checkTopicContains(topicProvider
                                        .listTopicOfCurrentUser[index].id))
                                    ? const Color.fromARGB(255, 207, 177, 255)
                                    : Colors.grey.withOpacity(0.1),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            height: null,
                            width: double.infinity,
                            onTap: () {
                              setState(() {
                                TopicModel topic =
                                    topicProvider.listTopicOfCurrentUser[index];
                                if (checkTopicContains(topic.id)) {
                                  setState(() {
                                    listTopicIdPicked.remove(topic.id);
                                  });
                                  return;
                                }
                                setState(() {
                                  listTopicIdPicked.add(topic.id);
                                });
                              });
                            },
                            headText: topicProvider
                                .listTopicOfCurrentUser[index].title,
                            body: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText(
                                  text:
                                      '${topicProvider.listTopicOfCurrentUser[index].listCard.length} thuật ngữ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                if (!topicProvider
                                    .listTopicOfCurrentUser[index].public)
                                  Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey.withOpacity(0.5),
                                    size: 20,
                                  ),
                              ],
                            ),
                            bottom: Container(
                              margin: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundImage: AppTheme.defaultAvatar,
                                    radius: 14,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  CustomText(
                                      text: topicProvider
                                              .listTopicOfCurrentUser[index]
                                              .userCreate
                                              ?.username ??
                                          ''),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewTopicsStudied() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: RefreshIndicator(
        onRefresh: _fetchTopics,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.8),
            child: Consumer<TopicProvider>(
              builder: (context, topicProvider, child) {
                return Skeletonizer(
                  enabled: isLoading,
                  containersColor: AppTheme.primaryColorSkeletonContainer,
                  child: Column(
                    children: [
                      const Row(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        margin: const EdgeInsets.only(bottom: 24),
                        child: TextButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await Navigator.pushNamed(context, '/topic/create',
                                arguments: true);
                            await topicProvider.reloadListTopic();
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: CustomText(
                            text: '+ Tạo học phần mới',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 207, 177, 255),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ...List.generate(
                          topicProvider.listTopicOfCurrentUser.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ItemList(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBackgroundColor,
                              border: Border.all(
                                color: (checkTopicContains(topicProvider
                                        .listTopicOfCurrentUser[index].id))
                                    ? const Color.fromARGB(255, 207, 177, 255)
                                    : Colors.grey.withOpacity(0.1),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            height: null,
                            width: double.infinity,
                            onTap: () {
                              setState(() {
                                TopicModel topic =
                                    topicProvider.listTopicOfCurrentUser[index];
                                if (checkTopicContains(topic.id)) {
                                  setState(() {
                                    listTopicIdPicked.remove(topic.id);
                                  });
                                  return;
                                }
                                setState(() {
                                  listTopicIdPicked.add(topic.id);
                                });
                              });
                            },
                            headText: topicProvider
                                .listTopicOfCurrentUser[index].title,
                            body: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText(
                                  text:
                                      '${topicProvider.listTopicOfCurrentUser[index].listCard.length} thuật ngữ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                if (!topicProvider
                                    .listTopicOfCurrentUser[index].public)
                                  Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey.withOpacity(0.5),
                                    size: 20,
                                  ),
                              ],
                            ),
                            bottom: Container(
                              margin: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundImage: AppTheme.defaultAvatar,
                                    radius: 14,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  CustomText(
                                      text: topicProvider
                                              .listTopicOfCurrentUser[index]
                                              .userCreate
                                              ?.username ??
                                          ''),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
