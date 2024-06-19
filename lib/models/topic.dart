import 'package:quizletapp/models/card.dart';
import 'package:quizletapp/models/user.dart';

class TopicModel {
  String id;
  String userId;
  String title;
  String description;
  bool public;
  UserModel? userCreate;
  List<CardModel> listCard;
  DateTime dateCreated; 

  TopicModel(this.id, this.userId, this.title, this.description, this.public,
      this.userCreate, this.listCard)
      : dateCreated = DateTime.now();

  TopicModel.copy(TopicModel source)
      : id = source.id,
        userId = source.userId,
        title = source.title,
        description = source.description,
        public = source.public,
        userCreate = source.userCreate,
        listCard = List<CardModel>.from(source.listCard.map((card) =>
            CardModel.copy(card))), 
        dateCreated = source.dateCreated;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId':userId,
      'title': title,
      'description': description,
      'public': public,
      'userCreate': null,
      'listCard': listCard
          .map((card) => card.toMap())
          .toList(), 
      'dateCreated': dateCreated
          .toIso8601String(), 
    };
  }

  static List<Map<String, dynamic>> topicsToMapList(List<TopicModel> topics) {
    return topics.map((topic) => topic.toMap()).toList();
  }

  static List<TopicModel> fromListMap(List<Map<String, dynamic>> listMap) {
    return listMap.map((map) => TopicModel.fromMap(map)).toList();
  }

  static TopicModel fromMap(Map<String, dynamic> map) {
    return TopicModel(
      map['id'],
      map['userId'],
      map['title'],
      map['description'],
      map['public'],
      map['userCreate'],
      List<CardModel>.from(
          (map['listCard'] ?? []).map((x) => CardModel.fromMap(x))),
    )..dateCreated = DateTime.parse(
        map['dateCreated']); 
  }

  @override
  String toString() {
    return 'TopicModel(userId: $userId, username: ${userCreate?.username}, id: $id, title: $title, description: $description, public: $public, listCard: $listCard, dateCreated: $dateCreated)';
  }
}
