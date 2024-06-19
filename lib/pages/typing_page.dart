import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:quizletapp/enums/setting_learn_quiz.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/card.dart';
import 'package:quizletapp/models/result.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/button.dart';
import 'package:quizletapp/widgets/text.dart';

class TypingPage extends StatefulWidget {
  final TopicModel topic;
  final List<CardModel> listCard;
  final int sumLearnNumber;
  final bool isShowResult;
  final bool isAnswerByTerm;
  const TypingPage({
    required this.topic,
    required this.listCard,
    required this.sumLearnNumber,
    required this.isShowResult,
    required this.isAnswerByTerm,
    super.key,
  });

  @override
  State<TypingPage> createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  late List<CardModel> listCard;
  List<ResultModel> listResult = [];
  int currentLearnIndex = 0;

  Map<String, double> dataChart = {
    'Đúng': 0,
    'Sai': 0,
  };

  final colorList = <Color>[
    Colors.greenAccent,
    Colors.orangeAccent,
  ];

  final TextEditingController _textResultController = TextEditingController();
  final FocusNode _inputAnswerFocus = FocusNode();
  bool isHasAnswer = false;

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    listCard = List.from(widget.listCard);
    listCard.shuffle(Random());
    _initValue();
    _textResultController.addListener(_onTextChange);
    super.initState();
  }

  @override
  void dispose() {
    _textResultController.dispose();
    _inputAnswerFocus.dispose();
    _textResultController.removeListener(_onTextChange);
    super.dispose();
  }

  void _initValue() {
    _inputAnswerFocus.requestFocus();
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

  void _onTextChange() {
    setState(() {
      isHasAnswer = _textResultController.text.trim().isNotEmpty;
    });
  }

  int getSumCorrect() {
    return listResult.where((element) => element.correct == true).length;
  }

  int getSumDefect() {
    return listResult.where((element) => element.correct == false).length;
  }

  bool _checkAnswer(String answer) {
    String result = widget.isAnswerByTerm
        ? listCard[currentLearnIndex].term
        : listCard[currentLearnIndex].define;

    return result.trim().toLowerCase() == answer.trim().toLowerCase();
  }

  Future<void> _handleSubmitAnswer() async {
    String answer = _textResultController.text;
    if (_checkAnswer(answer)) {
      var answerModel = ResultModel(
          true, listCard[currentLearnIndex], CardModel('', answer, answer));

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
        listResult.add(answerModel);
        _textResultController.text = '';
        _inputAnswerFocus.requestFocus();
        currentLearnIndex++;
      });
    } else {
      var answerModel = ResultModel(
          false, listCard[currentLearnIndex], CardModel('', answer, answer));
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
                        await speak(answer);
                      },
                      child: CustomText(
                        text: answer,
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
        listResult.add(answerModel);
        _textResultController.text = '';
        _inputAnswerFocus.requestFocus();
        currentLearnIndex++;
      });
    }

    if (currentLearnIndex == widget.sumLearnNumber) {
      double sumCorrect = getSumCorrect() * 1.0;
      double sumDefect = getSumDefect() * 1.0;
      setState(() {
        dataChart = {
          'Đúng': sumCorrect,
          'Sai': sumDefect,
        };
      });
    }
  }

  Widget _buildViewResult() {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              TextField(
                controller: _textResultController,
                focusNode: _inputAnswerFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  if (!isHasAnswer) return;
                  _handleSubmitAnswer();
                },
                cursorColor: Colors.white,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: (widget.isAnswerByTerm)
                      ? 'Điền thuật ngữ'
                      : 'Điền định nghĩa',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 4.0, color: Colors.white),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                  ),
                ),
              ),
              if (!isHasAnswer)
                Positioned(
                  right: -4,
                  top: 0,
                  bottom: 0,
                  child: TextButton(
                    onPressed: () {
                      _handleSubmitAnswer();
                    },
                    child: CustomText(
                      text: 'Không biết',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 168, 137, 219),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        IconButton(
          style: ButtonStyle(
            backgroundColor: isHasAnswer
                ? const MaterialStatePropertyAll(AppTheme.primaryColor)
                : const MaterialStatePropertyAll(Colors.grey),
          ),
          onPressed: () {
            if (!isHasAnswer) return;
            _handleSubmitAnswer();
          },
          icon: Icon(
            Icons.arrow_upward_rounded,
            color: isHasAnswer ? Colors.white : Colors.white60,
          ),
        ),
      ],
    );
  }

  _handleResetLearn() {
    setState(() {
      currentLearnIndex = 0;
      listResult.clear();
      _textResultController.text = '';
      _inputAnswerFocus.requestFocus();
    });
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
                    child: _buildViewResult(),
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
                      Navigator.popAndPushNamed(context, '/learn/flashcards',
                          arguments: {
                            'listCard': widget.topic.listCard,
                            'topic': widget.topic,
                          });
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          width: 2,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.filter_none_rounded,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          CustomText(
                            text: 'Ôn luyện bằng thẻ ghi nhớ',
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
