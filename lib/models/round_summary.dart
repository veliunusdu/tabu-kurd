class RoundSummary {
  final int roundNumber;
  final String teamName;
  final int wordsGuessed;
  final int wordsSkipped;
  final int tabooViolations;
  final int pointsEarned;
  final Duration timeUsed;
  final List<String> correctWords;
  final List<String> skippedWords;

  RoundSummary({
    required this.roundNumber,
    required this.teamName,
    required this.wordsGuessed,
    required this.wordsSkipped,
    required this.tabooViolations,
    required this.pointsEarned,
    required this.timeUsed,
    required this.correctWords,
    required this.skippedWords,
  });

  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'teamName': teamName,
      'wordsGuessed': wordsGuessed,
      'wordsSkipped': wordsSkipped,
      'tabooViolations': tabooViolations,
      'pointsEarned': pointsEarned,
      'timeUsed': timeUsed.inSeconds,
      'correctWords': correctWords,
      'skippedWords': skippedWords,
    };
  }

  factory RoundSummary.fromJson(Map<String, dynamic> json) {
    return RoundSummary(
      roundNumber: json['roundNumber'],
      teamName: json['teamName'],
      wordsGuessed: json['wordsGuessed'],
      wordsSkipped: json['wordsSkipped'],
      tabooViolations: json['tabooViolations'],
      pointsEarned: json['pointsEarned'],
      timeUsed: Duration(seconds: json['timeUsed']),
      correctWords: List<String>.from(json['correctWords']),
      skippedWords: List<String>.from(json['skippedWords']),
    );
  }
}
