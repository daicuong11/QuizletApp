import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/folder.dart';
import 'package:quizletapp/services/models_services/folder_service.dart';
import 'package:quizletapp/services/providers/current_user_provider.dart';
import 'package:quizletapp/services/providers/folder_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/loading.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:uuid/uuid.dart';

class CreateFolderPage extends StatefulWidget {
  final bool isPop;
  const CreateFolderPage({
    this.isPop = false,
    super.key,
  });

  @override
  State<CreateFolderPage> createState() => _CreateFolderPageState();
}

class _CreateFolderPageState extends State<CreateFolderPage> {
  final folderService = FolderService();
  final _formKey = GlobalKey<FormState>();
  final uuid = Uuid();
  bool isLoading = false;
  bool isHasTextFolderTitle = false;
  String titleFolder = '';
  String desFolder = '';

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: AppTheme.primaryBackgroundColor,
        appBar: AppBar(
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: AppTheme.primaryBackgroundColor,
          title: CustomText(
            text: 'Thư mục mới',
            type: TextStyleEnum.large,
          ),
          leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: CustomText(
              text: 'Hủy',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          actions: (isHasTextFolderTitle)
              ? [
                  Consumer2<CurrentUserProvider, FolderProvider>(
                    builder: (context, currentUser, folderProvider, child) {
                      return TextButton(
                        onPressed: () async {
                          // create folder
                          setState(() {
                            isLoading = true;
                          });
                          _formKey.currentState!.save();
                          String newFolderID = await folderService.addFolder(
                            FolderModel(
                              uuid.v4(),
                              currentUser.currentUser!.userId,
                              titleFolder,
                              desFolder,
                              null,
                              [],
                              [],
                            ),
                          );
                          folderProvider.reloadListFolderOfCurrentUser();
                          setState(() {
                            isLoading = false;
                          });
                          if (widget.isPop) {
                            Navigator.pop(context);
                          } else {
                            await Navigator.pushNamed(context, '/folder/detail',
                                arguments: newFolderID);
                            Navigator.pop(context);
                          }
                        },
                        child: CustomText(
                          text: 'Lưu',
                          type: TextStyleEnum.large,
                        ),
                      );
                    },
                  ),
                ]
              : null,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Wrap(
                  children: [
                    TextFormField(
                      autofocus: true,
                      onChanged: (value) {
                        if (value.trim().isEmpty) {
                          setState(() {
                            isHasTextFolderTitle = false;
                          });
                        } else {
                          setState(() {
                            isHasTextFolderTitle = true;
                          });
                        }
                      },
                      onSaved: (newValue) {
                        titleFolder = newValue ?? '';
                      },
                      cursorColor: Colors.white,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(width: 4.0, color: Colors.white),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        text: 'Tiêu đề thư mục',
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
                      onSaved: (newValue) {
                        desFolder = newValue ?? '';
                      },
                      cursorColor: Colors.white,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(width: 4.0, color: Colors.white),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        text: 'Mô tả (tùy chọn)',
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
        ),
      ),
      if (isLoading) const Loading(),
    ]);
  }
}
