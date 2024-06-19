import 'package:quizletapp/models/topic.dart';
import 'package:quizletapp/models/user.dart';

class RankingModel {
  int quantityCorrect;
  int timeTest;
  int attempts;
  UserModel user;
  TopicModel topic;

  RankingModel(this.quantityCorrect, this.timeTest, this.attempts, this.topic, this.user);
}