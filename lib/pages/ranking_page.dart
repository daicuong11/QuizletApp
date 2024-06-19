import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/ranking.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/services/models_services/exam_result_service.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/button.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RankingPage extends StatefulWidget {
  final TopicModel topic;

  const RankingPage({
    required this.topic,
    super.key,
  });

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with SingleTickerProviderStateMixin {
  ExamResultService examResultService = ExamResultService();

  late final TabController _tabController;

  late TopicModel topic;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    topic = TopicModel.copy(widget.topic);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<RankingModel>> fetchTopQuantityCorrect() {
    return examResultService.getTop20ByQuantityCorrect(widget.topic.id);
  }

  Future<List<RankingModel>> fetchTopTimeTest() {
    return examResultService.getTop20ByTimeTest(widget.topic.id);
  }

  Future<List<RankingModel>> fetchTopAttempts() {
    return examResultService.getTop20ByAttempts(widget.topic.id);
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    List<String> parts = [];

    if (hours > 0) {
      parts.add('$hours giờ');
    }
    if (minutes > 0) {
      parts.add('$minutes phút');
    }
    if (remainingSeconds > 0 || parts.isEmpty) {
      parts.add('$remainingSeconds giây');
    }

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: AppTheme.primaryBackgroundColor,
        title: CustomText(
          text: 'Bảng xếp hạng',
          type: TextStyleEnum.large,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          dividerHeight: 3,
          overlayColor:
              const MaterialStatePropertyAll(AppTheme.primaryBackgroundColor),
          dividerColor: Colors.transparent,
          indicatorColor: Colors.deepPurpleAccent.shade100,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          labelStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 32),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
              text: 'Thần đồng',
            ),
            Tab(
              text: 'Vua tốc độ',
            ),
            Tab(
              text: 'Chăm chỉ',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder(
            future: fetchTopQuantityCorrect(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text:
                            'Chủ đề này chưa có bài kiểm tra nào. \n Bạn hãy là người đầu tiên!',
                        textAlign: TextAlign.center,
                        type: TextStyleEnum.large,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 64),
                        child: CustomButton(
                          onTap: () {
                            Navigator.popAndPushNamed(
                              context,
                              '/learn/quiz/settings',
                              arguments: topic,
                            );
                          },
                          iconLeft: const Icon(
                            Icons.menu_book,
                            color: Colors.white,
                          ),
                          text: 'Lấy Top ngay!',
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasData) {
                List<RankingModel> data = snapshot.data!;
                int sumQuestion = data[0].topic.listCard.length;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 4,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              height: 160,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Image.asset('assets/images/top.png'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 32,
                                        ),
                                        CustomText(
                                          text: "Bảng xếp hạng".toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        CustomText(
                                          text:
                                              'Top 20 người trả lời đúng nhiều nhất',
                                          type: TextStyleEnum.large,
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                    ),
                                    child: CustomText(
                                      text: '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        image: AppTheme.defaultAvatar,
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(
                                        width: 2,
                                        color: (index < 3)
                                            ? Colors.redAccent
                                            : Colors.yellowAccent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              title: CustomText(
                                text: data[index].user.username,
                                type: TextStyleEnum.large,
                              ),
                              trailing: CustomText(
                                text:
                                    '${data[index].quantityCorrect}/$sumQuestion',
                                type: TextStyleEnum.xl,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 157, 113, 227),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 20,
                              ),
                              child: CustomText(
                                text: '${index + 1}',
                                style: (index < 3)
                                    ? const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      )
                                    : const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AppTheme.defaultAvatar,
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: (index < 3)
                                      ? Colors.redAccent
                                      : Colors.yellowAccent,
                                ),
                              ),
                            )
                          ],
                        ),
                        title: CustomText(
                          text: data[index].user.username,
                          type: TextStyleEnum.large,
                        ),
                        trailing: CustomText(
                          text: '${data[index].quantityCorrect}/$sumQuestion',
                          type: TextStyleEnum.xl,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 157, 113, 227),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: data.length,
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  child: CustomText(text: 'Lỗi tải dữ liệu!'),
                );
              } else {
                return Skeletonizer(
                  enabled: true,
                  containersColor: AppTheme.primaryColorSkeletonContainer,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 32),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 4,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                height: 160,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child:
                                          Image.asset('assets/images/top.png'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 32,
                                          ),
                                          CustomText(
                                            text: "Bảng xếp hạng".toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          CustomText(
                                            text:
                                                'Top 20 người trả lời đúng nhiều nhất',
                                            type: TextStyleEnum.large,
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                      ),
                                      child: CustomText(
                                        text: '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        image: const DecorationImage(
                                          image: AppTheme.defaultAvatar,
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: (index < 3)
                                              ? Colors.redAccent
                                              : Colors.yellowAccent,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                title: CustomText(
                                  text: 'Lý Đại Cương',
                                  type: TextStyleEnum.large,
                                ),
                                trailing: CustomText(
                                  text: '10/10',
                                  type: TextStyleEnum.xl,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 157, 113, 227),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                ),
                                child: CustomText(
                                  text: '${index + 1}',
                                  style: (index < 3)
                                      ? const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        )
                                      : const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AppTheme.defaultAvatar,
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    width: 2,
                                    color: (index < 3)
                                        ? Colors.redAccent
                                        : Colors.yellowAccent,
                                  ),
                                ),
                              )
                            ],
                          ),
                          title: CustomText(
                            text: 'Đỗ Văn Hoàng',
                            type: TextStyleEnum.large,
                          ),
                          trailing: CustomText(
                            text: '1/10',
                            type: TextStyleEnum.xl,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 157, 113, 227),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: 20,
                    ),
                  ),
                );
              }
            },
          ),
          FutureBuilder(
            future: fetchTopTimeTest(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text:
                            'Chủ đề này chưa có bài kiểm tra nào. \n Bạn hãy là người đầu tiên!',
                        textAlign: TextAlign.center,
                        type: TextStyleEnum.large,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 64),
                        child: CustomButton(
                          onTap: () {
                            Navigator.popAndPushNamed(
                              context,
                              '/learn/quiz/settings',
                              arguments: topic,
                            );
                          },
                          iconLeft: const Icon(
                            Icons.menu_book,
                            color: Colors.white,
                          ),
                          text: 'Lấy Top ngay!',
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.hasData) {
                List<RankingModel> data = snapshot.data!;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 4,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              height: 160,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child:
                                        Image.asset('assets/images/nhanh.png'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 32,
                                        ),
                                        CustomText(
                                          text: "Bảng xếp hạng".toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        CustomText(
                                          text:
                                              'Top 20 người trả lời nhanh nhất',
                                          type: TextStyleEnum.large,
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                    ),
                                    child: CustomText(
                                      text: '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        image: AppTheme.defaultAvatar,
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(
                                        width: 2,
                                        color: (index < 3)
                                            ? Colors.redAccent
                                            : Colors.yellowAccent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              title: CustomText(
                                text: data[index].user.username,
                                type: TextStyleEnum.large,
                              ),
                              trailing: CustomText(
                                text: formatDuration(data[index].timeTest),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 157, 113, 227),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 20,
                              ),
                              child: CustomText(
                                text: '${index + 1}',
                                style: (index < 3)
                                    ? const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      )
                                    : const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AppTheme.defaultAvatar,
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: (index < 3)
                                      ? Colors.redAccent
                                      : Colors.yellowAccent,
                                ),
                              ),
                            )
                          ],
                        ),
                        title: CustomText(
                          text: data[index].user.username,
                          type: TextStyleEnum.large,
                        ),
                        trailing: CustomText(
                          text: formatDuration(data[index].timeTest),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 157, 113, 227),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: data.length,
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  child: CustomText(text: 'Lỗi tải dữ liệu!'),
                );
              } else {
                return Skeletonizer(
                  enabled: true,
                  containersColor: AppTheme.primaryColorSkeletonContainer,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 32),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 4,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                height: 160,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child:
                                          Image.asset('assets/images/top.png'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 32,
                                          ),
                                          CustomText(
                                            text: "Bảng xếp hạng".toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          CustomText(
                                            text:
                                                'Top 20 người trả lời đúng nhiều nhất',
                                            type: TextStyleEnum.large,
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                      ),
                                      child: CustomText(
                                        text: '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        image: const DecorationImage(
                                          image: AppTheme.defaultAvatar,
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: (index < 3)
                                              ? Colors.redAccent
                                              : Colors.yellowAccent,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                title: CustomText(
                                  text: 'Lý Đại Cương',
                                  type: TextStyleEnum.large,
                                ),
                                trailing: CustomText(
                                  text: '10/10',
                                  type: TextStyleEnum.xl,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 157, 113, 227),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                ),
                                child: CustomText(
                                  text: '${index + 1}',
                                  style: (index < 3)
                                      ? const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        )
                                      : const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AppTheme.defaultAvatar,
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    width: 2,
                                    color: (index < 3)
                                        ? Colors.redAccent
                                        : Colors.yellowAccent,
                                  ),
                                ),
                              )
                            ],
                          ),
                          title: CustomText(
                            text: 'Đỗ Văn Hoàng',
                            type: TextStyleEnum.large,
                          ),
                          trailing: CustomText(
                            text: '1/10',
                            type: TextStyleEnum.xl,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 157, 113, 227),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: 20,
                    ),
                  ),
                );
              }
            },
          ),
          FutureBuilder(
            future: fetchTopAttempts(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text:
                            'Chủ đề này chưa có bài kiểm tra nào. \n Bạn hãy là người đầu tiên!',
                        textAlign: TextAlign.center,
                        type: TextStyleEnum.large,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 64),
                        child: CustomButton(
                          onTap: () {
                            Navigator.popAndPushNamed(
                              context,
                              '/learn/quiz/settings',
                              arguments: topic,
                            );
                          },
                          iconLeft: const Icon(
                            Icons.menu_book,
                            color: Colors.white,
                          ),
                          text: 'Lấy Top ngay!',
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.hasData) {
                List<RankingModel> data = snapshot.data!;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 4,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              height: 160,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                        'assets/images/chamchi.png'),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 32,
                                        ),
                                        CustomText(
                                          text: "Bảng xếp hạng".toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        CustomText(
                                          text:
                                              'Top 20 người học chủ đề này nhiều nhất',
                                          type: TextStyleEnum.large,
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                    ),
                                    child: CustomText(
                                      text: '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        image: AppTheme.defaultAvatar,
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(
                                        width: 2,
                                        color: (index < 3)
                                            ? Colors.redAccent
                                            : Colors.yellowAccent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              title: CustomText(
                                text: data[index].user.username,
                                type: TextStyleEnum.large,
                              ),
                              trailing: CustomText(
                                text: '${data[index].attempts} lần',
                                type: TextStyleEnum.large,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 157, 113, 227),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 20,
                              ),
                              child: CustomText(
                                text: '${index + 1}',
                                style: (index < 3)
                                    ? const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      )
                                    : const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AppTheme.defaultAvatar,
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: (index < 3)
                                      ? Colors.redAccent
                                      : Colors.yellowAccent,
                                ),
                              ),
                            )
                          ],
                        ),
                        title: CustomText(
                          text: data[index].user.username,
                          type: TextStyleEnum.large,
                        ),
                        trailing: CustomText(
                          text: '${data[index].attempts} lần',
                          type: TextStyleEnum.large,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 157, 113, 227),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: data.length,
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  child: CustomText(text: 'Lỗi tải dữ liệu!'),
                );
              } else {
                return Skeletonizer(
                  enabled: true,
                  containersColor: AppTheme.primaryColorSkeletonContainer,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 32),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 4,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                height: 160,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child:
                                          Image.asset('assets/images/top.png'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 32,
                                          ),
                                          CustomText(
                                            text: "Bảng xếp hạng".toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          CustomText(
                                            text:
                                                'Top 20 người trả lời đúng nhiều nhất',
                                            type: TextStyleEnum.large,
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                      ),
                                      child: CustomText(
                                        text: '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        image: const DecorationImage(
                                          image: AppTheme.defaultAvatar,
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: (index < 3)
                                              ? Colors.redAccent
                                              : Colors.yellowAccent,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                title: CustomText(
                                  text: 'Lý Đại Cương',
                                  type: TextStyleEnum.large,
                                ),
                                trailing: CustomText(
                                  text: '10/10',
                                  type: TextStyleEnum.xl,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 157, 113, 227),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                ),
                                child: CustomText(
                                  text: '${index + 1}',
                                  style: (index < 3)
                                      ? const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        )
                                      : const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AppTheme.defaultAvatar,
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    width: 2,
                                    color: (index < 3)
                                        ? Colors.redAccent
                                        : Colors.yellowAccent,
                                  ),
                                ),
                              )
                            ],
                          ),
                          title: CustomText(
                            text: 'Đỗ Văn Hoàng',
                            type: TextStyleEnum.large,
                          ),
                          trailing: CustomText(
                            text: '1/10',
                            type: TextStyleEnum.xl,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 157, 113, 227),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: 20,
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
