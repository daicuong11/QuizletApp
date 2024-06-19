import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/models/user.dart';

class ExamResultModel {
  String id;
  String topicId;
  String userId;
  UserModel? userCreate;
  TopicModel? topic;
  int timeTest;
  int quantityCorrect;
  DateTime dateCreated;

  ExamResultModel(this.id, this.topicId, this.userId, this.userCreate,
      this.timeTest, this.quantityCorrect, this.topic)
      : dateCreated = DateTime.now();

  ExamResultModel.copy(ExamResultModel source)
      : id = source.id,
        topicId = source.topicId,
        userId = source.userId,
        userCreate = source.userCreate,
        topic = source.topic,
        timeTest = source.timeTest,
        quantityCorrect = source.quantityCorrect,
        dateCreated = source.dateCreated;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'userId': userId,
      'userCreate': null,
      'topic': null, 
      'timeTest': timeTest,
      'quantityCorrect': quantityCorrect,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> examResultsToMapList(
      List<ExamResultModel> examResults) {
    return examResults.map((examResult) => examResult.toMap()).toList();
  }

  static List<ExamResultModel> fromListMap(List<Map<String, dynamic>> listMap) {
    return listMap.map((map) => ExamResultModel.fromMap(map)).toList();
  }

  static ExamResultModel fromMap(Map<String, dynamic> map) {
    return ExamResultModel(
      map['id'],
      map['topicId'],
      map['userId'],
      map['userCreate'],
      map['timeTest'],
      map['quantityCorrect'],
      map['topic'], 
    )..dateCreated = DateTime.parse(map['dateCreated']);
  }

  @override
  String toString() {
    return 'ExamResultModel(topicId: $topicId, userId: $userId, username: ${userCreate?.username}, id: $id, timeTest: $timeTest, quantityCorrect: $quantityCorrect, dateCreated: $dateCreated, topic: $topic)';
  }
}
