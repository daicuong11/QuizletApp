class CardModel {
  String cardId;
  String term;
  String define;

  CardModel(this.cardId, this.term, this.define);

  CardModel.copy(CardModel source)
      : cardId = source.cardId,
        term = source.term,
        define = source.define;

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'term': term,
      'define': define,
    };
  }

  // Static method to convert a list of maps into a list of CardModel objects
  static List<CardModel> fromListMap(List<Map<String, dynamic>> listMap) {
    return listMap.map((map) => CardModel.fromMap(map)).toList();
  }

  // Static method to convert a map into a CardModel object
  static CardModel fromMap(Map<String, dynamic> map) {
    return CardModel(
      map['cardId'],
      map['term'],
      map['define'],
    );
  }

  // Static method to convert a list of CardModel objects into a list of maps
  static List<Map<String, dynamic>> cardsToMapList(List<CardModel> cards) {
    return cards.map((card) => card.toMap()).toList();
  }

  String toString() {
    return 'CardModel: { define: $define, term: $term}';
  }
}
