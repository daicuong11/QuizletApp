import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/card.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';
import 'package:quizletapp/services/providers/current_user_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/button_listtile.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:toastification/toastification.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:permission_handler/permission_handler.dart';

class TopicDetailPage extends StatefulWidget {
  final String topicId;
  const TopicDetailPage({
    required this.topicId,
    super.key,
  });

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  final FlutterTts flutterTts = FlutterTts();
  TopicService topicService = TopicService();
  bool isLoading = false;
  TopicModel? topic;
  int _current = 0;
  int _currentPicked = 0;
  List<CardModel> listCardPicked = [];
  List<List<CardModel>> listSort = [[], []];

  int _currentIndexSort = 0;

  final _controller = CarouselController();

  @override
  void initState() {
    _fetchTopic();
    super.initState();
  }

  String removeDiacritics(String input) {
    String result = input.toLowerCase();

    result = result.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    result = result.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    result = result.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    result = result.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    result = result.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    result = result.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    result = result.replaceAll(RegExp(r'[đ]'), 'd');
    result = result.replaceAll(RegExp(r'[ñ]'), 'n');
    result = result.replaceAll(RegExp(r'[ç]'), 'c');

    result = result.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
    result = result.replaceAll(' ', '_');

    return result;
  }

  void writeCsvFile(List<CardModel> dataList, {String fileName = 'abc'}) async {
    List<List<dynamic>> rows = [];

    for (var card in dataList) {
      rows.add([card.term, card.define]);
    }

    bool permissionGranted = await _requestPermissions();
    if (!permissionGranted) {
      toastification.show(
        context: context,
        title: CustomText(
          text: 'Xuất file csv thất bại',
          type: TextStyleEnum.large,
        ),
        style: ToastificationStyle.fillColored,
        foregroundColor: Colors.white,
        showProgressBar: false,
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );

      Navigator.pop(context);
      return;
    }

    Directory? downloadDir = await _getDownloadDirectory();
    if (downloadDir == null) {
      print('Could not get the download directory');
      toastification.show(
        context: context,
        title: CustomText(
          text: 'Xuất file csv thất bại',
          type: TextStyleEnum.large,
        ),
        style: ToastificationStyle.fillColored,
        foregroundColor: Colors.white,
        showProgressBar: false,
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );

      Navigator.pop(context);
      return;
    }
    // Save the CSV file
    String filePath = '${downloadDir.path}/$fileName.csv';
    File file = File(filePath);
    String csv = const ListToCsvConverter().convert(rows);
    file.writeAsStringSync(csv);

    print('CSV file saved to Download folder: $filePath');

    toastification.show(
      context: context,
      title: CustomText(
        text: 'Xuất file csv thành công',
        type: TextStyleEnum.large,
      ),
      style: ToastificationStyle.fillColored,
      foregroundColor: Colors.white,
      showProgressBar: false,
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
    );

    Navigator.pop(context);
  }

