import 'package:quizletapp/enums/collection_enum.dart';
import 'package:quizletapp/models/exam_result.dart';
import 'package:quizletapp/models/ranking.dart';
import 'package:quizletapp/models/result.dart';
import 'package:quizletapp/services/firebase.dart';
import 'package:quizletapp/services/firebase_auth.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';
import 'package:quizletapp/services/models_services/user_service.dart';

class ExamResultService {
  FirebaseService firebaseService = FirebaseService();
  FirebaseAuthService firebaseAuthService = FirebaseAuthService();
  UserService userService = UserService();
  TopicService topicService = TopicService();

  Future<String> addResult(ExamResultModel result) async {
    try {
      return await firebaseService.addDocument(
        CollectionEnum.results.name,
        result.toMap(),
      );
    } catch (e) {
      print('Error ExamResultService (addResult): $e');
      return '';
    }
  }

  Future<List<ExamResultModel>> getListResultByUserIdAndTopicId(
      String userId, String topicId) async {
    var mapResult = await groupResultsByUserId(topicId);
    return mapResult.containsKey(userId) ? mapResult[userId]! : [];
  }

  Future<List<ExamResultModel>> getListResultByTopicId(String topicId) async {
    try {
      var listMapResult = await firebaseService.getDocumentsByField(
        CollectionEnum.results.name,
        'topicId',
        topicId,
      );
      List<ExamResultModel> listResult =
          ExamResultModel.fromListMap(listMapResult);
      var currentTopic = await topicService.getTopicById(listResult[0].topicId);
      for (var i in listResult) {
        var currentUser = await userService.getUserByUid(i.userId);
        i.userCreate = currentUser;
        i.topic = currentTopic;
      }
      return listResult;
    } catch (e) {
      print('Error ExamResultService (getListResultByTopicId): $e');
      return [];
    }
  }

  Future<Map<String, List<ExamResultModel>>> groupResultsByUserId(
      String topicId) async {
    List<ExamResultModel> results = await getListResultByTopicId(topicId);

    Map<String, List<ExamResultModel>> groupedResults = {};

    for (var result in results) {
      if (groupedResults.containsKey(result.userId)) {
        groupedResults[result.userId]!.add(result);
      } else {
        groupedResults[result.userId] = [result];
      }
    }

    return groupedResults;
  }

  ExamResultModel getMaxQuantityCorrect(List<ExamResultModel> results) {
    return results.reduce((current, next) =>
        next.quantityCorrect > current.quantityCorrect ? next : current);
  }

  ExamResultModel getMinTimeTest(List<ExamResultModel> results) {
    return results.reduce(
        (current, next) => next.timeTest < current.timeTest ? next : current);
  }

  Future<List<RankingModel>> getListRankingModel(String topicId) async {
    var mapRanking = await groupResultsByUserId(topicId);
    List<RankingModel> listRankingModel = [];
    for (var listExamResult in mapRanking.values) {
      ExamResultModel maxQuantityCorrect =
          getMaxQuantityCorrect(listExamResult);
      ExamResultModel minTimeTest = getMinTimeTest(listExamResult);
      RankingModel newRankingModel = RankingModel(
          maxQuantityCorrect.quantityCorrect,
          minTimeTest.timeTest,
          listExamResult.length,
          maxQuantityCorrect.topic!,
          maxQuantityCorrect.userCreate!);
      listRankingModel.add(newRankingModel);
    }
    return listRankingModel;
  }

  Future<List<RankingModel>> getTop20ByQuantityCorrect(String topicId) async {
    var listResult = await getListRankingModel(topicId);
    listResult.sort((a, b) => b.quantityCorrect.compareTo(a.quantityCorrect));
    return listResult.take(20).toList();
  }

  Future<List<RankingModel>> getTop20ByTimeTest(String topicId) async {
    var listResult = await getListRankingModel(topicId);
    listResult.sort((a, b) => a.timeTest.compareTo(b.timeTest));
    return listResult.take(20).toList();
  }

  Future<List<RankingModel>> getTop20ByAttempts(String topicId) async {
    List<RankingModel> listResult = await getListRankingModel(topicId);
    listResult.sort((a, b) => b.attempts.compareTo(a.attempts));
    return listResult.take(20).toList();
  }
}
