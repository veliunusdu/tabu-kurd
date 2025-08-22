import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../services/localization_service.dart';
import 'new_game_screen.dart';

class GameFlowScreen extends StatefulWidget {
  final GameSettings settings;
  final List<Team> teams;

  const GameFlowScreen({
    super.key,
    required this.settings,
    required this.teams,
  });

  @override
  State<GameFlowScreen> createState() => _GameFlowScreenState();
}

class _GameFlowScreenState extends State<GameFlowScreen> {
  late GameState _gameState;
  bool _showingPreRound = true;

  @override
  void initState() {
    super.initState();
    _gameState = GameState(
      teams: widget.teams,
      maxRounds: widget.settings.numberOfRounds,
      targetScore: widget.settings.targetScore,
      totalTime: widget.settings.timePerRound,
      timeLeft: widget.settings.timePerRound,
      currentPlayerName: widget.teams.isNotEmpty ? widget.teams[0].name : '',
    );
  }

  void _startFirstRound() {
    setState(() {
      _showingPreRound = false;
    });
  }

  void _onRoundComplete(GameState newGameState) {
    setState(() {
      _gameState = newGameState;
    });

    // Check if game should end based on current state
    if (_gameState.shouldEndGame || _gameState.hasWinner) {
      // Add a small delay to ensure the UI updates properly
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _endGame();
        }
      });
    } else {
      // Move to next team and check again
      final nextGameState = _gameState.nextTeam();
      setState(() {
        _gameState = nextGameState;
      });
      
      // Check if game should end after moving to next team (which might increment round)
      if (_gameState.shouldEndGame || _gameState.hasWinner) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _endGame();
          }
        });
      } else {
        setState(() {
          _showingPreRound = true;
        });
      }
    }
  }

  void _endGame() {
    final endType = _gameState.hasWinner 
        ? GameEndType.targetScoreReached 
        : GameEndType.maxRoundsCompleted;
    
    setState(() {
      _gameState = _gameState.endGame(endType);
    });
    
    // Show game over dialog immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    final winners = _gameState.winners;
    final isMultipleWinners = winners.length > 1;
    
    // Debug print to ensure this method is called
    print('DEBUG: Showing game over dialog. Winners: ${winners.map((w) => w.name).join(", ")}');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber.shade600,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.get('game_over', widget.settings.language),
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Winner announcement
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade100, Colors.amber.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.celebration,
                          size: 48,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isMultipleWinners
                              ? AppLocalizations.get('tie_game', widget.settings.language)
                              : AppLocalizations.get('winner', widget.settings.language),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...winners.map((team) => Text(
                          team.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700,
                          ),
                        )),
                        const SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.get('final_score', widget.settings.language)}: ${winners.first.score}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Final scoreboard - PROMINENTLY DISPLAYED
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.leaderboard,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.get('final_scores', widget.settings.language),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._gameState.teams.map((team) {
                          final isWinner = winners.contains(team);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isWinner ? Colors.amber.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isWinner ? Colors.amber.shade400 : Colors.grey.shade300,
                                width: isWinner ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (isWinner) ...[
                                      Icon(
                                        Icons.emoji_events,
                                        color: Colors.amber.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      team.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                                        color: isWinner ? Colors.amber.shade800 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isWinner ? Colors.amber.shade100 : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${team.score}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isWinner ? Colors.amber.shade700 : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  // Game statistics
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.get('game_statistics', widget.settings.language),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.get('rounds_played', widget.settings.language)),
                            Text('${_gameState.currentRound}'),
                          ],
                        ),
                        if (_gameState.endType == GameEndType.targetScoreReached) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.get('target_reached', widget.settings.language)),
                              Text('${widget.settings.targetScore}'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).popUntil((route) => route.isFirst); // Go back to home screen
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              child: Text(AppLocalizations.get('back_to_menu', widget.settings.language)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset game state and start new game
                setState(() {
                  _gameState = GameState(
                    teams: widget.teams.map((team) => Team(name: team.name)).toList(),
                    maxRounds: widget.settings.numberOfRounds,
                    targetScore: widget.settings.targetScore,
                    totalTime: widget.settings.timePerRound,
                    timeLeft: widget.settings.timePerRound,
                    currentPlayerName: widget.teams.isNotEmpty ? widget.teams[0].name : '',
                  );
                  _showingPreRound = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.get('play_again', widget.settings.language)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gameState.gameCompleted) {
      // Return to home if game is completed but dialog isn't showing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
      return Scaffold(
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_showingPreRound) {
      return _buildPreRoundScreen();
    } else {
      return NewGameScreen(
        settings: widget.settings,
        teams: _gameState.teams,
        gameState: _gameState,
        onRoundComplete: _onRoundComplete,
      );
    }
  }

  Widget _buildPreRoundScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get('taboo_game', widget.settings.language)),
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
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
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                // Game Progress
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_esports,
                              color: Colors.blue.shade600,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.get('game_progress', widget.settings.language),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildProgressItem(
                              AppLocalizations.get('round', widget.settings.language),
                              '${_gameState.currentRound}/${_gameState.maxRounds}',
                              Icons.refresh,
                              Colors.orange,
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            _buildProgressItem(
                              AppLocalizations.get('target', widget.settings.language),
                              '${widget.settings.targetScore}',
                              Icons.flag,
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Current Team
                Card(
                  elevation: 6,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF228B22).withOpacity(0.1),
                          const Color(0xFF228B22).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_pin,
                          size: 48,
                          color: const Color(0xFF228B22),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.get('current_player', widget.settings.language),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _gameState.currentTeam.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF228B22),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.get('score', widget.settings.language)}: ${_gameState.currentTeam.score}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Scoreboard
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.leaderboard,
                              color: Colors.purple.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.get('scoreboard', widget.settings.language),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._gameState.teams.asMap().entries.map((entry) {
                          final index = entry.key;
                          final team = entry.value;
                          final isCurrentTeam = index == _gameState.currentTeamIndex;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isCurrentTeam 
                                  ? const Color(0xFF228B22).withOpacity(0.1)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCurrentTeam 
                                    ? const Color(0xFF228B22)
                                    : Colors.grey.shade300,
                                width: isCurrentTeam ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (isCurrentTeam) ...[
                                      Icon(
                                        Icons.play_arrow,
                                        color: const Color(0xFF228B22),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      team.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isCurrentTeam 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                        color: isCurrentTeam 
                                            ? const Color(0xFF228B22)
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${team.score}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentTeam 
                                        ? const Color(0xFF228B22)
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.get('round_instructions', widget.settings.language),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Start Round Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startFirstRound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF228B22),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.get('start_round', widget.settings.language),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
