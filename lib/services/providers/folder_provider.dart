import 'package:flutter/material.dart';
import 'package:quizletapp/models/folder.dart';
import 'package:quizletapp/services/models_services/folder_service.dart';

class FolderProvider extends ChangeNotifier {
  FolderService folderService = FolderService();
  List<FolderModel> _listFolderOfCurrentUser = [];

  FolderProvider() {
    initFolders();
  }

  List<FolderModel> get listFolderOfCurrentUser => _listFolderOfCurrentUser;

  Future<void> initFolders() async {
    await reloadListFolderOfCurrentUser();
  }

  Future<void> reloadListFolderOfCurrentUser() async {
    try {
      var result = await folderService.getAllTopicOfCurrentUser();
      _listFolderOfCurrentUser =
          FolderService.sortFoldersByDateDescending(result);
      notifyListeners();
    } catch (e) {
      print('FolderProvider error: $e');
    }
  }
}
