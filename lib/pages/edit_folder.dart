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

class EditFolderPage extends StatefulWidget {
  FolderModel folder;
  EditFolderPage({
    required this.folder,
    super.key,
  });

  @override
  State<EditFolderPage> createState() => _EditFolderPageState();
}

class _EditFolderPageState extends State<EditFolderPage> {
  final folderService = FolderService();
  final _formKey = GlobalKey<FormState>();
  final uuid = Uuid();
  bool isLoading = false;
  bool isHasTextFolderTitle = false;
  String titleFolder = '';
  String desFolder = '';
  
  @override
  void initState() {
    // TODO: implement initState
    if(widget.folder.title.trim().isNotEmpty) {
      setState(() {
        isHasTextFolderTitle = true;
      });
    }
    super.initState();
  }

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
            text: 'Sửa thư mục',
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
                          // update folder
                          setState(() {
                            isLoading = true;
                          });
                          _formKey.currentState!.save();
                          widget.folder.title = titleFolder;
                          widget.folder.description = desFolder;
                          await folderService.updateFolder(widget.folder);
                          folderProvider.reloadListFolderOfCurrentUser();
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pop(context);
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
                      initialValue: widget.folder.title,
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
                      initialValue: widget.folder.description,
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
