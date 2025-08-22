import 'team.dart';

class GameState {
  final List<Team> teams;
  final int currentTeamIndex;
  final int currentRound;
  final int maxRounds;
  final int targetScore;
  final bool gameCompleted;
  final bool roundInProgress;
  final int timeLeft;
  final int totalTime;
  final bool isPaused;
  final String currentPlayerName;
  final GameEndType? endType;
  
  GameState({
    required this.teams,
    this.currentTeamIndex = 0,
    this.currentRound = 1,
    this.maxRounds = 3,
    this.targetScore = 30,
    this.gameCompleted = false,
    this.roundInProgress = false,
    this.timeLeft = 60,
    this.totalTime = 60,
    this.isPaused = false,
    this.currentPlayerName = '',
    this.endType,
  });

  Team get currentTeam => teams[currentTeamIndex];
  
  bool get hasWinner {
    return teams.any((team) => team.score >= targetScore);
  }
  
  List<Team> get winners {
    if (!hasWinner) return [];
    final maxScore = teams.map((team) => team.score).reduce((a, b) => a > b ? a : b);
    return teams.where((team) => team.score == maxScore).toList();
  }
  
  bool get isLastRound => currentRound >= maxRounds;
  
  bool get shouldEndGame {
    return hasWinner || isLastRound;
  }
  
  GameState copyWith({
    List<Team>? teams,
    int? currentTeamIndex,
    int? currentRound,
    int? maxRounds,
    int? targetScore,
    bool? gameCompleted,
    bool? roundInProgress,
    int? timeLeft,
    int? totalTime,
    bool? isPaused,
    String? currentPlayerName,
    GameEndType? endType,
  }) {
    return GameState(
      teams: teams ?? this.teams,
      currentTeamIndex: currentTeamIndex ?? this.currentTeamIndex,
      currentRound: currentRound ?? this.currentRound,
      maxRounds: maxRounds ?? this.maxRounds,
      targetScore: targetScore ?? this.targetScore,
      gameCompleted: gameCompleted ?? this.gameCompleted,
      roundInProgress: roundInProgress ?? this.roundInProgress,
      timeLeft: timeLeft ?? this.timeLeft,
      totalTime: totalTime ?? this.totalTime,
      isPaused: isPaused ?? this.isPaused,
      currentPlayerName: currentPlayerName ?? this.currentPlayerName,
      endType: endType ?? this.endType,
    );
  }
  
  GameState nextTeam() {
    final nextIndex = (currentTeamIndex + 1) % teams.length;
    final nextRound = nextIndex == 0 ? currentRound + 1 : currentRound;
    
    return copyWith(
      currentTeamIndex: nextIndex,
      currentRound: nextRound,
      currentPlayerName: teams[nextIndex].name,
      roundInProgress: false,
      timeLeft: totalTime,
    );
  }
  
  GameState startRound() {
    return copyWith(
      roundInProgress: true,
      isPaused: false,
      timeLeft: totalTime,
    );
  }
  
  GameState endRound() {
    return copyWith(
      roundInProgress: false,
      isPaused: false,
    );
  }
  
  GameState endGame(GameEndType endType) {
    return copyWith(
      gameCompleted: true,
      roundInProgress: false,
      isPaused: false,
      endType: endType,
    );
  }
  
  GameState pauseGame() {
    return copyWith(
      isPaused: true,
    );
  }
  
  GameState resumeGame() {
    return copyWith(
      isPaused: false,
    );
  }
}

enum GameEndType {
  targetScoreReached,
  maxRoundsCompleted,
  manualEnd,
}
