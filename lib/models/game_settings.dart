class GameSettings {
  final String language;
  final int timePerRound;
  final int maxSkips;
  final bool soundEnabled;
  final String difficulty;
  final int numberOfRounds;
  final bool skipsAllowed;
  final int maxSkipsPerRound;
  final int playersPerTeam;
  final bool workOffline;
  final int targetScore;
  final bool useTargetScore;

  GameSettings({
    this.language = 'kurmanci',
    this.timePerRound = 60,
    this.maxSkips = 3,
    this.soundEnabled = true,
    this.difficulty = 'normal',
    this.numberOfRounds = 3,
    this.skipsAllowed = true,
    this.maxSkipsPerRound = 3,
    this.playersPerTeam = 2,
    this.workOffline = true,
    this.targetScore = 30,
    this.useTargetScore = false,
  });

  GameSettings copyWith({
    String? language,
    int? timePerRound,
    int? maxSkips,
    bool? soundEnabled,
    String? difficulty,
    int? numberOfRounds,
    bool? skipsAllowed,
    int? maxSkipsPerRound,
    int? playersPerTeam,
    bool? workOffline,
    int? targetScore,
    bool? useTargetScore,
  }) {
    return GameSettings(
      language: language ?? this.language,
      timePerRound: timePerRound ?? this.timePerRound,
      maxSkips: maxSkips ?? this.maxSkips,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      difficulty: difficulty ?? this.difficulty,
      numberOfRounds: numberOfRounds ?? this.numberOfRounds,
      skipsAllowed: skipsAllowed ?? this.skipsAllowed,
      maxSkipsPerRound: maxSkipsPerRound ?? this.maxSkipsPerRound,
      playersPerTeam: playersPerTeam ?? this.playersPerTeam,
      workOffline: workOffline ?? this.workOffline,
      targetScore: targetScore ?? this.targetScore,
      useTargetScore: useTargetScore ?? this.useTargetScore,
    );
  }
}
