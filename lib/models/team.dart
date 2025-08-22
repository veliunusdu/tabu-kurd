class Team {
  String name;
  int score;
  int correctGuesses;
  int skippedWords;
  int tabooViolations;
  List<String> wordsGuessed;
  List<String> wordsSkipped;
  List<String> tabooWordsUsed;

  Team({
    required this.name,
    this.score = 0,
    this.correctGuesses = 0,
    this.skippedWords = 0,
    this.tabooViolations = 0,
    List<String>? wordsGuessed,
    List<String>? wordsSkipped,
    List<String>? tabooWordsUsed,
  }) : wordsGuessed = wordsGuessed ?? [],
       wordsSkipped = wordsSkipped ?? [],
       tabooWordsUsed = tabooWordsUsed ?? [];

  Team copyWith({
    String? name,
    int? score,
    int? correctGuesses,
    int? skippedWords,
    int? tabooViolations,
    List<String>? wordsGuessed,
    List<String>? wordsSkipped,
    List<String>? tabooWordsUsed,
  }) {
    return Team(
      name: name ?? this.name,
      score: score ?? this.score,
      correctGuesses: correctGuesses ?? this.correctGuesses,
      skippedWords: skippedWords ?? this.skippedWords,
      tabooViolations: tabooViolations ?? this.tabooViolations,
      wordsGuessed: wordsGuessed ?? this.wordsGuessed,
      wordsSkipped: wordsSkipped ?? this.wordsSkipped,
      tabooWordsUsed: tabooWordsUsed ?? this.tabooWordsUsed,
    );
  }

  void addCorrectGuess(String word) {
    correctGuesses++;
    score++;
    wordsGuessed.add(word);
  }

  void addSkip(String word) {
    skippedWords++;
    wordsSkipped.add(word);
  }

  void addTabooViolation(String word) {
    tabooViolations++;
    tabooWordsUsed.add(word);
    // Penalty: lose a point
    if (score > 0) score--;
  }

  void reset() {
    score = 0;
    correctGuesses = 0;
    skippedWords = 0;
    tabooViolations = 0;
    wordsGuessed.clear();
    wordsSkipped.clear();
    tabooWordsUsed.clear();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'correctGuesses': correctGuesses,
      'skippedWords': skippedWords,
      'tabooViolations': tabooViolations,
      'wordsGuessed': wordsGuessed,
      'wordsSkipped': wordsSkipped,
      'tabooWordsUsed': tabooWordsUsed,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'],
      score: json['score'] ?? 0,
      correctGuesses: json['correctGuesses'] ?? 0,
      skippedWords: json['skippedWords'] ?? 0,
      tabooViolations: json['tabooViolations'] ?? 0,
      wordsGuessed: List<String>.from(json['wordsGuessed'] ?? []),
      wordsSkipped: List<String>.from(json['wordsSkipped'] ?? []),
      tabooWordsUsed: List<String>.from(json['tabooWordsUsed'] ?? []),
    );
  }
}
