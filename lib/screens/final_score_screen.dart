import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/game_settings.dart';
import '../models/team.dart';
import '../services/localization_service.dart';

class FinalScoreScreen extends StatelessWidget {
  final GameState gameState;
  final GameSettings settings;

  const FinalScoreScreen({
    super.key,
    required this.gameState,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final sortedTeams = List<Team>.from(gameState.teams)
      ..sort((a, b) => b.score.compareTo(a.score));
    
    final winnerScore = sortedTeams.first.score;
    final winners = sortedTeams.where((team) => team.score == winnerScore).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get('final_scores', settings.language)),
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF228B22).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Winner Announcement
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade300,
                        Colors.amber.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 48,
                        color: Colors.amber.shade800,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        winners.length == 1
                            ? '🎉 ${AppLocalizations.get('winner', settings.language)} 🎉'
                            : '🎉 ${AppLocalizations.get('winners', settings.language)} 🎉',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: winners.map((winner) => Text(
                          winner.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                          textAlign: TextAlign.center,
                        )).toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.get('score', settings.language)}: $winnerScore',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                // Score Table
                Expanded(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.leaderboard,
                                color: const Color(0xFF228B22),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.get('final_scores', settings.language),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF228B22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF228B22).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Takım',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    'Puan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    'Doğru',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    'Pas',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    'Taboo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Team Scores
                          Expanded(
                            child: ListView.builder(
                              itemCount: sortedTeams.length,
                              itemBuilder: (context, index) {
                                final team = sortedTeams[index];
                                final isWinner = winners.contains(team);
                                final position = index + 1;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isWinner 
                                        ? Colors.amber.shade50
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isWinner 
                                          ? Colors.amber.shade300
                                          : Colors.grey.shade300,
                                      width: isWinner ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: position == 1 
                                                    ? Colors.amber.shade400
                                                    : position == 2 
                                                        ? Colors.grey.shade400
                                                        : position == 3 
                                                            ? Colors.brown.shade400
                                                            : Colors.blue.shade300,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$position',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                team.name,
                                                style: TextStyle(
                                                  fontWeight: isWinner 
                                                      ? FontWeight.bold 
                                                      : FontWeight.normal,
                                                  fontSize: 14,
                                                  color: isWinner 
                                                      ? Colors.amber.shade800
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${team.score}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isWinner 
                                                ? Colors.amber.shade800
                                                : null,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${team.correctGuesses}',
                                          style: const TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${team.skippedWords}',
                                          style: const TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${team.tabooViolations}',
                                          style: const TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.home, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.get('back_to_home', settings.language),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
