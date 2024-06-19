import 'dart:math';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/setting_learn_flashcards_enum.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/card.dart';
import 'package:quizletapp/models/exam_result.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/models/user.dart';
import 'package:quizletapp/services/providers/current_user_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/button.dart';
import 'package:quizletapp/widgets/button_active.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class LearnFlashCards extends StatefulWidget {
  List<CardModel> listCard;
  TopicModel topic;
  LearnFlashCards({
    required this.listCard,
    required this.topic,
    super.key,
  });

  @override
  State<LearnFlashCards> createState() => _LearnFlashCardsState();
}

class _LearnFlashCardsState extends State<LearnFlashCards> {
  final FlutterTts flutterTts = FlutterTts();

  late AppinioSwiperController appinioSwiperController;
  var cardKeys = <int, GlobalKey<FlipCardState>>{};
  late GlobalKey<FlipCardState> lastFlipped;

  int _settingIndex = 1;
  bool isMix = false;
  bool isVolume = false;
  bool isEnd = false;
  bool isAutoPlay = false;
  double positionValueChanges = 0;

  List<CardSide> listCardSide = [CardSide.FRONT, CardSide.BACK];

  FocusNode autoPlayFocus = FocusNode();

  List<CardModel> listLeft = [];
  List<CardModel> listRight = [];
  List<CardModel> listShow = [];

  int currentCardIndex = 0;
  bool cardIsFlipped = false;
  bool isFinishLearn = false;

  Map<String, double> dataMap = {
    'Đã biết': 0,
    'Đang học': 0,
    'Còn lại': 0,
  };

  final colorList = <Color>[
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.grey[50]!.withOpacity(0.15),
  ];

  @override
  void dispose() {
    appinioSwiperController.dispose();
    autoPlayFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    listShow = List.from(widget.listCard);
    super.initState();
    initValueState();
    appinioSwiperController = AppinioSwiperController();
  }

  Future<void> initValueState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool mix =
          prefs.getBool(SettingLearnFlashCardEnum.isMix.name) ?? false;
      final bool volume =
          prefs.getBool(SettingLearnFlashCardEnum.isVolume.name) ?? false;
      final int index =
          prefs.getInt(SettingLearnFlashCardEnum.indexFront.name) ?? 1;

      setState(() {
        isMix = mix;
        isVolume = volume;
        _settingIndex = index;
      });

      if (mix) {
        setState(() {
          listShow.shuffle(Random());
        });
      }

