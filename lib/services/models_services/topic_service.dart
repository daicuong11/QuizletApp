import 'package:quizletapp/enums/collection_enum.dart';
import 'package:quizletapp/models/card.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/models/user.dart';
import 'package:quizletapp/services/firebase.dart';
import 'package:quizletapp/services/firebase_auth.dart';
import 'package:quizletapp/services/models_services/user_service.dart';

class TopicService {
  FirebaseAuthService firebaseAuthService = FirebaseAuthService();
  FirebaseService firebaseService = FirebaseService();
  UserService userService = UserService();

  Future<TopicModel?> getTopicById(String topicId) async {
    try {
      var getTopicById = await firebaseService.getDocument('topics', topicId);
      UserModel? userCreate =
          await userService.getUserByUid(getTopicById['userId']);
      var user = TopicModel.fromMap(getTopicById);
      user.userCreate = userCreate;
      return user;
    } catch (e) {
      print('Topic service error (method getTopicById): $e');
    }
    return null;
  }

  Future<List<TopicModel>> getAllTopicPublic() async {
    List<TopicModel> topics = [];

    try {
      var listTopic =
          await firebaseService.getDocumentsByField('topics', 'public', true);
      print('listAllTopicPublic: $listTopic');

      for (var topicMap in listTopic) {
        UserModel? user = await userService.getUserByUid(topicMap['userId']);

        TopicModel topic = TopicModel.fromMap(topicMap);
        topic.userCreate = user;
        topics.add(topic);
      }
    } catch (e) {
      print('Topic service error (method getAllTopicPublic): $e');
    }

    return topics;
  }

  Future<List<TopicModel>> getListTopicByUserId(String userId) async {
    try {
      var listTopic =
          await firebaseService.getDocumentsByField('topics', 'userId', userId);

      List<TopicModel> listResult = TopicModel.fromListMap(listTopic);

      return listResult;
    } catch (e) {
      print('Lỗi lấy topics: ${e}');
      return [];
    }
  }

  Future<List<TopicModel>> getListTopicOfCurrentUser() async {
    try {
      if (firebaseAuthService.isUserLoggedIn()) {
        var user = firebaseAuthService.getCurrentUser();
        if (user == null) return [];
        var listTopic = await firebaseService.getDocumentsByField(
            'topics', 'userId', user.uid);

        List<TopicModel> listResult = [];

        UserModel? currentUserModel = await userService.getUserByUid(user!.uid);

        for (var topicMap in listTopic) {
          TopicModel topic = TopicModel.fromMap(topicMap);
          topic.userCreate = currentUserModel;
          listResult.add(topic);
        }

        return sortTopicsByDateDescending(listResult);
      } else {
        return [];
      }
    } catch (e) {
      print('Lỗi lấy topics: ${e}');
      return [];
    }
  }

  //Thêm một topic mới vào firestore
  Future<String> addTopic(TopicModel newTopic) async {
    try {
      var id = await firebaseService.addDocument('topics', newTopic.toMap());
      return id;
    } catch (e) {
      print('Topic service error (method add): $e');
    }
    return '';
  }

  Future<void> updateTopic(TopicModel newTopic) async {
    try {
      await firebaseService.updateDocument(
          'topics', newTopic.id, newTopic.toMap());
    } catch (e) {
      print('Topic service error (method update): $e');
    }
  }

  Future<void> deleteTopic(String id) async {
    try {
      await firebaseService.deleteDocument('topics', id);
    } catch (e) {
      print('Topic service error (method delete): $e');
    }
  }

  static List<TopicModel> sortTopicsByDate(List<TopicModel> topics) {
    topics.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    return topics;
  }

  static List<TopicModel> sortTopicsByDateDescending(List<TopicModel> topics) {
    topics.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    return topics;
  }

  static List<CardModel> sortTopicByABC(List<CardModel> listCard) {
    List<CardModel> listClone = listCard.map((element) {
      return CardModel(element.cardId, element.term, element.define);
    }).toList();
    listClone.sort((a, b) => a.term.compareTo(b.term));
    return listClone;
  }

  List<TopicModel> getTopicsToday(List<TopicModel> listTopicOfCurrentUser) {
    DateTime now = DateTime.now();
    DateTime startOfToday = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
    DateTime endOfToday =
        DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    List<TopicModel> topicsToday = [];

    listTopicOfCurrentUser.forEach((topicModel) {
      if (topicModel.dateCreated.isAfter(startOfToday) &&
          topicModel.dateCreated.isBefore(endOfToday)) {
        topicsToday.add(topicModel);
      }
    });

    return sortTopicsByDateDescending(topicsToday);
  }

  static String formatDate(DateTime dateTime) {
    if (dateTime == null) {
      return '';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return 'ngày $day tháng $month năm $year';
  }

  Future<List<TopicModel>> searchTopics(String keyword) async {
    try {
      String key = keyword.trim().toLowerCase();
      var getAllTopic = await getAllTopicPublic();

      var listSearch = getAllTopic
          .where(
            (e) =>
                e.title.toLowerCase().contains(key) ||
                e.description.toLowerCase().contains(key),
          )
          .toList();
      return sortTopicsByDateDescending(listSearch);
    } catch (e) {
      print('Error TopicService ( searchTopics): $e');
      return [];
    }
  }

  void printListTopics(List<TopicModel> listTopics) {
    print('List topics:');
    for (var i in listTopics) {
      print(i.toString());
    }
  }
}
