import 'package:flutter/material.dart';
import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/services/models_services/topic_service.dart';

class TopicProvider extends ChangeNotifier {
  TopicService topicService = TopicService();
  
  List<TopicModel> _listTopicOfCurrentUser = [];

  TopicProvider() {
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
      print('TopicProvider: Lỗi reload listTopicOfCurrentUser: $e');
    }
  }
}
