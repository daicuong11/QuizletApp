import 'package:flutter/material.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';

class ForumTopicProvider extends ChangeNotifier {
  TopicService topicService = TopicService();
  
  List<TopicModel> _listTopicOfCurrentUser = [];

  ForumTopicProvider() {
    init();
  }

  Future<void> init() async {
    await reloadListTopic();
  }

  List<TopicModel> get listTopicOfCurrentUser => _listTopicOfCurrentUser;

  Future<void> reloadListTopic() async {
    try {
      var result = await topicService.getListTopicOfCurrentUser();
      _listTopicOfCurrentUser = TopicService.sortTopicsByDateDescending(result);
      notifyListeners();
    } catch (e) {
      print('ForumTopicProvider: Lỗi reload listTopicOfCurrentUser: $e');
    }
  }
}
