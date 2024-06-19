import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/card.dart'; // Changed from 'package:quizletapp/models/card.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/pages/topic_setting.dart';
import 'package:quizletapp/services/firebase_auth.dart';
import 'package:quizletapp/services/providers/topic_provider.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/loading.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:cupertino_interactive_keyboard/cupertino_interactive_keyboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

class CreateTopicPage extends StatefulWidget {
  final bool isPop;
  const CreateTopicPage({
    this.isPop = false,
    Key? key,
  }) : super(key: key);

  @override
  State<CreateTopicPage> createState() => _CreateTopicPageState();
}

class _CreateTopicPageState extends State<CreateTopicPage> {
  FirebaseAuthService firebaseAuthService = FirebaseAuthService();

  bool isLoading = false;

  bool isPublic = true;

  var uuid = Uuid();

  List<CardModel> listCard = [];

  List<FocusNode> listFocus = [];

  String _filePath = '';

  var viewCards = [];

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    listCard.add(CardModel(uuid.v4(), '', ''));
    listCard.add(CardModel(uuid.v4(), '', ''));
    listCard.add(CardModel(uuid.v4(), '', ''));

    listFocus.add(FocusNode());
    listFocus.add(FocusNode());
    listFocus.add(FocusNode());
    listFocus.add(FocusNode());
    listFocus.add(FocusNode());
    listFocus.add(FocusNode());
    listFocus[0].requestFocus();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (FocusNode i in listFocus) {
      i.dispose();
    }
    super.dispose();
  }

  Future<void> readExcelFile() async {
    List<CardModel> dataList = [];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );

    if (result != null) {
      String filePath = result.files.first.path!;
      var file = File(filePath);
      List<List<dynamic>> csvData = [];

      // Read the CSV file
      try {
        csvData = CsvToListConverter().convert(file.readAsStringSync());
      } catch (e) {
        print('Error reading CSV file: $e');
        return;
      }

      // Process CSV data
      for (var row in csvData) {
        String term = row[0].toString();
        String define = row[1].toString();

        CardModel newCard = CardModel(uuid.v4(), term, define);
        dataList.add(newCard);
      }
    } else {
      print('No file selected');
    }

    if (dataList.isNotEmpty) {
      for (var card in dataList) {
        print('{ ${card.term} : ${card.define}}');
        _addNewCardByCsv(card);
      }

      Future.delayed(Durations.medium3).whenComplete(() {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  int? getIndexFocus() {
    for (int i = 0; i < listFocus.length; i++) {
      if (listFocus[i].hasFocus) {
        return i;
      }
    }
    return null;
  }

  void _addNewCardByCsv(CardModel newCard) {
    if (listFocus.length % 2 == 0) {
      FocusNode termFocus = FocusNode();
      FocusNode defineFocus = FocusNode();

      setState(() {
        listFocus.add(termFocus);
        listFocus.add(defineFocus);

        listCard.add(newCard);
      });
    }
  }

  void _addNewCard() {
    int? index = getIndexFocus();
    if (listFocus.length % 2 == 0) {
      FocusNode termFocus = FocusNode();
      FocusNode defineFocus = FocusNode();

      setState(() {
        listFocus.add(termFocus);
        listFocus.add(defineFocus);

        listCard.add(CardModel(uuid.v4(), '', ''));
      });

      termFocus.requestFocus();

      Future.delayed(Durations.medium2).whenComplete(() {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      });
    }
  }

  void _deleteCard(int index, CardModel cardModel, FocusNode focusNode1,
      FocusNode focusNode2) {
    if (listCard.length > 0) {
      setState(() {
        // listCard.removeAt(index);
        // listFocus.removeRange(index * 2, index * 2 + 2);
        listCard.remove(cardModel);
        listFocus.remove(focusNode1);
        listFocus.remove(focusNode2);
      });
    }
  }

  String? _checkValue() {
    if (listCard.length < 3) {
      return 'Bạn phải thêm vào ít nhất hai thuật ngữ mới lưu được học phần.';
    }
    int count = 0;
    for (int i = 1; i < listCard.length; i++) {
      String term = listCard[i].term;
      String define = listCard[i].define;
      if (term.isNotEmpty || define.isNotEmpty) {
        count++;
      }
    }
    if (count < 2) {
      if (count == 0 && listCard[0].term.isEmpty) return 'not create';
      return 'Bạn phải thêm vào ít nhất hai thuật ngữ mới lưu được học phần.';
    }
    if (listCard[0].term.isEmpty) {
      return 'Bạn phải nhập tiêu đề mới lưu được học phần này';
    }
    return null;
  }

  List<CardModel> listCardCleaned(List<CardModel> list) {
    List<CardModel> listResult = [];
    for (var i in list) {
      if (i.term.isNotEmpty || i.define.isNotEmpty) listResult.add(i);
    }
    return listResult;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppTheme.primaryBackgroundColor,
          appBar: AppBar(
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: AppTheme.primaryBackgroundColor,
            title: CustomText(
              text: 'Tạo học phần',
              type: TextStyleEnum.large,
            ),
            leading: IconButton(
              onPressed: () async {
                //Cài đặt topic
                var prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isPublic', isPublic);
                var rs = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopicSettingPage(
                      isPublic: isPublic,
                    ),
                  ),
                );
                var public = await prefs.getBool('isPublic') ?? true;
                setState(() {
                  isPublic = public;
                });
              },
              icon: const Icon(Icons.settings_outlined),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    // FocusScope.of(context).unfocus();
                    String? resultCheck = _checkValue();
                    if (resultCheck == null) {
                      //Đã check thông tin thành công
                      //lưu vào db
                      CardModel titleAndDes = listCard[0];
                      print(
                          'Tiêu đề: ${titleAndDes.term}, Mô tả: ${titleAndDes.define}');
                      if (listCard.isNotEmpty) {
                        TopicService topicService = TopicService();

                        var listClone = listCard.sublist(1);
                        List<CardModel> newListCard =
                            listCardCleaned(listClone);
                        //in ra check
                        print('Danh sách thẻ sau khi thêm mới:');
                        for (CardModel card in newListCard) {
                          print(
                              'Thuật ngữ: ${card.term}, Định nghĩa: ${card.define}');
                        }

                        //lưu
                        var user = firebaseAuthService.getCurrentUser();
                        if (user != null) {
                          TopicModel newTopic = TopicModel(
                              uuid.v4(),
                              user.uid,
                              titleAndDes.term,
                              titleAndDes.define,
                              isPublic,
                              null,
                              newListCard);
                          setState(() {
                            isLoading = true;
                          });
                          var newTopicId =
                              await topicService.addTopic(newTopic);
                          setState(() {
                            isLoading = false;
                          });
                          print('Tạo topic thành công');
                          context.read<TopicProvider>().reloadListTopic();
                          if (widget.isPop == true) {
                            Navigator.pop(context);
                          } else {
                            await Navigator.pushReplacementNamed(
                                context, '/topic/detail',
                                arguments: newTopicId);
                            Navigator.pop(context);
                          }
                        }
                      } else {
                        print('listCard rỗng');
                      }
                    } else if (resultCheck.compareTo('not create') == 0) {
                      //chưa điền gì nên không lưu
                      Navigator.pop(context);
                    } else {
                      var chooseResult = await showOkCancelAlertDialog(
                        context: context,
                        cancelLabel: 'Hủy',
                        okLabel: 'Xóa học phần này',
                        isDestructiveAction: true,
                        style: AdaptiveStyle.iOS,
                        useActionSheetForIOS: true,
                        title: resultCheck,
                      );

                      if (chooseResult == OkCancelResult.ok) {
                        //xóa học phần đang tạo
                        var isDelete = await showOkCancelAlertDialog(
                          context: context,
                          cancelLabel: 'Hủy',
                          okLabel: 'Xóa',
                          isDestructiveAction: true,
                          alertStyle: AdaptiveStyle.iOS,
                          style: AdaptiveStyle.iOS,
                          title: 'Bạn chắc chắn muốn xóa học phần này',
                        );
                        if (isDelete == OkCancelResult.ok) {
                          Navigator.pop(context);
                        }
                      }
                    }
                  } catch (e) {
                    print('Lỗi lưu topic vào database: $e');
                  }
                },
                child: CustomText(
                  text: 'Xong',
                  type: TextStyleEnum.large,
                ),
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 100),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            children: [
                              TextFormField(
                                initialValue: listCard[0].term,
                                focusNode: listFocus[0],
                                onChanged: (value) {
                                  listCard[index].term = value ?? '';
                                },
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Chủ đề, chương, đơn vị',
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
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                alignment: Alignment.centerLeft,
                                child: CustomText(
                                  text: 'Tiêu đề',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            children: [
                              TextFormField(
                                initialValue: listCard[0].define,
                                focusNode: listFocus[1],
                                maxLines: null,
                                onChanged: (value) {
                                  listCard[index].define = value ?? '';
                                },
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Học phần của bạn có chủ đề gì?',
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
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                alignment: Alignment.centerLeft,
                                child: CustomText(
                                  text: 'Mô tả',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                            ),
                            onPressed: readExcelFile,
                            child: Wrap(
                              spacing: 4,
                              children: [
                                const Icon(
                                  Icons.document_scanner_rounded,
                                  color: Color.fromARGB(255, 168, 129, 232),
                                ),
                                CustomText(
                                  text: 'Quét tài liệu',
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 168, 129, 232),
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Dismissible(
                    key: ValueKey<String>(listCard[index].cardId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
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
                    onDismissed: (direction) {
                      _deleteCard(index, listCard[index], listFocus[index * 2],
                          listFocus[index * 2 + 1]);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: AppTheme.primaryBackgroundColorAppbar,
                      child: Column(
                        children: [
                          Wrap(
                            children: [
                              TextFormField(
                                initialValue: listCard[index].term,
                                focusNode: listFocus[index * 2],
                                maxLines: null,
                                onChanged: (value) {
                                  listCard[index].term = value ?? '';
                                },
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
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
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                alignment: Alignment.centerLeft,
                                child: CustomText(
                                  text: 'Thuật ngữ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            children: [
                              TextFormField(
                                initialValue: listCard[index].define,
                                focusNode: listFocus[index * 2 + 1],
                                maxLines: null,
                                onChanged: (value) {
                                  listCard[index].define = value ?? '';
                                },
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
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
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                alignment: Alignment.centerLeft,
                                child: CustomText(
                                  text: 'Định nghĩa',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                      height: 8,
                    ),
                itemCount: listCard.length),
          ),
          bottomSheet: CupertinoInputAccessory(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBackgroundColorAppbar,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 64,
                    height: 44,
                    child: TextButton(
                      onPressed: () {
                        var indexFocus = getIndexFocus();
                        if (indexFocus != null &&
                            indexFocus != (listFocus.length - 1)) {
                          listFocus[indexFocus + 1].requestFocus();
                        }
                      },
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    child: Material(
                      elevation: 4,
                      shape: const CircleBorder(),
                      color: AppTheme.primaryColor,
                      child: IconButton(
                        onPressed: () {
                          _addNewCard();
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 64,
                  )
                ],
              ),
            ),
          ),
        ),
        if (isLoading) const Loading(),
      ],
    );
  }
}