      if (isVolume &&
          appinioSwiperController.cardIndex != null &&
          appinioSwiperController.cardIndex! < listShow.length) {
        final String textToSpeak = _settingIndex == 0
            ? listShow[appinioSwiperController.cardIndex!].term
            : listShow[appinioSwiperController.cardIndex!].define;
        await speak(textToSpeak);
      }
    } catch (e) {
      print('Lỗi init: $e');
    }
  }

  void rollBack(CardModel itemRollBack) {
    if (listLeft.contains(itemRollBack)) {
      setState(() {
        listLeft.remove(itemRollBack);
      });
      print('remove left');
    } else if (listRight.contains(itemRollBack)) {
      setState(() {
        listRight.remove(itemRollBack);
      });
      print('remove right');
    }
  }

  void setSettingIndex(int index) async {
    setState(() {
      _settingIndex = index;
    });
    print('change index: $_settingIndex');
  }

  double getOpacity(double position) {
    double absPosition = position.abs();

    if (absPosition > 2.5) {
      return 1.0;
    }

    if (absPosition < 0.1) {
      return 0.0;
    }

    return (absPosition - 0.1) / (2.4);
  }

  int getOpacityInt(double position) {
    double absPosition = position.abs();

    if (absPosition > 2.5) {
      return 255;
    }

    if (absPosition < 0.1) {
      return 1;
    }

    double linearMapping = ((absPosition - 0.1) / 2.4) * (255 - 1) + 1;

    return linearMapping.round();
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

  Future<void> _onSpeak() async {
    bool readTermFirst = _settingIndex == 0;

    if (readTermFirst) {
      await _readTermFirst();
    } else {
      await _readDefinitionFirst();
    }
  }

  Future<void> _readTermFirst() async {
    if (cardKeys[currentCardIndex]!.currentState?.isFront ?? false) {
      await flutterTts.speak(listShow[currentCardIndex].term);
      await Future.delayed(const Duration(seconds: 2));
      await cardKeys[currentCardIndex]!
          .currentState!
          .toggleCard()
          .whenComplete(() => Future.delayed(Durations.extralong2));
    }
    await flutterTts.speak(listShow[currentCardIndex].define);
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _readDefinitionFirst() async {
    if (cardKeys[currentCardIndex]!.currentState?.isFront ?? false) {
      await flutterTts.speak(listShow[currentCardIndex].define);
      await Future.delayed(const Duration(seconds: 2));
      await cardKeys[currentCardIndex]
          ?.currentState
          ?.toggleCard()
          .whenComplete(() => Future.delayed(Durations.extralong2));
    }
    await flutterTts.speak(listShow[currentCardIndex].term);
    await Future.delayed(const Duration(seconds: 2));
  }

  void updateCardIsFlipped() => cardIsFlipped = !cardIsFlipped;

  void _autoPlay() {
    if (!isAutoPlay) {
      setState(() => isAutoPlay = true);
      _playCards();
    } else {
      setState(() => isAutoPlay = false);
      flutterTts.stop();
    }
  }

  Future<void> _playCards() async {
    for (int i = currentCardIndex; i < listShow.length; i++) {
      if (!isAutoPlay) break;
      await _onSpeak();
      if (!isAutoPlay) break;
      await appinioSwiperController
          .swipeLeft()
          .whenComplete(() => Future.delayed(Durations.extralong2));
    }
    setState(() => isAutoPlay = false);
  }

  void _onSwipeEnd(
      int previousIndex, int targetIndex, SwiperActivity activity) {
    print(
        'onSwipeEnd: previousIndex: $previousIndex, targetIndex: $targetIndex, possition: ${activity.currentOffset.dx}');
    if (previousIndex == targetIndex) return;
    if (!isAutoPlay) speakIfIsVolume();
    if (previousIndex > targetIndex) {
      rollBack(listShow[targetIndex]);
    } else {
      if (activity.currentOffset.dx < 0) {
        setState(() {
          listLeft.add(listShow[previousIndex]);
          positionValueChanges = 0;
        });
      } else {
        setState(() {
          listRight.add(listShow[previousIndex]);
          positionValueChanges = 0;
        });
      }
    }
    if (currentCardIndex == listShow.length) {
      _handleFinishLearn();
    }
  }

  Future<void> speakIfIsVolume() async {
    if (isVolume) {
      if (_settingIndex == 0 &&
              cardKeys[currentCardIndex]!.currentState?.isFront == true ||
          _settingIndex != 0 &&
              cardKeys[currentCardIndex]!.currentState?.isFront == false) {
        await flutterTts.speak(listShow[currentCardIndex].term);
        return;
      }
      await flutterTts.speak(listShow[currentCardIndex].define);
    }
  }

  Future<void> _onFlipDone(bool isFront) async {
    if (isVolume) {
      if (_settingIndex == 0 && isFront || _settingIndex != 0 && !isFront) {
        await flutterTts.speak(listShow[currentCardIndex].define);
        return;
      }
      await flutterTts.speak(listShow[currentCardIndex].term);
    }
  }

  _handleFinishLearn() {
    double studied = listRight.length * 1.0;
    double studying = listLeft.length * 1.0;
    double remaining =
        (listShow.length - (listLeft.length + listRight.length)) * 1.0;

    print("đã biết: $studied ; Đang học: $studying ; còn lại: $remaining");
    setState(() {
      dataMap = {
        "Đã biết": studied,
        "Đang học": studying,
        "Còn lại": remaining,
      };
      isFinishLearn = true;
    });
  }

  _handleShuffledCards(bool state) {
    if (state) {
      setState(() {
        listShow.shuffle(Random());
      });
      return;
    }
    setState(() {
      listShow = List.from(widget.listCard);
    });
  }

  _handleResetLearn() {
    setState(() {
      isFinishLearn = false;
      currentCardIndex = 0;
      listLeft.clear();
      listRight.clear();
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
                    ...List.generate(listShow.length, (index) {
                      if (appinioSwiperController.cardIndex != null &&
                          appinioSwiperController.cardIndex! > index) {
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
              '${(currentCardIndex + 1) > listShow.length ? currentCardIndex : currentCardIndex + 1}/${listShow.length}',
          type: TextStyleEnum.large,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close,
            size: 28,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    backgroundColor: AppTheme.primaryBackgroundColor,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.9,
                        widthFactor: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 44,
                                height: 6,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(160, 127, 144, 155),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              CustomText(
                                text: 'Tùy chọn',
                                type: TextStyleEnum.xl,
                              ),
                              Divider(
                                color: Colors.grey.shade800,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 40),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ButtonActive(
                                          initValue: isMix,
                                          titleText: 'Trộn thẻ',
                                          onChange: (state) async {
                                            setState(() {
                                              isMix = state;
                                            });
                                            final SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            await prefs.setBool(
                                                SettingLearnFlashCardEnum
                                                    .isMix.name,
                                                state);
                                            _handleShuffledCards(state);
                                          },
                                        ),
                                        ButtonActive(
                                          initValue: isVolume,
                                          titleText: 'Phát bản thu',
                                          iconData: Icons.volume_up,
                                          onChange: (state) async {
                                            setState(() {
                                              isVolume = state;
                                            });
                                            final SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            await prefs.setBool(
                                                SettingLearnFlashCardEnum
                                                    .isVolume.name,
                                                state);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    CustomText(
                                      text: 'Thiết lập thẻ ghi nhớ',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    CustomText(text: 'Mặt trước'),
                                    Container(
                                      margin: const EdgeInsets.only(top: 16),
                                      child: ToggleSwitch(
                                        animate: true,
                                        animationDuration: 200,
                                        minWidth: double.infinity,
                                        cornerRadius: 20.0,
                                        activeBgColors: [
                                          [Colors.green[800]!],
                                          [Colors.red[800]!]
                                        ],
                                        activeFgColor: Colors.white,
                                        inactiveBgColor:
                                            Colors.grey.withOpacity(0.3),
                                        inactiveFgColor: Colors.white,
                                        initialLabelIndex: _settingIndex,
                                        totalSwitches: 2,
                                        labels: const [
                                          'Thuật ngữ',
                                          'Định nghĩa'
                                        ],
                                        customTextStyles: const [
                                          TextStyle(
                                              fontWeight: FontWeight.w500),
                                          TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ],
                                        radiusStyle: true,
                                        onToggle: (index) async {
                                          final SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          if (index == 0) {
                                            setSettingIndex(0);
                                            await prefs.setInt(
                                                SettingLearnFlashCardEnum
                                                    .indexFront.name,
                                                0);
                                          } else {
                                            setSettingIndex(1);
                                            await prefs.setInt(
                                                SettingLearnFlashCardEnum
                                                    .indexFront.name,
                                                1);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: (!isFinishLearn)
          ? Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 48,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 6,
                            ),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadiusDirectional.only(
                                bottomEnd: Radius.circular(999),
                                topEnd: Radius.circular(999),
                              ),
                              border: Border(
                                top: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 255, 95, 8)),
                                right: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 255, 95, 8)),
                                bottom: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 255, 95, 8)),
                              ),
                            ),
                            child: CustomText(
                              text: '${listLeft.length}',
                              type: TextStyleEnum.large,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 95, 8)),
                            ),
                          ),
                          if (positionValueChanges < 0)
                            Positioned.fill(
                              child: Container(
                                width: 48,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 95, 8)
                                      .withOpacity(
                                          getOpacity(positionValueChanges)),
                                  borderRadius:
                                      const BorderRadiusDirectional.only(
                                    bottomEnd: Radius.circular(999),
                                    topEnd: Radius.circular(999),
                                  ),
                                  border: const Border(
                                    top: BorderSide(
                                        width: 1,
                                        color: Color.fromARGB(255, 255, 95, 8)),
                                    right: BorderSide(
                                        width: 1,
                                        color: Color.fromARGB(255, 255, 95, 8)),
                                    bottom: BorderSide(
                                        width: 1,
                                        color: Color.fromARGB(255, 255, 95, 8)),
                                  ),
                                ),
                                child: CustomText(
                                  text: '+1',
                                  type: TextStyleEnum.large,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 48,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 6,
                            ),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadiusDirectional.only(
                                bottomStart: Radius.circular(999),
                                topStart: Radius.circular(999),
                              ),
                              border: Border(
                                top: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 57, 255, 63)),
                                left: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 57, 255, 63)),
                                bottom: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 57, 255, 63)),
                              ),
                            ),
                            child: CustomText(
                              text: '${listRight.length}',
                              type: TextStyleEnum.large,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 57, 255, 63)),
                            ),
                          ),
                          if (positionValueChanges > 0)
                            Positioned.fill(
                              child: Container(
                                width: 48,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 57, 255, 63)
                                      .withOpacity(
                                          getOpacity(positionValueChanges)),
                                  borderRadius:
                                      const BorderRadiusDirectional.only(
                                    bottomStart: Radius.circular(999),
                                    topStart: Radius.circular(999),
                                  ),
                                  border: const Border(
                                    top: BorderSide(
                                        width: 1,
                                        color:
                                            Color.fromARGB(255, 57, 255, 63)),
                                    left: BorderSide(
                                        width: 1,
                                        color:
                                            Color.fromARGB(255, 57, 255, 63)),
                                    bottom: BorderSide(
                                        width: 1,
                                        color:
                                            Color.fromARGB(255, 57, 255, 63)),
                                  ),
                                ),
                                child: CustomText(
                                  text: '+1',
                                  type: TextStyleEnum.large,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: AppinioSwiper(
                      initialIndex: 0,
                      controller: appinioSwiperController,
                      backgroundCardScale: 1,
                      backgroundCardOffset:
                          Offset.fromDirection(BorderSide.strokeAlignCenter),
                      cardCount: listShow.length,
                      onCardPositionChanged: (position) {
                        setState(() {
                          positionValueChanges = position.angle;
                        });
                      },
                      onSwipeCancelled: (activity) {
                        setState(() {
                          positionValueChanges = 0;
                        });
                      },
                      onSwipeBegin: (previousIndex, targetIndex, activity) {
                        print(
                            'onSwipeBegin: previousIndex: $previousIndex, targetIndex: $targetIndex, possition: ${activity.currentOffset.dx}');

                        if (previousIndex != targetIndex) {
                          setState(() {
                            currentCardIndex = targetIndex;
                          });
                        }
                      },
                      onSwipeEnd: (previousIndex, targetIndex, activity) {
                        _onSwipeEnd(previousIndex, targetIndex, activity);
                      },
                      cardBuilder: (context, index) {
                        cardKeys.putIfAbsent(
                            index, () => GlobalKey<FlipCardState>());
                        GlobalKey<FlipCardState> thisCard = cardKeys[index]!;
                        return FlipCard(
                          key: thisCard,
                          fill: Fill.fillBack,
                          side: CardSide.FRONT,
                          flipOnTouch: true,
                          onFlipDone: (isFront) {
                            _onFlipDone(isFront);
                          },
                          front: Stack(
                            children: [
                              Card(
                                shape: BeveledRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 40),
                                  decoration: BoxDecoration(
                                    border: (positionValueChanges == 0 ||
                                            appinioSwiperController.cardIndex !=
                                                index)
                                        ? null
                                        : Border.all(
                                            width: 2,
                                            color: (positionValueChanges > 0)
                                                ? const Color.fromARGB(
                                                    255, 57, 255, 63)
                                                : const Color.fromARGB(
                                                    255, 255, 169, 40),
                                          ),
                                    color:
                                        AppTheme.primaryBackgroundColorAppbar,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: AutoSizeText(
                                    (_settingIndex == 0)
                                        ? (listShow[index].term.isEmpty)
                                            ? '...'
                                            : listShow[index].term
                                        : (widget
                                                .listCard[index].define.isEmpty)
                                            ? '...'
                                            : listShow[index].define,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(1 -
                                            getOpacity(positionValueChanges)),
                                        fontSize: 28),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                top: 16,
                                child: IconButton(
                                  onPressed: () async {
                                    if (_settingIndex == 0) {
                                      await speak(listShow[index].term);
                                      return;
                                    }
                                    await speak(listShow[index].define);
                                  },
                                  icon: const Icon(
                                    Icons.volume_up_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              (positionValueChanges > 0)
                                  ? Positioned.fill(
                                      child: Center(
                                        child: CustomText(
                                          text: 'Đã biết',
                                          type: TextStyleEnum.xxl,
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  getOpacityInt(
                                                      positionValueChanges),
                                                  14,
                                                  251,
                                                  25)),
                                        ),
                                      ),
                                    )
                                  : Positioned.fill(
                                      child: Center(
                                        child: CustomText(
                                          text: 'Đang học',
                                          type: TextStyleEnum.xxl,
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  getOpacityInt(
                                                      positionValueChanges),
                                                  255,
                                                  95,
                                                  8)),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          back: Stack(
                            children: [
                              Card(
                                shape: BeveledRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 40),
                                  decoration: BoxDecoration(
                                    border: (positionValueChanges == 0 ||
                                            appinioSwiperController.cardIndex !=
                                                index)
                                        ? null
                                        : Border.all(
                                            width: 2,
                                            color: (positionValueChanges > 0)
                                                ? const Color.fromARGB(
                                                    255, 57, 255, 63)
                                                : const Color.fromARGB(
                                                    255, 255, 169, 40)),
                                    color:
                                        AppTheme.primaryBackgroundColorAppbar,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: AutoSizeText(
                                    (_settingIndex == 0)
                                        ? (widget
                                                .listCard[index].define.isEmpty)
                                            ? '...'
                                            : listShow[index].define
                                        : (listShow[index].term.isEmpty)
                                            ? '...'
                                            : listShow[index].term,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(1 -
                                            getOpacity(positionValueChanges)),
                                        fontSize: 28),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                top: 16,
                                child: IconButton(
                                  onPressed: () async {
                                    if (_settingIndex == 1) {
                                      await speak(listShow[index].term);
                                      return;
                                    }
                                    await speak(listShow[index].define);
                                  },
                                  icon: const Icon(
                                    Icons.volume_up_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              (positionValueChanges > 0)
                                  ? Positioned.fill(
                                      child: Center(
                                        child: CustomText(
                                          text: 'Đã biết',
                                          type: TextStyleEnum.xxl,
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  getOpacityInt(
                                                      positionValueChanges),
                                                  14,
                                                  251,
                                                  25)),
                                        ),
                                      ),
                                    )
                                  : Positioned.fill(
                                      child: Center(
                                        child: CustomText(
                                          text: 'Đang học',
                                          type: TextStyleEnum.xxl,
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  getOpacityInt(
                                                      positionValueChanges),
                                                  255,
                                                  95,
                                                  8)),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () async {
                          if (currentCardIndex > 0) {
                            await appinioSwiperController.unswipe();
                          }
                        },
                        icon: Icon(
                          Icons.reply,
                          color: (appinioSwiperController.cardIndex == 0)
                              ? Colors.grey.withOpacity(0.5)
                              : Colors.white,
                          size: 28,
                        ),
                      ),
                      CustomText(text: 'Chạm vào thẻ để lật'),
                      IconButton(
                        focusNode: autoPlayFocus,
                        focusColor: Colors.grey,
                        onPressed: () {
                          _autoPlay();
                        },
                        icon: Icon(
                          (isAutoPlay) ? Icons.pause : Icons.play_arrow,
                          color: (appinioSwiperController.cardIndex ==
                                  listShow.length)
                              ? Colors.grey.withOpacity(0.5)
                              : Colors.white,
                          size: 28,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(
                    height: 44,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomText(
                          text:
                              'Bạn đang làm rất tuyệt! Hãy tiếp tục tập trung vào các thuật ngữ khó.',
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child:
                            Image.asset('assets/images/image_finish_learn.png'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 44,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            PieChart(
                              dataMap: dataMap,
                              chartType: ChartType.ring,
                              ringStrokeWidth: 14,
                              chartLegendSpacing: 28,
                              centerWidget:
                                  (listShow.length == listRight.length)
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.greenAccent,
                                          size: 36,
                                        )
                                      : CustomText(
                                          text:
                                              '${((listRight.length / listShow.length) * 100).toInt()}%',
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
                              totalValue: listShow.length.toDouble(),
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
                                text: dataMap['Đã biết']!.toInt().toString(),
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
                                  color: Color.fromARGB(255, 255, 95, 8),
                                ),
                              ),
                              child: CustomText(
                                text: dataMap['Đang học']!.toInt().toString(),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 95, 8),
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
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              child: CustomText(
                                text: dataMap['Còn lại']!.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.white,
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          onTap: () {
                            Navigator.popAndPushNamed(
                                context, '/learn/quiz/settings',
                                arguments: widget.topic);
                          },
                          text: 'Làm bài kiểm tra thử',
                          iconLeft: const Icon(
                            Icons.edit_document,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: () {
                            _handleResetLearn();
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
                            child: CustomText(
                              text: 'Đặt lại thẻ ghi nhớ',
                              type: TextStyleEnum.large,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
