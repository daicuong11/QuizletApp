import 'package:quizletapp/enums/collection_enum.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/models/user.dart';
import 'package:quizletapp/services/firebase.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';

class UserService {
  FirebaseService firebaseService = FirebaseService();

  // Phương thức để lấy thông tin người dùng bằng UID
  Future<UserModel?> getUserByUid(String uid) async {
    try {
      var findUser = await firebaseService.getDocumentsByField('users', 'userId', uid);
      if (findUser.isNotEmpty) {
        return UserModel.fromMap(findUser.first);
      }
      return null;
    } catch (error) {
      // Xử lý lỗi nếu có
      print('Error getting user by UID: $error');
      return null;
    }
  }

  Future<List<UserModel>> getAllUser() async {
    try {
      var allUserMap = await firebaseService.getDocuments('users');
      return UserModel.fromListMap(allUserMap);
    } catch (error) {
      // Xử lý lỗi nếu có
      print('Error getAllUser: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String keyword) async {
    try {
      TopicService topicService = TopicService();

      List<Map<String, dynamic>> listResult = [];

      String key = keyword.toLowerCase().trim();
      var allUser = await getAllUser();

      var searchAllUser = allUser.where((element) => element.username.toLowerCase().contains(key)).toList();

      for (var i in searchAllUser) {
        List<TopicModel> currentTopic = await topicService.getListTopicByUserId(i.userId);
        listResult.add({
          'countTopic': currentTopic.length,
          'user': i,
        });
      }
      return listResult;
    } catch (e) {
      print('Error UserService (searchUsers): $e');
      return [];
    }
  }
}