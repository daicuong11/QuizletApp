import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/setting_learn_quiz.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/card.dart';
import 'package:quizletapp/models/exam_result.dart';
import 'package:quizletapp/models/result.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/models/user.dart';
import 'package:quizletapp/services/models_services/exam_result_service.dart';
import 'package:quizletapp/services/providers/current_user_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/button.dart';
import 'package:quizletapp/widgets/text.dart';

class QuizPage extends StatefulWidget {
  final TopicModel topic;
  final List<CardModel> listCard;
  final int sumLearnNumber;
  final bool isShowResult;
  final bool isAnswerByTerm;
  const QuizPage({
    required this.topic,
    required this.listCard,
    required this.sumLearnNumber,
    required this.isShowResult,
    required this.isAnswerByTerm,
    super.key,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<CardModel> listCard;
  ExamResultService examResultService = ExamResultService();
  List<ResultModel> listResult = [];
  int currentLearnIndex = 0;

  Stopwatch timeTest = Stopwatch();

  Map<String, double> dataChart = {
    'Đúng': 0,
    'Sai': 0,
  };

  final colorList = <Color>[
    Colors.greenAccent,
    Colors.orangeAccent,
  ];

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    listCard = List.from(widget.listCard);
    listCard.shuffle(Random());
    _initValue();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initValue() {
    timeTest.reset();
    timeTest.start();
  }

  Future<void> speak(String textToSpeech, {String language = 'en-US'}) async {
    try {
      // Set language to English (US)
      int resultLanguage = await flutterTts.setLanguage(language);
      if (resultLanguage != 1) {
        print('Failed to set language');
        return;
      }

      // Set pitch level
      int resultPitch = await flutterTts.setPitch(0.8);
      if (resultPitch != 1) {
        print('Failed to set pitch');
        return;
      }

      // Ensures that the speak completion is awaited
      await flutterTts.awaitSpeakCompletion(true);

      // Start speaking
      int resultSpeak = await flutterTts.speak(textToSpeech);
      if (resultSpeak != 1) {
        print('Failed to speak');
      }
    } catch (e) {
      print('Error occurred in TTS operation: $e');
    }
  }

  int getSumCorrect() {
    return listResult.where((element) => element.correct == true).length;
  }

  int getSumDefect() {
    return listResult.where((element) => element.correct == false).length;
  }

  Future<void> _handleChooseAnswer(CardModel answerCardModel) async {
    if (listCard[currentLearnIndex] == answerCardModel) {
      var answer =
          ResultModel(true, listCard[currentLearnIndex], answerCardModel);

      if (widget.isShowResult) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              contentPadding: const EdgeInsets.only(top: 0),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              scrollable: true,
              backgroundColor: const Color.fromARGB(255, 57, 255, 63),
              title: CustomText(
                text: '😍  Đúng',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  color: AppTheme.primaryBackgroundColorAppbar,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String question = (widget.isAnswerByTerm)
                            ? listCard[currentLearnIndex].define
                            : listCard[currentLearnIndex].term;
                        await speak(question);
                      },
                      child: CustomText(
                        text: (widget.isAnswerByTerm)
                            ? listCard[currentLearnIndex].define
                            : listCard[currentLearnIndex].term,
                        type: TextStyleEnum.large,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    CustomText(
                      text: 'Khớp với:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () async {
                        String question = (widget.isAnswerByTerm)
                            ? listCard[currentLearnIndex].term
                            : listCard[currentLearnIndex].define;
                        await speak(question);
                      },
                      child: CustomText(
                        text: (widget.isAnswerByTerm)
                            ? listCard[currentLearnIndex].term
                            : listCard[currentLearnIndex].define,
                        type: TextStyleEnum.large,
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    CustomButton(
                      height: 36,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      text: 'Tiếp tục',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
      setState(() {
        currentLearnIndex++;
        listResult.add(answer);
      });
    } else {
      var answer =
          ResultModel(false, listCard[currentLearnIndex], answerCardModel);
      if (widget.isShowResult) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              contentPadding: const EdgeInsets.only(top: 0),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              scrollable: true,
              backgroundColor: const Color.fromARGB(255, 255, 95, 8),
              title: CustomText(
                text: '😕  Hãy học thuật ngữ này!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  color: AppTheme.primaryBackgroundColorAppbar,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String question = (widget.isAnswerByTerm)
                            ? listCard[currentLearnIndex].define
                            : listCard[currentLearnIndex].term;
                        await speak(question);
                      },
                      child: CustomText(
                        text: (widget.isAnswerByTerm)
                            ? listCard[currentLearnIndex].define
                            : listCard[currentLearnIndex].term,
                        type: TextStyleEnum.large,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    CustomText(
                      text: 'Đáp án đúng:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color.fromARGB(255, 57, 255, 63),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () async {
                        String question = (widget.isAnswerByTerm)
                            ? listCard[currentLearnIndex].term
                            : listCard[currentLearnIndex].define;
                        await speak(question);
                      },
                      child: CustomText(
                        text: (widget.isAnswerByTerm)
                            ? listCard[currentLearnIndex].term
                            : listCard[currentLearnIndex].define,
                        type: TextStyleEnum.large,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Divider(
                      color: Colors.black87,
                      thickness: 0.5,
                    ),
                    CustomText(
                      text: 'Bạn cho rằng:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color.fromARGB(255, 255, 95, 8),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () async {
                        String question = (widget.isAnswerByTerm)
                            ? answerCardModel.term
                            : answerCardModel.define;
                        await speak(question);
                      },
                      child: CustomText(
                        text: (widget.isAnswerByTerm)
                            ? answerCardModel.term
                            : answerCardModel.define,
                        type: TextStyleEnum.large,
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    CustomButton(
                      height: 36,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      text: 'Tiếp tục',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
      setState(() {
        currentLearnIndex++;
        listResult.add(answer);
      });
    }

    if (currentLearnIndex == widget.sumLearnNumber) {
      _handleFinish();
    }
  }

  _handleFinish() async {
    timeTest.stop();
    int timeTestInSeconds = timeTest.elapsed.inSeconds;

    double sumCorrect = getSumCorrect() * 1.0;
    double sumDefect = getSumDefect() * 1.0;

    // save result
    UserModel currentUser = context.read<CurrentUserProvider>().currentUser!;
    ExamResultModel result = ExamResultModel(
      '',
      widget.topic.id,
      currentUser.userId,
      null,
      timeTestInSeconds,
      getSumCorrect(),
      null,
    );

    setState(() {
      dataChart = {
        'Đúng': sumCorrect,
        'Sai': sumDefect,
      };
    });

    var idResult = await examResultService.addResult(result);
    print('Lưu thành công: $idResult');
  }

  List<CardModel> getRandomAnswers(
      List<CardModel> list, CardModel exclude, int count) {
    List<CardModel> filteredList = List.from(list)..remove(exclude);

    filteredList.shuffle(Random());

    return filteredList.take(count).toList();
  }

  List<Widget> _buildViewResult() {
    int numberQuestion = 4;
    if (listCard.length < 4) {
      numberQuestion = 2;
    }

    List<CardModel> listResultOfThisQuestion = getRandomAnswers(
        listCard, listCard[currentLearnIndex], numberQuestion - 1);
    listResultOfThisQuestion.add(listCard[currentLearnIndex]);
    listResultOfThisQuestion.shuffle(Random());
    // for (var i in listResultOfThisQuestion) {
    //   print('card: ${i.toString()}');
    // }
    return listResultOfThisQuestion.map((e) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: GestureDetector(
          onTap: () {
            _handleChooseAnswer(e);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryBackgroundColor,
              border: Border.all(
                width: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AutoSizeText(
              (widget.isAnswerByTerm) ? e.term : e.define,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  _handleResetLearn() {
    setState(() {
      currentLearnIndex = 0;
      listResult.clear();
    });
    _initValue();
  }

  String _getTitleResult() {
    double percent = ((getSumCorrect() / widget.sumLearnNumber) * 100);
    if (percent < 100) {
      return 'Bạn đang tiến bộ!';
    }
    return 'Xuất sắc! Có vẻ bạn nắm rất vững bài!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackgroundColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Stack(
            children: [
              Container(
                color: Colors.grey,
                height: 3,
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    ...List.generate(widget.sumLearnNumber, (index) {
                      if (currentLearnIndex > index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            color: Colors.white,
                          ),
                        );
                      }
                      return Expanded(
                        child: Container(
                          height: 4,
                          color: Colors.transparent,
                        ),
                      );
                    }),
                  ],
                ),
              )
            ],
          ),
        ),
        title: CustomText(
          text:
              '${(currentLearnIndex + 1) > widget.sumLearnNumber ? currentLearnIndex : currentLearnIndex + 1}/${widget.sumLearnNumber}',
          type: TextStyleEnum.large,
        ),
        leading: IconButton(
          onPressed: () async {
            var result = await showOkCancelAlertDialog(
              context: context,
              title: "Bạn muốn kết thúc bài kiểm tra này?",
              message: 'Tiến trình kiểm tra sẽ không được lưu lại',
              okLabel: 'Kết thúc kiểm tra',
              cancelLabel: 'Hủy',
              style: AdaptiveStyle.iOS,
              isDestructiveAction: true,
            );
            if (result == OkCancelResult.ok) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(
            Icons.close,
            size: 28,
          ),
        ),
      ),
      body: (currentLearnIndex < widget.sumLearnNumber)
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () async {
                          String question = (widget.isAnswerByTerm)
                              ? listCard[currentLearnIndex].define
                              : listCard[currentLearnIndex].term;
                          await speak(question);
                        },
                        child: CustomText(
                          text: (widget.isAnswerByTerm)
                              ? listCard[currentLearnIndex].define
                              : listCard[currentLearnIndex].term,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ..._buildViewResult(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: CustomText(
                      text: _getTitleResult(),
                      type: TextStyleEnum.xxl,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    child: CustomText(
                      text: 'Kết quả của bạn',
                      type: TextStyleEnum.large,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              PieChart(
                                dataMap: dataChart,
                                chartType: ChartType.ring,
                                ringStrokeWidth: 14,
                                chartLegendSpacing: 28,
                                centerWidget: CustomText(
                                  text:
                                      '${((getSumCorrect() / widget.sumLearnNumber) * 100).toInt()}%',
                                  type: TextStyleEnum.large,
                                ),
                                legendOptions: const LegendOptions(
                                  showLegendsInRow: false,
                                  legendPosition: LegendPosition.right,
                                  showLegends: true,
                                  legendShape: BoxShape.circle,
                                  legendTextStyle: TextStyle(
                                    height: 2,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                baseChartColor:
                                    Colors.grey[50]!.withOpacity(0.15),
                                colorList: colorList,
                                chartValuesOptions: const ChartValuesOptions(
                                  showChartValues: false,
                                ),
                                totalValue: widget.sumLearnNumber.toDouble(),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                child: CustomText(
                                  text: dataChart['Đúng']!.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    width: 2,
                                    color:
                                        const Color.fromARGB(255, 255, 95, 8),
                                  ),
                                ),
                                child: CustomText(
                                  text: dataChart['Sai']!.toInt().toString(),
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 95, 8),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: CustomText(
                      text: 'Bước tiếp theo',
                      type: TextStyleEnum.large,
                    ),
                  ),
                  CustomButton(
                    onTap: () {
                      _handleResetLearn();
                    },
                    iconLeft: const Icon(
                      Icons.file_copy,
                      color: Colors.white,
                    ),
                    text: 'Làm bài kiểm tra mới',
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () {
                      //navigator to lean other
                      Map<String, dynamic> object = {
                        'listCard': widget.listCard,
                        'topic': widget.topic,
                        SettingLearnQuizEnum.sumLearnNumber.name:
                            widget.sumLearnNumber,
                        SettingLearnQuizEnum.isShowResult.name:
                            widget.isShowResult,
                        SettingLearnQuizEnum.isAnswerByTerm.name:
                            widget.isAnswerByTerm,
                      };
                      Navigator.popAndPushNamed(context, '/learn/typing',
                          arguments: object);
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            width: 2,
                            color: Colors.grey.withOpacity(0.5),
                          )),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.edit,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          CustomText(
                            text: 'Ôn luyện bằng chế độ gõ từ',
                            type: TextStyleEnum.large,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 24, bottom: 16),
                    child: CustomText(
                      text: 'Đáp án của bạn',
                      type: TextStyleEnum.large,
                    ),
                  ),
                  ...listResult.map((e) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.only(top: 32),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBackgroundColorAppbar,
                      ),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            constraints: const BoxConstraints(
                              minHeight: 140,
                            ),
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomText(
                                  text: widget.isAnswerByTerm
                                      ? e.cardQuestion.define
                                      : e.cardQuestion.term,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check,
                                            color: Color.fromARGB(
                                                255, 57, 255, 63),
                                            size: 28,
                                          ),
                                          CustomText(
                                            text: widget.isAnswerByTerm
                                                ? e.cardQuestion.term
                                                : e.cardQuestion.define,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromARGB(
                                                  255, 57, 255, 63),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!e.correct)
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.close,
                                              color: Color.fromARGB(
                                                  255, 255, 95, 8),
                                              size: 28,
                                            ),
                                            CustomText(
                                              text: widget.isAnswerByTerm
                                                  ? e.cardResult.term
                                                  : e.cardResult.define,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromARGB(
                                                    255, 255, 95, 8),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                                color: (e.correct)
                                    ? Color.fromARGB(255, 63, 221, 69)
                                    : const Color.fromARGB(255, 255, 95, 8)),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                CustomText(
                                  text: e.correct ? 'Đúng' : 'Sai',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  })
                ],
              ),
            ),
    );
  }
}
