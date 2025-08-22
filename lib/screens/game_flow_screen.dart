import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../services/localization_service.dart';
import 'new_game_screen.dart';
import 'final_score_screen.dart';

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

    // Check if game should end because someone won
    if (_gameState.hasWinner) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _endGame();
        }
      });
      return;
    }

    // Move to next team (this might increment the round)
    final nextGameState = _gameState.nextTeam();
    setState(() {
      _gameState = nextGameState;
    });
    
    // After moving to next team, check if we've exceeded max rounds
    if (_gameState.currentRound > _gameState.maxRounds) {
      // All teams have completed all rounds - game is over
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _endGame();
        }
      });
    } else {
      // Continue to next round
      setState(() {
        _showingPreRound = true;
      });
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
    // Navigate to the final score screen instead of showing a dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FinalScoreScreen(
          gameState: _gameState,
          settings: widget.settings,
        ),
      ),
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
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                // Game Progress
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_esports,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.get('game_progress', widget.settings.language),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                              height: 30,
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
                const SizedBox(height: 16),

                // Current Team
                Card(
                  elevation: 6,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
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
                          size: 36,
                          color: const Color(0xFF228B22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.get('current_player', widget.settings.language),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _gameState.currentTeam.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF228B22),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
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
                const SizedBox(height: 16),

                // Scoreboard
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.leaderboard,
                              color: Colors.purple.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.get('scoreboard', widget.settings.language),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._gameState.teams.asMap().entries.map((entry) {
                          final index = entry.key;
                          final team = entry.value;
                          final isCurrentTeam = index == _gameState.currentTeamIndex;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                        size: 16,
                                      ),
                                      const SizedBox(width: 3),
                                    ],
                                    Text(
                                      team.name,
                                      style: TextStyle(
                                        fontSize: 14,
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
                                    fontSize: 14,
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
                
                const SizedBox(height: 16),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(12),
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
                        size: 20,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.get('round_instructions', widget.settings.language),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Start Round Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
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
                        const Icon(Icons.play_arrow, size: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppLocalizations.get('start_round', widget.settings.language),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
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
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
