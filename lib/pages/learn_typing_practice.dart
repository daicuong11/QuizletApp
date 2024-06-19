import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:quizletapp/enums/setting_learn_quiz.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/button.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LearnTypingPracticePage extends StatefulWidget {
  final TopicModel topic;
  const LearnTypingPracticePage({
    required this.topic,
    super.key,
  });

  @override
  State<LearnTypingPracticePage> createState() => _LearnTypingPracticePageState();
}

class _LearnTypingPracticePageState extends State<LearnTypingPracticePage> {
  late TopicModel currentTopic;
  bool isShowResult = false;
  bool isAnswerByTerm = false;
  bool isLoading = true;
  int countCardToLearn = 1;

  @override
  void initState() {
    currentTopic = widget.topic;
    _initValue();
    super.initState();
  }

  _initValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isShowResultSaved =
        sharedPreferences.getBool(SettingLearnQuizEnum.isShowResult.name) ??
            false;
    bool isAnswerByTermSaved =
        sharedPreferences.getBool(SettingLearnQuizEnum.isAnswerByTerm.name) ??
            false;
    int sumLearnNumber = 1;
    if(widget.topic.listCard.length >= 20) {
      sumLearnNumber = 20;
    }
    else if (widget.topic.listCard.length >= 10) {
      sumLearnNumber = 10;
    }
    else {
      sumLearnNumber = widget.topic.listCard.length;
    }
    setState(() {
      isShowResult = isShowResultSaved;
      isAnswerByTerm = isAnswerByTermSaved;
      countCardToLearn = sumLearnNumber;
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: Skeletonizer(
        enabled: isLoading,
        containersColor: AppTheme.primaryColorSkeletonContainer,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(right: 4),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          direction: Axis.vertical,
                          spacing: 8,
                          children: [
                            CustomText(text: currentTopic.title),
                            CustomText(
                              text: 'Thiết lập gõ từ',
                              type: TextStyleEnum.xl,
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.edit_document,
                          color: AppTheme.primaryColor,
                          size: 60,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState2) {
                                return Container(
                                  height: 360,
                                  color: Color.fromARGB(255, 27, 32, 41),
                                  child: Column(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        color: AppTheme
                                            .primaryBackgroundColorAppbar,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: CustomText(
                                                text: 'Hoàn tất',
                                                type: TextStyleEnum.large,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 16),
                                          child: NumberPicker(
                                            value: countCardToLearn,
                                            minValue: 1,
                                            maxValue:
                                                currentTopic.listCard.length,
                                            itemCount: 7,
                                            itemWidth: double.infinity,
                                            itemHeight: 40,
                                            zeroPad: true,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.3)),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                            ),
                                            selectedTextStyle: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            onChanged: (value) {
                                              setState2(() {
                                                setState(() {
                                                  countCardToLearn = value;
                                                });
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        splashColor: AppTheme.primaryBackgroundColor,
                        title: CustomText(
                          text: 'Số câu hỏi',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              text: countCardToLearn.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: AppTheme.primaryColor,
                              size: 44,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        splashColor: AppTheme.primaryBackgroundColor,
                        title: CustomText(
                          text: 'Hiển thị đáp án ngay',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Switch(
                          value: isShowResult,
                          onChanged: (value) async {
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            setState(() {
                              isShowResult = value;
                            });
                            await sharedPreferences.setBool(
                                SettingLearnQuizEnum.isShowResult.name, value);
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        splashColor: AppTheme.primaryBackgroundColor,
                        title: CustomText(
                          text: 'Trả lời bằng thuật ngữ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: CustomText(
                          text: (!isAnswerByTerm)
                              ? 'Câu hỏi: Thuật ngữ, Đáp án: Định nghĩa'
                              : 'Câu hỏi: Định nghĩa, Đáp án: Thuật ngữ',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        trailing: Switch(
                          value: isAnswerByTerm,
                          onChanged: (value) async {
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            setState(() {
                              isAnswerByTerm = value;
                            });
                            await sharedPreferences.setBool(
                                SettingLearnQuizEnum.isAnswerByTerm.name,
                                value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton(
                disable: (widget.topic.listCard.isEmpty)? true : false,
                text: 'Bắt đầu làm kiểm tra',
                onTap: () {
                  if(widget.topic.listCard.isEmpty) return;
                  Map<String, dynamic> object = {
                    'topic': widget.topic,
                    'listCard': widget.topic.listCard,
                    SettingLearnQuizEnum.sumLearnNumber.name: countCardToLearn,
                    SettingLearnQuizEnum.isShowResult.name: isShowResult,
                    SettingLearnQuizEnum.isAnswerByTerm.name: isAnswerByTerm,
                  };
                  Navigator.popAndPushNamed(context, '/learn/typing',
                      arguments: object);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
