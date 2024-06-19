import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/folder.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/services/models_services/folder_service.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';
import 'package:quizletapp/services/providers/folder_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/item_list.dart';
import 'package:quizletapp/widgets/text.dart';

class TopicInfoPage extends StatefulWidget {
  final TopicModel topic;
  TopicInfoPage({
    required this.topic,
    super.key,
  });

  @override
  State<TopicInfoPage> createState() => _TopicInfoPageState();
}

class _TopicInfoPageState extends State<TopicInfoPage> {
  List<FolderModel> listFolderOfThisTopic = [];

  @override
  void didChangeDependencies() {
    listFolderOfThisTopic = FolderService.getListFolderContainsTopic(
        context.watch<FolderProvider>().listFolderOfCurrentUser,
        widget.topic.id);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        leadingWidth: 64,
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.primaryBackgroundColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: CustomText(
          text: 'Thông tin học phần',
          type: TextStyleEnum.large,
        ),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: CustomText(
            text: 'Đóng',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Tạo bởi',
                  type: TextStyleEnum.large,
                ),
                const SizedBox(
                  height: 24,
                ),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      width: 2,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      children: [
                        const CircleAvatar(
                          backgroundImage: AppTheme.defaultAvatar,
                          backgroundColor: Colors.grey,
                          radius: 20,
                        ),
                        CustomText(
                          text: '${widget.topic.userCreate?.username}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        CustomText(
                          text:
                              '${TopicService.formatDate(widget.topic.dateCreated)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Đã thêm vào các thư mục sau',
                  type: TextStyleEnum.large,
                ),
                const SizedBox(
                  height: 24,
                ),
                if (listFolderOfThisTopic.isNotEmpty)
                  ...List.generate(listFolderOfThisTopic.length, (index) {
                    return Container(
                      margin: (index % 2 != 0)
                          ? const EdgeInsets.symmetric(vertical: 16)
                          : null,
                      child: ItemList(
                        onTap: () {
                          Navigator.pushNamed(context, '/folder/detail',
                              arguments: listFolderOfThisTopic[index].id);
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
                              text: listFolderOfThisTopic[index].title,
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
                                      '${listFolderOfThisTopic[index].listTopic.length} học phần'),
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
                                  text: listFolderOfThisTopic[index]
                                      .userCreate!
                                      .username)
                            ],
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
    );
  }
}
