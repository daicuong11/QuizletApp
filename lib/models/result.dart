import 'package:quizletapp/models/card.dart';

class ResultModel {
  bool correct;
  CardModel cardQuestion;
  CardModel cardResult;

  ResultModel(this.correct, this.cardQuestion, this.cardResult);
}