import 'package:flutter/material.dart';
import '../models/round_summary.dart';
import '../models/team.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';

class RoundSummaryScreen extends StatelessWidget {
  final RoundSummary roundSummary;
  final List<Team> allTeams;
  final int totalRounds;
  final String language;
  final VoidCallback onNextRound;
  final VoidCallback onEndGame;

  const RoundSummaryScreen({
    super.key,
    required this.roundSummary,
    required this.allTeams,
    required this.totalRounds,
    required this.language,
    required this.onNextRound,
    required this.onEndGame,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.get('round', language)} ${roundSummary.roundNumber} ${AppLocalizations.get('game_over', language)}'),
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Round performance card
            Card(
              elevation: 8,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF228B22), Color(0xFF32CD32)],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      roundSummary.teamName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.check_circle,
                          '${roundSummary.wordsGuessed}',
                          AppLocalizations.get('correct', language),
                          Colors.white,
                        ),
                        _buildStatItem(
                          Icons.skip_next,
                          '${roundSummary.wordsSkipped}',
                          AppLocalizations.get('skip', language),
                          Colors.white70,
                        ),
                        _buildStatItem(
                          Icons.warning,
                          '${roundSummary.tabooViolations}',
                          AppLocalizations.get('taboo_words', language),
                          Colors.red[200]!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${AppLocalizations.get('points', language)}: ${roundSummary.pointsEarned >= 0 ? '+' : ''}${roundSummary.pointsEarned}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Current leaderboard
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.leaderboard, color: Color(0xFF228B22)),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.get('score', language),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...allTeams.asMap().entries.map((entry) {
                      final index = entry.key;
                      final team = entry.value;
                      final isCurrentTeam = team.name == roundSummary.teamName;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrentTeam 
                              ? const Color(0xFF228B22).withOpacity(0.1)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: isCurrentTeam 
                              ? Border.all(color: const Color(0xFF228B22), width: 2)
                              : null,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: index == 0 
                                  ? const Color(0xFFFFD700) // Gold color
                                  : index == 1 
                                      ? Colors.grey[400] 
                                      : Colors.brown[300],
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                team.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isCurrentTeam ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              '${team.score} ${AppLocalizations.get('points', language)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCurrentTeam ? const Color(0xFF228B22) : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Words details
            if (roundSummary.correctWords.isNotEmpty || roundSummary.skippedWords.isNotEmpty) ...[
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.get('round', language) + ' Details',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (roundSummary.correctWords.isNotEmpty) ...[
                                  Text(
                                    '✅ ${AppLocalizations.get('correct', language)}:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  ...roundSummary.correctWords.map((word) => 
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, top: 4),
                                      child: Text('• $word'),
                                    )
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (roundSummary.skippedWords.isNotEmpty) ...[
                                  Text(
                                    '⏭️ ${AppLocalizations.get('skip', language)}:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  ...roundSummary.skippedWords.map((word) => 
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, top: 4),
                                      child: Text('• $word'),
                                    )
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                if (roundSummary.roundNumber < totalRounds) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SoundService.playRoundEndSound();
                        onNextRound();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        'Start Next Round',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SoundService.playGameOverSound();
                        onEndGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        'Final Results',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}
