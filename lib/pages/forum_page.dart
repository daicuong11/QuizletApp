import 'package:flutter/material.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/item_list.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _searchInputController = TextEditingController();
  late Future<List<TopicModel>> _futureTopics;

  @override
  void initState() {
    super.initState();
    _futureTopics = fetchAllTopic();
  }

  String _formatDate(DateTime dateCreated) {
    final now = DateTime.now();
    final difference = now.difference(dateCreated);

    if (difference.inSeconds < 60) {
      return 'vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 2) {
      return 'hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      String day = dateCreated.day.toString().padLeft(2, '0');
      String month = dateCreated.month.toString().padLeft(2, '0');
      String year = dateCreated.year.toString();
      return '$day/$month/$year';
    }
  }

  Widget _buildPost(TopicModel topic) {
    return ItemList(
      onTap: () {
        Navigator.pushNamed(context, '/topic/detail', arguments: topic.id);
      },
      height: null,
      width: double.infinity,
      head: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: topic.title,
            type: TextStyleEnum.large,
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: _formatDate(topic.dateCreated),
                type: TextStyleEnum.normal,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              const Icon(
                Icons.access_time_outlined,
                color: Colors.grey,
                size: 20,
              )
            ],
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            CustomText(text: '${topic.listCard.length} thuật ngữ'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
            CustomText(text: topic.userCreate?.username ?? 'người vô danh')
          ],
        ),
      ),
    );
  }

  Future<List<TopicModel>> fetchAllTopic() async {
    TopicService topicService = TopicService();
    var result = await topicService.getAllTopicPublic();
    return TopicService.sortTopicsByDateDescending(result);
  }

  @override
  Widget build(BuildContext context) {
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
          text: 'Diễn đàn',
          type: TextStyleEnum.xl,
        ),
        //không hiển thị leadding
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        backgroundColor: AppTheme.primaryBackgroundColorAppbar,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(bottom: 18),
            child: TextField(
              controller: _searchInputController,
              onSubmitted: (value) {
                if (value.trim().isEmpty) return;
                Navigator.pushNamed(context, '/search-topic',
                    arguments: {'code': 0, 'key': _searchInputController.text});
                _searchInputController.clear();
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
        actions: [
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
      ),
      body: FutureBuilder<List<TopicModel>>(
        future: _futureTopics,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Skeletonizer(
              enabled: true,
              containersColor: AppTheme.primaryColorSkeletonContainer,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                itemCount: 5,
                separatorBuilder: (context, index) => const SizedBox(
                  height: 16,
                ),
                itemBuilder: (context, index) {
                  return ItemList(
                    height: null,
                    width: double.infinity,
                    head: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Tên của topic',
                          type: TextStyleEnum.large,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              text: 'Vừa xong',
                              type: TextStyleEnum.normal,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Icon(
                              Icons.access_time_outlined,
                              color: Colors.grey,
                              size: 20,
                            )
                          ],
                        ),
                      ],
                    ),
                    body: Container(
                      margin: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          CustomText(text: '10 thuật ngữ'),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                          CustomText(text: 'người vô danh')
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: CustomText(text: 'Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _futureTopics = fetchAllTopic();
                });
              },
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: ListView(
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 200),
                      child: Center(
                          child: CustomText(
                              text: 'Chưa có học phần nào được tạo.'))),
                ],
              ),
            );
          } else {
            var listTopicModel = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _futureTopics = fetchAllTopic();
                });
              },
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                itemCount: listTopicModel.length,
                separatorBuilder: (context, index) => const SizedBox(
                  height: 16,
                ),
                itemBuilder: (context, index) {
                  var currentTopic = listTopicModel[index];
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Các học phần mới nhất',
                          type: TextStyleEnum.large,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildPost(currentTopic),
                      ],
                    );
                  }
                  return _buildPost(currentTopic);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
