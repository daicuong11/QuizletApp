import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/models/user.dart';
import 'package:quizletapp/services/firebase_auth.dart';

class FolderModel {
  String id;
  String userId;
  String title;
  String description;
  UserModel? userCreate;
  List<String> listTopicId;
  List<TopicModel> listTopic;
  DateTime dateCreated;

  FolderModel(this.id, this.userId, this.title, this.description,
      this.userCreate, this.listTopicId, this.listTopic)
      : dateCreated = DateTime.now();

  // Phương thức tạo danh sách các đối tượng từ danh sách Map
  static List<FolderModel> fromListMap(List<Map<String, dynamic>> listMap) {
    return listMap.map((map) => FolderModel.fromMap(map)).toList();
  }

  // Phương thức tạo đối tượng từ một Map
  static FolderModel fromMap(Map<String, dynamic> map) {
    FirebaseAuthService firebaseAuthService = FirebaseAuthService();
    var user = firebaseAuthService.getCurrentUser()!;
    var currentUser =
        UserModel(user.uid, user.uid, user.email!, user.displayName!);
    return FolderModel(
      map['id'],
      map['userId'],
      map['title'],
      map['description'],
      currentUser,
      List<String>.from(map['listTopicId'] ?? []),
      List<TopicModel>.from(
          (map['listTopic'] ?? []).map((x) => TopicModel.fromMap(x))),
    )..dateCreated = DateTime.parse(map['dateCreated']);
  }

  // Phương thức tạo một Map từ đối tượng FolderModel
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'userCreate': null,
      'listTopicId': listTopicId,
      'listTopic': listTopic.map((topic) => topic.toMap()).toList(),
      'dateCreated': dateCreated
          .toIso8601String(), // Chuyển đổi listTopic thành List<Map<String, dynamic>>
    };
  }

  // Phương thức chuyển đổi từ List<FolderModel> sang List<Map<String, dynamic>>
  static List<Map<String, dynamic>> foldersToMapList(
      List<FolderModel> folders) {
    return folders.map((folder) => folder.toMap()).toList();
  }

  @override
  String toString() {
    return 'FolderModel{id: $id, userId: $userId, title: $title, description: $description, userCreate: $userCreate, listTopic: $listTopic, listTopicId: $listTopicId, dateCreated: $dateCreated}';
  }
}
