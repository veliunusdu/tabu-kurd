class TabooCard {
  final String word;
  final List<String> tabooWords;
  final String category;
  final String language;

  TabooCard({
    required this.word,
    required this.tabooWords,
    required this.category,
    this.language = 'kurmanci',
  });

  factory TabooCard.fromJson(Map<String, dynamic> json) {
    return TabooCard(
      word: json['word'] as String,
      tabooWords: List<String>.from(json['tabooWords']),
      category: json['category'] as String,
      language: json['language'] as String? ?? 'kurmanci',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'tabooWords': tabooWords,
      'category': category,
      'language': language,
    };
  }
}
