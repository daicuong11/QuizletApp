import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/filter_topic_enum.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/pages/topic_detail_page.dart';
import 'package:quizletapp/services/models_services/folder_service.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';
import 'package:quizletapp/services/providers/current_user_provider.dart';
import 'package:quizletapp/services/providers/folder_provider.dart';
import 'package:quizletapp/services/providers/index_of_library_provider.dart';
import 'package:quizletapp/services/providers/topic_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/item_list.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sticky_headers/sticky_headers.dart';

class LibraryPage extends StatefulWidget {
  LibraryPage({
    super.key,
  });

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  TopicService topicService = TopicService();
  FolderService folderService = FolderService();
  FilterTopicEnum typeFilter = FilterTopicEnum.all;
  late final TabController _tabController;
  bool isLoading = false;
  bool isListNotEmpty = false;
  bool isActiveBtn = false;

  List<TopicModel> listSearch = [];
  List<TopicModel> listTopicOfCurrentUser = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _fetchListTopic();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    _searchResultList();
  }

  _searchResultList() {
    List<TopicModel> showResult = [];
    if (_searchController.text.trim() != '') {
      for (var topic in listTopicOfCurrentUser) {
        var name = topic.title.toLowerCase();
        if (name.contains(_searchController.text.toLowerCase())) {
          showResult.add(topic);
        }
      }
    } else {
      showResult = List.from(listTopicOfCurrentUser);
    }
    setState(() {
      listSearch = showResult;
    });
  }

  _fetchListTopic() async {
    var list = context.watch<TopicProvider>().listTopicOfCurrentUser;
    setState(() {
      listSearch = list;
      listTopicOfCurrentUser = list;
    });
  }

  Future<void> _fetchTopics() async {
    setState(() {
      isLoading = true;
    });
    await context.read<TopicProvider>().reloadListTopic();
    _searchController.clear();
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

  String _getTypeFilter() {
    if (typeFilter == FilterTopicEnum.all) return 'Tất cả';
    if (typeFilter == FilterTopicEnum.created) return 'Đã tạo';
    return 'Đã học';
  }

  bool checkListSearchContainsId(String id) {
    for (var i in listSearch) {
      if (i.id == id) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IndexOfLibraryProvider>(
      builder: (context, indexOfLibraryProvider, child) {
        if (indexOfLibraryProvider.indexSelected != _tabController.index) {
          _tabController.index = indexOfLibraryProvider.indexSelected;
        }
        return Scaffold(
          backgroundColor: AppTheme.primaryBackgroundColor,
          appBar: AppBar(
            foregroundColor: Colors.white,
            centerTitle: true,
            backgroundColor: AppTheme.primaryBackgroundColor,
            title: CustomText(
              text: 'Thư viện',
              type: TextStyleEnum.large,
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  if (_tabController.index == 0) {
                    print('add topic');
                    Navigator.pushNamed(context, '/topic/create');
                  } else if (_tabController.index == 1) {
                    Navigator.pushNamed(context, '/folder/create');
                  }
                },
                icon: const Icon(
                  Icons.add,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 16,
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
                  onTap: (value) {
                    indexOfLibraryProvider.changeIndex(value);
                  },
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
                      text: 'Học phần',
                    ),
                    Tab(
                      text: 'Thư mục',
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInitTopicPage(),
              _buildInitFolderPage(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInitTopicPage() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Column(
        children: [
          // Container(
          //   alignment: Alignment.centerLeft,
          //   child: TextButton(
          //     onPressed: () async {
          //       setState(() {
          //         isActiveBtn = true;
          //       });
          //       await showDialog(
          //         barrierColor: Colors.transparent,
          //         context: context,
          //         builder: (context) {
          //           return SimpleDialog(
          //             contentPadding: EdgeInsets.zero,
          //             backgroundColor: AppTheme.primaryBackgroundColorDiaLog,
          //             title: Container(
          //               padding: const EdgeInsets.only(bottom: 24),
          //               alignment: Alignment.center,
          //               child: CustomText(
          //                 text: 'Chọn lựa chọn',
          //                 type: TextStyleEnum.large,
          //               ),
          //             ),
          //             children: [
          //               Divider(
          //                 height: 0.5,
          //                 color: Colors.grey.withOpacity(0.5),
          //               ),
          //               SimpleDialogOption(
          //                 onPressed: () {
          //                   setState(() {
          //                     typeFilter = FilterTopicEnum.all;
          //                   });
          //                   Navigator.pop(context);
          //                 },
          //                 child: Container(
          //                   padding: const EdgeInsets.symmetric(vertical: 8),
          //                   child: Wrap(
          //                     spacing: 10,
          //                     children: [
          //                       SizedBox(
          //                         height: 20,
          //                         width: 20,
          //                         child: (typeFilter == FilterTopicEnum.all)
          //                             ? const Icon(
          //                                 Icons.check,
          //                                 color: Colors.white,
          //                                 size: 24,
          //                               )
          //                             : null,
          //                       ),
          //                       CustomText(
          //                         text: 'Tất cả',
          //                         style: const TextStyle(
          //                             fontWeight: FontWeight.w400),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //               Divider(
          //                 height: 0.5,
          //                 color: Colors.grey.withOpacity(0.5),
          //               ),
          //               SimpleDialogOption(
          //                 onPressed: () {
          //                   setState(() {
          //                     typeFilter = FilterTopicEnum.created;
          //                   });
          //                   Navigator.pop(context);
          //                 },
          //                 child: Container(
          //                   padding: const EdgeInsets.symmetric(vertical: 8),
          //                   child: Wrap(
          //                     spacing: 10,
          //                     children: [
          //                       SizedBox(
          //                         height: 20,
          //                         width: 20,
          //                         child: (typeFilter == FilterTopicEnum.created)
          //                             ? const Icon(
          //                                 Icons.check,
          //                                 color: Colors.white,
          //                                 size: 24,
          //                               )
          //                             : null,
          //                       ),
          //                       CustomText(
          //                         text: 'Đã tạo',
          //                         style: const TextStyle(
          //                             fontWeight: FontWeight.w400),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //               Divider(
          //                 height: 0.5,
          //                 color: Colors.grey.withOpacity(0.5),
          //               ),
          //               SimpleDialogOption(
          //                 onPressed: () {
          //                   setState(() {
          //                     typeFilter = FilterTopicEnum.studied;
          //                   });
          //                   Navigator.pop(context);
          //                 },
          //                 child: Container(
          //                   padding: const EdgeInsets.symmetric(vertical: 8),
          //                   child: Wrap(
          //                     spacing: 10,
          //                     children: [
          //                       SizedBox(
          //                         height: 20,
          //                         width: 20,
          //                         child: (typeFilter == FilterTopicEnum.studied)
          //                             ? const Icon(
          //                                 Icons.check,
          //                                 color: Colors.white,
          //                                 size: 24,
          //                               )
          //                             : null,
          //                       ),
          //                       CustomText(
          //                         text: 'Đã học',
          //                         style: const TextStyle(
          //                             fontWeight: FontWeight.w400),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           );
          //         },
          //       );
          //       setState(() {
          //         isActiveBtn = false;
          //       });
          //     },
          //     style: const ButtonStyle(
          //         padding: MaterialStatePropertyAll(EdgeInsets.all(0))),
          //     child: Container(
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //       decoration: BoxDecoration(
          //         color: (isActiveBtn)
          //             ? Colors.white.withOpacity(0.5)
          //             : Colors.transparent,
          //         border:
          //             Border.all(width: 2, color: Colors.grey.withOpacity(0.8)),
          //         borderRadius: BorderRadius.circular(6),
          //       ),
          //       child: Wrap(
          //         spacing: 4,
          //         children: [
          //           CustomText(text: _getTypeFilter()),
          //           Icon(
          //             (isActiveBtn)
          //                 ? Icons.keyboard_arrow_down
          //                 : Icons.keyboard_arrow_up,
          //             color: Colors.white,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchTopics,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.7),
                  child: Consumer<TopicProvider>(
                    builder: (context, topicProvider, child) {
                      if (topicProvider.listTopicOfCurrentUser.isNotEmpty) {
                        var listTopicToday = topicService.getTopicsToday(
                            topicProvider.listTopicOfCurrentUser);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (topicProvider
                                    .listTopicOfCurrentUser.isNotEmpty ||
                                listTopicToday.isNotEmpty)
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 24, bottom: 28),
                                child: Stack(
                                  children: [
                                    TextFormField(
                                      controller: _searchController,
                                      cursorColor: Colors.white,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(right: 44),
                                        hintText: 'Lọc học phần',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 20,
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 4.0, color: Colors.white),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2.0, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    if (_searchController.text.isNotEmpty)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                            });
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            (listSearch.isNotEmpty)
                                ? Column(
                                    children: [
                                      if (listTopicToday.isNotEmpty)
                                        StickyHeader(
                                          header: Container(
                                            color:
                                                AppTheme.primaryBackgroundColor,
                                            padding: const EdgeInsets.only(
                                                top: 16, bottom: 16),
                                            alignment: Alignment.centerLeft,
                                            child: Skeletonizer(
                                              enabled: isLoading,
                                              containersColor: AppTheme
                                                  .primaryColorSkeletonContainer,
                                              child: CustomText(
                                                text: 'Hôm nay',
                                                type: TextStyleEnum.large,
                                              ),
                                            ),
                                          ),
                                          content: Skeletonizer(
                                            enabled: isLoading,
                                            containersColor: AppTheme
                                                .primaryColorSkeletonContainer,
                                            child: Column(
                                              children: List.generate(
                                                  listTopicToday.length,
                                                  (index) {
                                                if (!checkListSearchContainsId(
                                                    listTopicToday[index].id)) {
                                                  return Container();
                                                }
                                                return Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  child: ItemList(
                                                    height: null,
                                                    width: double.infinity,
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              TopicDetailPage(
                                                            topicId:
                                                                listTopicToday[
                                                                        index]
                                                                    .id,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    headText:
                                                        listTopicToday[index]
                                                            .title,
                                                    body: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        CustomText(
                                                          text:
                                                              '${listTopicToday[index].listCard.length} thuật ngữ',
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        if (!listTopicToday[
                                                                index]
                                                            .public)
                                                          Icon(
                                                            Icons.lock_outline,
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            size: 20,
                                                          ),
                                                      ],
                                                    ),
                                                    bottom: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 16),
                                                      child: Row(
                                                        children: [
                                                          const CircleAvatar(
                                                            backgroundImage:
                                                                AppTheme
                                                                    .defaultAvatar,
                                                            radius: 14,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          CustomText(
                                                            text: listTopicToday[
                                                                        index]
                                                                    .userCreate
                                                                    ?.username ??
                                                                '',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                      StickyHeader(
                                        header: Container(
                                          color:
                                              AppTheme.primaryBackgroundColor,
                                          padding: const EdgeInsets.only(
                                              top: 16, bottom: 16),
                                          alignment: Alignment.centerLeft,
                                          child: Skeletonizer(
                                            enabled: isLoading,
                                            containersColor: AppTheme
                                                .primaryColorSkeletonContainer,
                                            child: CustomText(
                                              text: 'Tất cả',
                                              type: TextStyleEnum.large,
                                            ),
                                          ),
                                        ),
                                        content: Skeletonizer(
                                          enabled: isLoading,
                                          containersColor: AppTheme
                                              .primaryColorSkeletonContainer,
                                          child: Column(
                                            children: List.generate(
                                                topicProvider
                                                    .listTopicOfCurrentUser
                                                    .length, (index) {
                                              if (!checkListSearchContainsId(
                                                  topicProvider
                                                      .listTopicOfCurrentUser[
                                                          index]
                                                      .id)) {
                                                return Container();
                                              }
                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: ItemList(
                                                  height: null,
                                                  width: double.infinity,
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TopicDetailPage(
                                                          topicId: topicProvider
                                                              .listTopicOfCurrentUser[
                                                                  index]
                                                              .id,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  headText: topicProvider
                                                      .listTopicOfCurrentUser[
                                                          index]
                                                      .title,
                                                  body: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        CustomText(
                                                          text:
                                                              '${topicProvider.listTopicOfCurrentUser[index].listCard.length} thuật ngữ',
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        if (!topicProvider
                                                            .listTopicOfCurrentUser[
                                                                index]
                                                            .public)
                                                          Icon(
                                                            Icons.lock_outline,
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            size: 20,
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  bottom: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 16),
                                                    child: Row(
                                                      children: [
                                                        const CircleAvatar(
                                                          backgroundImage:
                                                              AppTheme
                                                                  .defaultAvatar,
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
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 32),
                                    alignment: Alignment.center,
                                    child: CustomText(
                                      text:
                                          'Không có kết quả cho \"${_searchController.text}\"',
                                      type: TextStyleEnum.xl,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          ],
                        );
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 64),
                        child: Column(
                          children: [
                            const Row(),
                            const CircleAvatar(
                              backgroundImage: AppTheme.defaultAvatar,
                              radius: 28,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            CustomText(
                              text:
                                  'Xin chào ${context.watch<CurrentUserProvider>().currentUser?.username ?? ''}',
                              type: TextStyleEnum.large,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  const Divider(),
                                  CustomText(
                                    text:
                                        'Bắt đầu bằng cách tìm học phần hoặc tự tạo học phần',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade300),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitFolderPage() {
    return RefreshIndicator(
      onRefresh: _fetchFolders,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: Consumer<FolderProvider>(
        builder: (context, folderProvider, child) {
          if (folderProvider.listFolderOfCurrentUser.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: ListView.separated(
                itemCount: folderProvider.listFolderOfCurrentUser.length,
                separatorBuilder: (context, index) => const SizedBox(
                  height: 16,
                ),
                itemBuilder: (context, index) {
                  return Skeletonizer(
                    enabled: isLoading,
                    containersColor: AppTheme.primaryColorSkeletonContainer,
                    child: Dismissible(
                      key:
                          Key(folderProvider.listFolderOfCurrentUser[index].id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          var result = await showOkCancelAlertDialog(
                              context: context,
                              okLabel: 'Xóa',
                              cancelLabel: 'Hủy',
                              isDestructiveAction: true,
                              style: AdaptiveStyle.iOS,
                              title: 'Xóa thư mục',
                              message:
                                  'Bạn chắc chắn muốn xóa thư mục này? Các học phần trong thư mục này sẽ không bị xóa mất.');

                          if (result == OkCancelResult.ok) {
                            return true;
                          }
                        }
                        return false;
                      },
                      onDismissed: (direction) async {
                        await folderService.deleteFolder(
                            folderProvider.listFolderOfCurrentUser[index].id);
                        folderProvider.reloadListFolderOfCurrentUser();
                      },
                      child: ItemList(
                        onTap: () {
                          Navigator.pushNamed(context, '/folder/detail',
                              arguments: folderProvider
                                  .listFolderOfCurrentUser[index].id);
                        },
                        height: null,
                        width: double.infinity,
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
                            CustomText(
                              text: folderProvider
                                  .listFolderOfCurrentUser[index].title,
                              type: TextStyleEnum.large,
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
                                    const EdgeInsets.symmetric(horizontal: 16),
                                color: Colors.grey.shade600.withOpacity(0.5),
                                width: 1,
                                height: 18,
                              ),
                              const CircleAvatar(
                                backgroundImage: AppTheme.defaultAvatar,
                                backgroundColor: Colors.grey,
                                radius: 14,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              CustomText(
                                  text: folderProvider
                                      .listFolderOfCurrentUser[index]
                                      .userCreate!
                                      .username)
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return SingleChildScrollView(
            child: Skeletonizer(
              enabled: isLoading,
              containersColor: AppTheme.primaryColorSkeletonContainer,
              child: Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.7),
                margin: const EdgeInsets.symmetric(
                  vertical: 64,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const Icon(
                      FontAwesomeIcons.solidFolderOpen,
                      color: Colors.blue,
                      size: 44,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 32,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: CustomText(
                        text: 'Sắp xếp học phần của bạn theo chủ đề.',
                        type: TextStyleEnum.xl,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Ink(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/folder/create');
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: CustomText(
                            text: 'Tạo thư mục',
                            type: TextStyleEnum.large,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
