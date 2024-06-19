import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/folder.dart';
import 'package:quizletapp/pages/topic_detail_page.dart';
import 'package:quizletapp/services/models_services/folder_service.dart';
import 'package:quizletapp/services/providers/folder_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/button.dart';
import 'package:quizletapp/widgets/item_list.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class FolderDetailPage extends StatefulWidget {
  final String folderId;
  const FolderDetailPage({
    required this.folderId,
    super.key,
  });

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  FolderService folderService = FolderService();
  bool isLoading = false;
  FolderModel? folder;

  @override
  void initState() {
    _fetchFolder();
    super.initState();
  }

  Future<void> _fetchFolder() async {
    setState(() {
      isLoading = true;
    });
    folder = await folderService.getFolderById(widget.folderId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackgroundColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                '/folder/add',
                arguments: folder,
              );

              await _fetchFolder();
            },
            icon: const Icon(
              Icons.add_outlined,
              size: 28,
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_horiz_rounded),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: AppTheme.primaryBackgroundColor,
        elevation: 0,
        child: Column(
          children: [
            Expanded(
              child: Container(
                height: 200,
              ),
            ),
            Wrap(
              children: [
                const Divider(
                  thickness: 0.5,
                  height: 1,
                ),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.pushNamed(context, '/folder/edit',
                        arguments: folder);
                    _fetchFolder();
                  },
                  child: ListTile(
                    minVerticalPadding: 20,
                    title: CustomText(
                      text: 'Sửa thư mục',
                      type: TextStyleEnum.large,
                    ),
                    leading: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              children: [
                const Divider(
                  thickness: 0.5,
                  height: 1,
                ),
                InkWell(
                  onTap: () async {
                    await Navigator.popAndPushNamed(context, '/folder/add',
                        arguments: folder!);
                    await _fetchFolder();
                  },
                  child: ListTile(
                    minVerticalPadding: 20,
                    title: CustomText(
                      text: 'Thêm học phần',
                      type: TextStyleEnum.large,
                    ),
                    leading: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              children: [
                const Divider(
                  thickness: 0.5,
                  height: 1,
                ),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    var chooseResult = await showOkCancelAlertDialog(
                      context: context,
                      cancelLabel: 'Hủy',
                      okLabel: 'Xóa',
                      isDestructiveAction: true,
                      style: AdaptiveStyle.iOS,
                      title: 'Bạn chắc chắn muốn xóa thư mục này?',
                    );
                    if (chooseResult == OkCancelResult.ok) {
                      await folderService.deleteFolder(folder!.id);
                      context
                          .read<FolderProvider>()
                          .reloadListFolderOfCurrentUser();
                      Navigator.pop(context);
                    }
                  },
                  child: ListTile(
                    minVerticalPadding: 20,
                    title: CustomText(
                      text: 'Xóa thư mục',
                      type: TextStyleEnum.large,
                    ),
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              children: [
                const Divider(
                  thickness: 0.5,
                  height: 1,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 20, bottom: 28),
                    alignment: Alignment.center,
                    child: CustomText(
                      text: 'Hủy',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFolder,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: (folder != null)
                ? Skeletonizer(
                    enabled: isLoading,
                    containersColor: AppTheme.primaryColorSkeletonContainer,
                    child: Column(
                      children: [
                        const Row(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Row(),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: CustomText(
                                  text: folder!.title,
                                  type: TextStyleEnum.xl,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  direction: Axis.horizontal,
                                  children: [
                                    const Row(),
                                    CustomText(
                                      text:
                                          '${folder!.listTopic.length} học phần',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      color:
                                          Colors.grey.shade600.withOpacity(0.5),
                                      width: 1,
                                      height: 32,
                                    ),
                                    Wrap(
                                      direction: Axis.horizontal,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      children: [
                                        const CircleAvatar(
                                          backgroundImage:
                                              AppTheme.defaultAvatar,
                                          backgroundColor: Colors.grey,
                                          radius: 18,
                                        ),
                                        CustomText(
                                          text: folder!.userCreate!.username,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              // render list topic in this folder
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 32),
                                child: (folder!.listTopic.isEmpty)
                                    ? Container(
                                        color: Colors.grey.withOpacity(0.4),
                                        padding: const EdgeInsets.all(32),
                                        child: Column(
                                          children: [
                                            const Row(),
                                            CustomText(
                                              text:
                                                  'Thư mục này không có học phần',
                                              type: TextStyleEnum.large,
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            CustomText(
                                              text:
                                                  'Thêm học phần vào thư mục này để sắp xếp chúng.',
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            CustomButton(
                                              onTap: () async {
                                                await Navigator.pushNamed(
                                                  context,
                                                  '/folder/add',
                                                  arguments: folder,
                                                );
                                                _fetchFolder();
                                              },
                                              height: 38,
                                              text: 'Thêm học phần',
                                              textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          ...List.generate(
                                              folder!.listTopic.length,
                                              (index) {
                                            return Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: Dismissible(
                                                key: Key(folder!
                                                    .listTopic[index].id),
                                                direction:
                                                    DismissDirection.endToStart,
                                                background: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20),
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration:
                                                        const BoxDecoration(
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
                                                onDismissed: (direction) async {
                                                  folder!.listTopicId.remove(
                                                      folder!
                                                          .listTopic[index].id);
                                                  setState(() {
                                                    folder!.listTopic.remove(folder!.listTopic[index]);
                                                  });
                                                  await folderService
                                                      .updateFolder(folder!);
                                                  context
                                                      .read<FolderProvider>()
                                                      .reloadListFolderOfCurrentUser();
                                                  toastification.show(
                                                    context: context,
                                                    title: CustomText(
                                                      text: 'Đã lưu thay đổi',
                                                      type: TextStyleEnum.large,
                                                    ),
                                                    style: ToastificationStyle
                                                        .fillColored,
                                                    foregroundColor:
                                                        Colors.white,
                                                    showProgressBar: false,
                                                    type: ToastificationType
                                                        .success,
                                                    autoCloseDuration:
                                                        const Duration(
                                                            seconds: 3),
                                                  );
                                                },
                                                child: ItemList(
                                                  height: null,
                                                  width: double.infinity,
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TopicDetailPage(
                                                          topicId: folder!
                                                              .listTopic[index]
                                                              .id,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  headText: folder!
                                                      .listTopic[index].title,
                                                  body: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CustomText(
                                                        text:
                                                            '${folder!.listTopic[index].listCard.length} thuật ngữ',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14),
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      if (!folder!
                                                          .listTopic[index]
                                                          .public)
                                                        Icon(
                                                          Icons.lock_outline,
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
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
                                                          text: folder!
                                                                  .listTopic[
                                                                      index]
                                                                  .userCreate
                                                                  ?.username ??
                                                              '',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
        ),
      ),
    );
  }
}