  Future<bool> _requestPermissions() async {
    if (await Permission.storage.status.isGranted) {
      return true;
    } else {
      await Permission.storage.request();
      return false;
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    Directory? appDocDir = await getDownloadsDirectory();
    if (appDocDir == null) {
      return null;
    }
    return appDocDir;
  }

  Future<void> speak(String textToSpeech) async {
    try {
      // Set language to English (US)
      var resultLanguage = await flutterTts.setLanguage('en-US');
      if (resultLanguage == 1) {
        print('Language set to English (US)');
      } else {
        print('Failed to set language');
        return;
      }
      // Set pitch level
      var resultPitch = await flutterTts.setPitch(0.8);
      if (resultPitch == 1) {
        print('Pitch set to 0.8');
      } else {
        print('Failed to set pitch');
        return;
      }

      // Start speaking
      var resultSpeak = await flutterTts.speak(textToSpeech);
      if (resultSpeak == 1) {
        print('Speaking initiated');
      } else {
        print('Failed to speak');
        return;
      }
    } catch (e) {
      print('Error occurred in TTS operation: $e');
    }
  }

  bool _checkPicked(CardModel card) {
    return listCardPicked.contains(card);
  }

  Future<void> _fetchTopic() async {
    setState(() {
      isLoading = true;
      _currentIndexSort = 0;
    });
    topic = await topicService.getTopicById(widget.topicId);
    if (topic != null) {
      listSort = [
        topic!.listCard,
        TopicService.sortTopicByABC(topic!.listCard)
      ];
    }

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
                if (topic?.userId ==
                    context.read<CurrentUserProvider>().currentUser?.userId)
                  InkWell(
                    onTap: () async {
                      TopicModel topicClone = TopicModel.copy(topic!);
                      topicClone.listCard = listSort[0];
                      var result = await Navigator.popAndPushNamed(
                          context, '/topic/edit',
                          arguments: topicClone);
                      if (result == 0) {
                        //is updated this topic
                        _fetchTopic();
                      } else if (result == 1) {
                        //is deleted this topic
                        Navigator.pop(context);
                        return;
                      }
                    },
                    child: ListTile(
                      minVerticalPadding: 20,
                      title: CustomText(
                        text: 'Sửa học phần',
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
                    // TopicModel topicClone = TopicModel.copy(topic!);
                    var result = await Navigator.popAndPushNamed(
                        context, '/topic/add',
                        arguments: topic!);
                  },
                  child: ListTile(
                    minVerticalPadding: 20,
                    title: CustomText(
                      text: 'Thêm vào thư mục',
                      type: TextStyleEnum.large,
                    ),
                    leading: const Icon(
                      Icons.folder_copy_outlined,
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
                    writeCsvFile(topic!.listCard,
                        fileName: removeDiacritics(topic!.title));
                  },
                  child: ListTile(
                    minVerticalPadding: 20,
                    title: CustomText(
                      text: 'Xuất file csv',
                      type: TextStyleEnum.large,
                    ),
                    leading: const Icon(
                      Icons.folder_copy_outlined,
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
                    Navigator.popAndPushNamed(context, '/topic/info',
                        arguments: topic);
                  },
                  child: ListTile(
                    minVerticalPadding: 20,
                    title: CustomText(
                      text: 'Thông tin học phần',
                      type: TextStyleEnum.large,
                    ),
                    leading: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (topic?.userId ==
                context.read<CurrentUserProvider>().currentUser?.userId)
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
                        title: 'Bạn chắc chắn muốn xóa học phần này?',
                      );
                      if (chooseResult == OkCancelResult.ok) {
                        await topicService.deleteTopic(topic!.id);
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      }
                    },
                    child: ListTile(
                      minVerticalPadding: 20,
                      title: CustomText(
                        text: 'Xóa học phần',
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
        onRefresh: _fetchTopic,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: (topic != null)
                ? Skeletonizer(
                    enabled: isLoading,
                    containersColor: AppTheme.primaryColorSkeletonContainer,
                    child: Column(
                      children: [
                        const Row(),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              CarouselSlider.builder(
                                carouselController: _controller,
                                itemCount: listSort[0].length,
                                itemBuilder: (context, index, realIndex) {
                                  return FlipCard(
                                    fill: Fill.fillBack,
                                    direction: FlipDirection.VERTICAL,
                                    side: CardSide.FRONT,
                                    front: Stack(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppTheme
                                                .primaryBackgroundColorAppbar,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: AutoSizeText(
                                            (listSort[0][index].term.isEmpty)
                                                ? '...'
                                                : listSort[0][index].term,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: IconButton(
                                            onPressed: () {
                                              List<CardModel> listACard =
                                                  List.empty(growable: true);
                                              listACard.add(listSort[0][index]);
                                              TopicModel topicACard =
                                                  TopicModel.copy(topic!);
                                              topicACard.listCard = listACard;
                                              Navigator.pushNamed(
                                                  context, '/learn/flashcards',
                                                  arguments: {
                                                    'listCard': listACard,
                                                    'topic': topicACard
                                                  });
                                            },
                                            icon: const Icon(
                                              FontAwesomeIcons.expand,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    back: Stack(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppTheme
                                                .primaryBackgroundColorAppbar,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: AutoSizeText(
                                            (listSort[0][index].define.isEmpty)
                                                ? '...'
                                                : listSort[0][index].define,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: IconButton(
                                            onPressed: () {
                                              List<CardModel> listACard =
                                                  List.empty(growable: true);
                                              listACard.add(listSort[0][index]);
                                              TopicModel topicACard =
                                                  TopicModel.copy(topic!);
                                              topicACard.listCard = listACard;
                                              Navigator.pushNamed(
                                                  context, '/learn/flashcards',
                                                  arguments: {
                                                    'listCard': listACard,
                                                    'topic': topicACard
                                                  });
                                            },
                                            icon: const Icon(
                                              FontAwesomeIcons.expand,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                    initialPage: _current,
                                    height: 200,
                                    autoPlayInterval:
                                        const Duration(seconds: 2),
                                    enlargeCenterPage: true,
                                    scrollDirection: Axis.horizontal,
                                    enableInfiniteScroll: false,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        _current = index;
                                      });
                                    }),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 20, bottom: 4),
                                child:
                                    _buildCarouseIndicator(listSort[0].length),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Row(),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: CustomText(
                                  text: topic!.title,
                                  type: TextStyleEnum.xl,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  direction: Axis.horizontal,
                                  children: [
                                    Row(),
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      direction: Axis.horizontal,
                                      spacing: 8,
                                      children: [
                                        const CircleAvatar(
                                          backgroundImage:
                                              AppTheme.defaultAvatar,
                                          backgroundColor: Colors.grey,
                                          radius: 18,
                                        ),
                                        CustomText(
                                          text:
                                              topic!.userCreate?.username ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          color: Colors.grey.shade600
                                              .withOpacity(0.5),
                                          width: 1,
                                          height: 30,
                                        ),
                                        CustomText(
                                          text:
                                              '${listSort[0].length} thuật ngữ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (topic!.description.isNotEmpty)
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.only(top: 16),
                                  child: CustomText(
                                    text: topic!.description,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              const SizedBox(
                                height: 12,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (_currentPicked == 0) {
                                    await Navigator.pushNamed(
                                        context, '/learn/flashcards',
                                        arguments: {
                                          'listCard': topic!.listCard,
                                          'topic': topic
                                        });
                                  } else {
                                    await Navigator.pushNamed(
                                        context, '/learn/flashcards',
                                        arguments: {
                                          'listCard': listCardPicked,
                                          'topic': topic
                                        });
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: ButtonListTile(
                                  padding: const EdgeInsets.only(left: 8),
                                  borderRadius: 8,
                                  title: CustomText(
                                    text: 'Thẻ ghi nhớ',
                                    type: TextStyleEnum.large,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  icon: const Icon(
                                    Icons.library_books_rounded,
                                    color: Color.fromARGB(255, 105, 70, 245),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/learn/quiz/settings',
                                    arguments: topic,
                                  );
                                },
                                child: ButtonListTile(
                                  padding: const EdgeInsets.only(left: 8),
                                  borderRadius: 8,
                                  title: CustomText(
                                    text: 'Kiểm tra trắc nghiệm',
                                    type: TextStyleEnum.large,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  icon: const Icon(
                                    Icons.file_copy_rounded,
                                    color: Color.fromARGB(255, 105, 70, 245),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/learn/typing/settings',
                                    arguments: topic,
                                  );
                                },
                                child: ButtonListTile(
                                  padding: const EdgeInsets.only(left: 8),
                                  borderRadius: 8,
                                  title: CustomText(
                                    text: 'Gõ từ',
                                    type: TextStyleEnum.large,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard,
                                    color: Color.fromARGB(255, 105, 70, 245),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/topic/ranking',
                                    arguments: topic,
                                  );
                                },
                                child: ButtonListTile(
                                  padding: const EdgeInsets.only(left: 8),
                                  borderRadius: 8,
                                  title: CustomText(
                                    text: 'Bảng xếp hạng',
                                    type: TextStyleEnum.large,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard,
                                    color: Color.fromARGB(255, 105, 70, 245),
                                  ),
                                ),
                              ),
                              if (listCardPicked.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  child: ToggleSwitch(
                                    animate: true,
                                    animationDuration: 200,
                                    minWidth: double.infinity,
                                    cornerRadius: 20.0,
                                    activeBgColors: [
                                      [Colors.grey.withOpacity(0.7)],
                                      [Colors.grey.withOpacity(0.7)]
                                    ],
                                    activeFgColor: Colors.white,
                                    inactiveBgColor:
                                        Colors.grey.withOpacity(0.3),
                                    inactiveFgColor: Colors.white,
                                    initialLabelIndex: _currentPicked,
                                    totalSwitches: 2,
                                    labels: [
                                      'Học hết',
                                      'Học ${listCardPicked.length}'
                                    ],
                                    customTextStyles: const [
                                      TextStyle(fontWeight: FontWeight.w500),
                                      TextStyle(fontWeight: FontWeight.w500),
                                    ],
                                    radiusStyle: true,
                                    onToggle: (index) {
                                      if (index == 0) {
                                        setState(() {
                                          _currentPicked = 0;
                                          topic!.listCard =
                                              listSort[_currentIndexSort];
                                        });
                                      } else {
                                        setState(() {
                                          _currentPicked = 1;
                                          topic!.listCard = listCardPicked;
                                        });
                                      }
                                    },
                                  ),
                                ),

                              Container(
                                padding: const EdgeInsets.only(top: 16),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: 'Thuật ngữ',
                                      type: TextStyleEnum.large,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        var resultChooseTypeSort =
                                            await showModalActionSheet(
                                          context: context,
                                          title: 'Sắp xếp thuật ngữ',
                                          cancelLabel: 'Hủy',
                                          style: AdaptiveStyle.iOS,
                                          actions: [
                                            const SheetAction<int>(
                                                label: 'Theo thứ tự ban đầu',
                                                key: 0),
                                            const SheetAction<int>(
                                                label: 'Bảng chữ cái', key: 1),
                                          ],
                                        );
                                        if (resultChooseTypeSort == 0) {
                                          setState(() {
                                            _currentIndexSort = 0;
                                            topic!.listCard = listSort[0];
                                          });
                                        } else if (resultChooseTypeSort == 1) {
                                          setState(() {
                                            _currentIndexSort = 1;
                                            topic!.listCard = listSort[1];
                                          });
                                        }
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CustomText(
                                            text: (_currentIndexSort == 0)
                                                ? 'Thứ tự gốc'
                                                : 'Bảng chữ cái',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          const Icon(
                                            Icons.sort_rounded,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //List card bottom
                              ...List.generate(topic!.listCard.length, (index) {
                                return Card(
                                  color: AppTheme.primaryBackgroundColorAppbar,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16,
                                                  left: 16,
                                                  bottom: 16),
                                              child: CustomText(
                                                text: (topic!.listCard[index]
                                                        .term.isEmpty)
                                                    ? '...'
                                                    : topic!
                                                        .listCard[index].term,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8, right: 8),
                                            child: Wrap(
                                              spacing: -6,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    speak(topic!
                                                        .listCard[index].term);
                                                  },
                                                  icon: const Icon(
                                                    Icons.volume_up_outlined,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    if (!_checkPicked(topic!
                                                        .listCard[index])) {
                                                      setState(() {
                                                        listCardPicked.add(
                                                            topic!.listCard[
                                                                index]);
                                                      });
                                                    } else {
                                                      setState(() {
                                                        listCardPicked.remove(
                                                            topic!.listCard[
                                                                index]);
                                                      });
                                                      if (listCardPicked
                                                          .isEmpty) {
                                                        setState(() {
                                                          _currentPicked = 0;
                                                          topic!.listCard =
                                                              listSort[0];
                                                        });
                                                      }
                                                    }
                                                  },
                                                  icon: Icon(
                                                    (_checkPicked(topic!
                                                            .listCard[index]))
                                                        ? Icons.star
                                                        : Icons
                                                            .star_border_outlined,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 16, bottom: 16, right: 16),
                                        child: CustomText(
                                          text: (topic!.listCard[index].define
                                                  .isEmpty)
                                              ? '...'
                                              : topic!.listCard[index].define,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(
                                height: 32,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Skeletonizer(
                    enabled: true,
                    containersColor: AppTheme.primaryColorSkeletonContainer,
                    child: Column(
                      children: [
                        const Row(),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              CarouselSlider.builder(
                                itemCount: 3,
                                itemBuilder: (context, index, realIndex) {
                                  return FlipCard(
                                    fill: Fill.fillBack,
                                    direction: FlipDirection.VERTICAL,
                                    side: CardSide.FRONT,
                                    front: Stack(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppTheme
                                                .primaryBackgroundColorAppbar,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const AutoSizeText(
                                            'abc def',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                              FontAwesomeIcons.expand,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    back: Stack(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppTheme
                                                .primaryBackgroundColorAppbar,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const AutoSizeText(
                                            'abc def',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                              FontAwesomeIcons.expand,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                    initialPage: 0,
                                    height: 200,
                                    autoPlayInterval:
                                        const Duration(seconds: 2),
                                    enlargeCenterPage: true,
                                    enlargeFactor: 0.3,
                                    scrollDirection: Axis.horizontal,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        _current = index;
                                      });
                                    }),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 20, bottom: 4),
                                child: _buildCarouseIndicator(3),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Row(),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: CustomText(
                                  text: 'abc def gh',
                                  type: TextStyleEnum.xl,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundImage: AppTheme.defaultAvatar,
                                      backgroundColor: Colors.grey,
                                      radius: 14,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    CustomText(
                                      text: 'abc def',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      color:
                                          Colors.grey.shade600.withOpacity(0.5),
                                      width: 1,
                                      height: 18,
                                    ),
                                    CustomText(
                                      text: '0 thuật ngữ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              ButtonListTile(
                                padding: const EdgeInsets.only(left: 8),
                                borderRadius: 8,
                                title: CustomText(
                                  text: 'Thẻ ghi nhớ',
                                  type: TextStyleEnum.large,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                icon: const Icon(
                                  Icons.library_books_rounded,
                                  color: Color.fromARGB(255, 96, 30, 202),
                                ),
                                onTap: () {
                                  print('clicked');
                                },
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              ButtonListTile(
                                padding: const EdgeInsets.only(left: 8),
                                borderRadius: 8,
                                title: CustomText(
                                  text: 'Kiểm tra',
                                  type: TextStyleEnum.large,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                icon: const Icon(
                                  Icons.file_copy_rounded,
                                  color: Color.fromARGB(255, 96, 30, 202),
                                ),
                                onTap: () {
                                  print('clicked');
                                },
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              ButtonListTile(
                                padding: const EdgeInsets.only(left: 8),
                                borderRadius: 8,
                                title: CustomText(
                                  text: 'Gõ từ',
                                  type: TextStyleEnum.large,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                icon: const Icon(
                                  Icons.keyboard,
                                  color: Color.fromARGB(255, 96, 30, 202),
                                ),
                                onTap: () {
                                  print('clicked');
                                },
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              ButtonListTile(
                                padding: const EdgeInsets.only(left: 8),
                                borderRadius: 8,
                                title: CustomText(
                                  text: 'Bảng xếp hạng',
                                  type: TextStyleEnum.large,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                icon: const Icon(
                                  Icons.keyboard,
                                  color: Color.fromARGB(255, 96, 30, 202),
                                ),
                                onTap: () {
                                  print('clicked');
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  _buildCarouseIndicator(int itemLength) {
    return AnimatedSmoothIndicator(
      activeIndex: _current,
      count: itemLength,
      onDotClicked: (index) {
        setState(() {
          _current = index;
        });
        _controller.animateToPage(index);
      },
      effect: ScrollingDotsEffect(
        dotHeight: 5,
        dotWidth: 5,
        strokeWidth: 1.5,
        activeDotColor: const Color.fromARGB(255, 166, 110, 255),
        dotColor: Colors.grey.withOpacity(0.3),
        maxVisibleDots: 9,
      ),
    );
  }
}
