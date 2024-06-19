import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/models/folder.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/services/models_services/folder_service.dart';
import 'package:quizletapp/services/providers/folder_provider.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/button_listtile.dart';
import 'package:quizletapp/widgets/loading.dart';
import 'package:quizletapp/widgets/text.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddToFolderPage extends StatefulWidget {
  final TopicModel topic;
  const AddToFolderPage({
    required this.topic,
    super.key,
  });

  @override
  State<AddToFolderPage> createState() => _AddToFolderPageState();
}

class _AddToFolderPageState extends State<AddToFolderPage> {
  FolderService folderService = FolderService();

  List<FolderModel> listFolderContainsThisTopic = [];
  List<FolderModel> listFolderPicked = [];

  bool isLoading = false;
  bool isSkeleton = false;

  @override
  void didChangeDependencies() {
    setState(() {
      isSkeleton = true;
    });
    listFolderPicked = FolderService.getListFolderContainsTopic(
        context.watch<FolderProvider>().listFolderOfCurrentUser,
        widget.topic.id);

    listFolderContainsThisTopic = FolderService.getListFolderContainsTopic(
        context.watch<FolderProvider>().listFolderOfCurrentUser,
        widget.topic.id);
    setState(() {
      isSkeleton = false;
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> removeTopicInFolder() async {
    for (var folder in listFolderContainsThisTopic) {
      if (!listFolderPicked.contains(folder)) {
        await folderService.removeTopicInFolder(folder, widget.topic.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.primaryBackgroundColor,
        centerTitle: true,
        title: CustomText(
          text: 'Thêm vào thư mục',
          type: TextStyleEnum.large,
        ),
        actions: [
          TextButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                await removeTopicInFolder();

                for (var folder in listFolderPicked) {
                  await folderService.addTopicToFolder(folder, widget.topic.id);
                }

                context.read<FolderProvider>().reloadListFolderOfCurrentUser();

                setState(() {
                  isLoading = false;
                });
                Navigator.pop(context);
              },
              child: CustomText(
                text: 'Xong',
                style: TextStyle(fontWeight: FontWeight.bold),
              ))
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<FolderProvider>(
              builder: (context, folderProvider, child) {
                return Skeletonizer(
                  enabled: isSkeleton,
                  containersColor: AppTheme.primaryColorSkeletonContainer,
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        margin: const EdgeInsets.only(bottom: 28),
                        child: TextButton(
                          onPressed: () async {
                            setState(() {
                              isSkeleton = true;
                            });
                            await Navigator.pushNamed(
                                context, '/folder/create', arguments: true);
                            await folderProvider
                                .reloadListFolderOfCurrentUser();

                            setState(() {
                              isSkeleton = false;
                            });
                          },
                          child: CustomText(text: '+ Tạo thư mục mới', style: const TextStyle(color: Color.fromARGB(255, 207, 177, 255), fontWeight: FontWeight.bold),),
                        ),
                      ),
                      ...List.generate(
                          folderProvider.listFolderOfCurrentUser.length,
                          (index) {
                        if (index % 2 != 0) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            child: ButtonListTile(
                              onTap: () {
                                FolderModel folder = folderProvider
                                    .listFolderOfCurrentUser[index];
                                if (listFolderPicked.contains(folder)) {
                                  setState(() {
                                    listFolderPicked.remove(folder);
                                  });
                                  return;
                                }
                                setState(() {
                                  listFolderPicked.add(folder);
                                });
                              },
                              boxDecoration: BoxDecoration(
                                  color: AppTheme.primaryBackgroundColor,
                                  border: Border.all(
                                      color: (listFolderPicked.contains(
                                              folderProvider
                                                      .listFolderOfCurrentUser[
                                                  index]))
                                          ? const Color.fromARGB(
                                              255, 207, 177, 255)
                                          : Colors.transparent,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(16)),
                              icon: Icon(
                                Icons.folder_outlined,
                                color: Colors.grey.withOpacity(0.5),
                                size: 28,
                              ),
                              title: CustomText(
                                text: folderProvider
                                    .listFolderOfCurrentUser[index].title,
                                type: TextStyleEnum.large,
                              ),
                            ),
                          );
                        }
                        return ButtonListTile(
                          onTap: () {
                            FolderModel folder =
                                folderProvider.listFolderOfCurrentUser[index];
                            if (listFolderPicked.contains(folder)) {
                              setState(() {
                                listFolderPicked.remove(folder);
                              });
                              return;
                            }
                            setState(() {
                              listFolderPicked.add(folder);
                            });
                          },
                          boxDecoration: BoxDecoration(
                              color: AppTheme.primaryBackgroundColor,
                              border: Border.all(
                                  color: (listFolderPicked.contains(
                                          folderProvider
                                              .listFolderOfCurrentUser[index]))
                                      ? const Color.fromARGB(255, 207, 177, 255)
                                      : Colors.transparent,
                                  width: 2),
                              borderRadius: BorderRadius.circular(16)),
                          icon: Icon(
                            Icons.folder_outlined,
                            color: Colors.grey.withOpacity(0.5),
                            size: 28,
                          ),
                          title: CustomText(
                            text: folderProvider
                                .listFolderOfCurrentUser[index].title,
                            type: TextStyleEnum.large,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          if (isLoading) const Loading()
        ],
      ),
    );
  }
}
