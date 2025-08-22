import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/taboo_card.dart';
import '../models/team.dart';
import '../models/game_settings.dart';
import '../models/round_summary.dart';
import '../services/taboo_data_service.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import 'round_summary_screen.dart';
import '../models/game_state.dart';

class GameScreen extends StatefulWidget {
  final GameSettings? settings;
  final List<Team>? teams;
  final GameState? gameState;
  final Function(GameState)? onRoundComplete;

  const GameScreen({
    super.key, 
    this.settings, 
    this.teams,
    this.gameState,
    this.onRoundComplete,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<TabooCard> _cards = [];
  int _currentCardIndex = 0;
  int _timeLeft = 60;
  bool _gameActive = false;
  Timer? _timer;
  String _selectedCategory = "";
  late GameSettings _settings;
  late List<Team> _teams;
  int _currentTeamIndex = 0;
  int _currentRound = 1;
  int _skipsUsed = 0;
  
  // Round and game management
  int _maxRounds = 3;
  int _targetScore = 30;
  bool _gameCompleted = false;
  bool _roundInProgress = false;
  String _currentPlayerName = '';
  
  // Track cards for round summary
  List<String> _currentRoundCorrectWords = [];
  List<String> _currentRoundSkippedWords = [];
  List<String> _currentRoundTabooWords = [];
  
  // Animation controllers
  late AnimationController _correctAnimationController;
  late AnimationController _tabooAnimationController;
  late AnimationController _skipAnimationController;
  late AnimationController _cardFlipController;
  late AnimationController _pulseController;
  
  // Animations
  late Animation<double> _correctScaleAnimation;
  late Animation<double> _tabooShakeAnimation;
  late Animation<double> _skipSlideAnimation;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _showFeedback = false;
  String _feedbackType = '';

  // Haptic feedback method
  Future<void> _triggerHapticFeedback(String type) async {
    if (!_settings.soundEnabled) return;
    
    try {
      switch (type) {
        case 'success':
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
          break;
        case 'error':
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.heavyImpact();
          break;
        case 'skip':
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 50));
          await HapticFeedback.lightImpact();
          break;
        case 'select':
          await HapticFeedback.selectionClick();
          break;
        case 'timer':
          await HapticFeedback.mediumImpact();
          break;
        default:
          await HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Haptic feedback might not be available on all devices
    }
  }

  @override
  void initState() {
    super.initState();
    _settings = widget.settings ?? GameSettings();
    _teams = widget.teams ?? [
      Team(name: AppLocalizations.get('team_1', _settings.language)),
      Team(name: AppLocalizations.get('team_2', _settings.language)),
    ];
    _selectedCategory = AppLocalizations.get('all', _settings.language);
    _timeLeft = _settings.timePerRound;
    _maxRounds = _settings.numberOfRounds;
    _currentPlayerName = _teams.isNotEmpty ? _teams[_currentTeamIndex].name : '';
    _loadCards();
    
    // Initialize animation controllers
    _correctAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tabooAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _skipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cardFlipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Initialize animations
    _correctScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _correctAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _tabooShakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _tabooAnimationController,
      curve: Curves.elasticIn,
    ));
    
    _skipSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: _skipAnimationController,
      curve: Curves.easeOut,
    ));
    
    _cardFlipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardFlipController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  void _loadCards() async {
    final cards = await TabooDataService.getCardsByCategory(_selectedCategory, _settings.language);
    setState(() {
      _cards = cards;
      _cards.shuffle();
      _currentCardIndex = 0;
    });
  }

  void _startGame() {
    setState(() {
      _gameActive = true;
      for (var team in _teams) {
        team.score = 0;
        team.correctGuesses = 0;
        team.skippedWords = 0;
        team.tabooViolations = 0;
        team.wordsGuessed.clear();
        team.wordsSkipped.clear();
        team.tabooWordsUsed.clear();
      }
      _timeLeft = _settings.timePerRound;
      _currentCardIndex = 0;
      _currentRound = 1;
      _currentTeamIndex = 0;
      _skipsUsed = 0;
      _currentRoundCorrectWords.clear();
      _currentRoundSkippedWords.clear();
      _currentRoundTabooWords.clear();
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
      });
      
      if (_timeLeft <= 0) {
        SoundService.playTimeUpSound();
        _endRound();
      }
    });
  }

  void _endRound() {
    if (!_gameActive) return;
    
    _timer?.cancel();
    setState(() {
      _gameActive = false;
      _roundInProgress = false;
    });

    SoundService.playRoundEndSound();
    _triggerHapticFeedback('timer');
    _showRoundSummary();
  }

  void _showRoundSummary() {
    final currentTeam = _teams[_currentTeamIndex];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.timer, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.get('round_completed', _settings.language),
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.get('team', _settings.language)}: ${currentTeam.name}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${AppLocalizations.get('round', _settings.language)}: $_currentRound/$_maxRounds',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${AppLocalizations.get('points_earned', _settings.language)}: ${_currentRoundCorrectWords.length - _currentRoundTabooWords.length}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // All teams' current scores
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.leaderboard, color: Colors.blue.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.get('current_scores', _settings.language),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._teams.map((team) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${team.name}: ${team.score} ${AppLocalizations.get('points', _settings.language)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: team == currentTeam ? FontWeight.bold : FontWeight.normal,
                              color: team == currentTeam ? Colors.green.shade700 : Colors.black87,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Round statistics
                  if (_currentRoundCorrectWords.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${AppLocalizations.get('correct_guesses', _settings.language)} (${_currentRoundCorrectWords.length}):',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...(_currentRoundCorrectWords.map((word) => Padding(
                      padding: const EdgeInsets.only(left: 28, bottom: 2),
                      child: Text('• $word', style: const TextStyle(fontSize: 14)),
                    ))),
                    const SizedBox(height: 12),
                  ],
                  
                  if (_currentRoundTabooWords.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${AppLocalizations.get('taboo_violations', _settings.language)} (${_currentRoundTabooWords.length}):',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...(_currentRoundTabooWords.map((word) => Padding(
                      padding: const EdgeInsets.only(left: 28, bottom: 2),
                      child: Text('• $word', style: const TextStyle(fontSize: 14)),
                    ))),
                    const SizedBox(height: 12),
                  ],
                  
                  if (_currentRoundSkippedWords.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.skip_next, color: Colors.orange.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${AppLocalizations.get('skipped_words', _settings.language)} (${_currentRoundSkippedWords.length}):',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...(_currentRoundSkippedWords.map((word) => Padding(
                      padding: const EdgeInsets.only(left: 28, bottom: 2),
                      child: Text('• $word', style: const TextStyle(fontSize: 14)),
                    ))),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkGameEnd();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(AppLocalizations.get('continue', _settings.language)),
            ),
          ],
        );
      },
    );
  }

  void _checkGameEnd() {
    bool gameEndConditionMet = false;
    Team? winningTeam;
    
    // Update current team score
    int pointsEarned = _currentRoundCorrectWords.length - _currentRoundTabooWords.length;
    setState(() {
      _teams[_currentTeamIndex].score += pointsEarned;
    });
    
    // Check if any team reached target score
    for (Team team in _teams) {
      if (team.score >= _targetScore) {
        gameEndConditionMet = true;
        winningTeam = team;
        break;
      }
    }
    
    // Check if max rounds completed
    if (_currentRound > _maxRounds || (_currentRound == _maxRounds && _currentTeamIndex == _teams.length - 1)) {
      gameEndConditionMet = true;
    }
    
    if (gameEndConditionMet) {
      _gameCompleted = true;
      _showGameOverDialog();
    } else {
      _nextRound();
      _showNextTeamDialog();
    }
  }

  void _nextRound() {
    setState(() {
      _currentTeamIndex = (_currentTeamIndex + 1) % _teams.length;
      if (_currentTeamIndex == 0) {
        _currentRound++;
      }
      _timeLeft = _settings.timePerRound;
      _skipsUsed = 0;
      _currentPlayerName = _teams[_currentTeamIndex].name;
      _roundInProgress = false;
      _currentRoundCorrectWords.clear();
      _currentRoundSkippedWords.clear();
      _currentRoundTabooWords.clear();
      _loadCards();
    });
  }

  void _showNextTeamDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.people, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.get('next_turn', _settings.language),
                style: TextStyle(color: Colors.blue.shade700),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.green.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppLocalizations.get('now_playing', _settings.language)}:',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _teams[_currentTeamIndex].name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${AppLocalizations.get('round', _settings.language)}: $_currentRound/$_maxRounds',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(AppLocalizations.get('start_round', _settings.language)),
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog() {
    Team winningTeam = _teams.reduce((a, b) => a.score > b.score ? a : b);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.get('game_over', _settings.language)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${AppLocalizations.get('winner', _settings.language)}: ${winningTeam.name}'),
              Text('${AppLocalizations.get('score', _settings.language)}: ${winningTeam.score}'),
              const SizedBox(height: 10),
              ...(_teams.map((team) => Text('${team.name}: ${team.score} ${AppLocalizations.get('points', _settings.language)}'))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.get('back', _settings.language)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: Text(AppLocalizations.get('new_game_btn', _settings.language)),
            ),
          ],
        );
      },
    );
  }

  void _pauseGame() {
    _timer?.cancel();
    setState(() {
      _gameActive = false;
    });
    _showPauseDialog();
  }

  void _resumeGame() {
    setState(() {
      _gameActive = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
      });
      
      if (_timeLeft <= 0) {
        SoundService.playTimeUpSound();
        _endRound();
      }
    });
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.get('game_paused', _settings.language)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.get('current_team', _settings.language)}: ${_teams[_currentTeamIndex].name}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.get('time_left', _settings.language)}: $_timeLeft ${AppLocalizations.get('seconds', _settings.language)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.get('score', _settings.language)}: ${_teams[_currentTeamIndex].score}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resumeGame();
              },
              child: Text(AppLocalizations.get('back_to_game', _settings.language)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showGameOverDialog();
              },
              child: Text(AppLocalizations.get('end_game', _settings.language)),
            ),
          ],
        );
      },
    );
  }

  void _correctAnswer() {
    if (!_gameActive) return;
    
    final currentCard = _cards[_currentCardIndex];
    SoundService.playCorrectSound();
    _triggerHapticFeedback('success');
    
    setState(() {
      _showFeedback = true;
      _feedbackType = 'correct';
    });
    
    _correctAnimationController.forward().then((_) {
      _correctAnimationController.reverse();
      setState(() {
        _showFeedback = false;
      });
    });
    
    setState(() {
      _teams[_currentTeamIndex].addCorrectGuess(currentCard.word);
      _currentRoundCorrectWords.add(currentCard.word);
      _nextCard();
    });
  }

  void _tabooViolation() {
    if (!_gameActive) return;
    
    final currentCard = _cards[_currentCardIndex];
    SoundService.playTabooSound();
    _triggerHapticFeedback('error');
    
    setState(() {
      _showFeedback = true;
      _feedbackType = 'taboo';
    });
    
    _tabooAnimationController.forward().then((_) {
      _tabooAnimationController.reverse();
      setState(() {
        _showFeedback = false;
      });
    });
    
    setState(() {
      _teams[_currentTeamIndex].addTabooViolation(currentCard.word);
      _currentRoundTabooWords.add(currentCard.word);
      _nextCard();
    });
  }

  void _skipCard() {
    if (!_gameActive) return;
    
    if (_settings.skipsAllowed && _skipsUsed < _settings.maxSkipsPerRound) {
      final currentCard = _cards[_currentCardIndex];
      SoundService.playSkipSound();
      _triggerHapticFeedback('skip');
      
      setState(() {
        _showFeedback = true;
        _feedbackType = 'skip';
      });
      
      _skipAnimationController.forward().then((_) {
        _skipAnimationController.reverse();
        setState(() {
          _showFeedback = false;
        });
      });
      
      setState(() {
        _skipsUsed++;
        _teams[_currentTeamIndex].addSkip(currentCard.word);
        _currentRoundSkippedWords.add(currentCard.word);
        _nextCard();
      });
    } else if (!_settings.skipsAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('skips_not_allowed', _settings.language)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('no_more_skips', _settings.language)),
        ),
      );
    }
  }

  void _nextCard() {
    _cardFlipController.forward().then((_) {
      setState(() {
        _currentCardIndex = (_currentCardIndex + 1) % _cards.length;
      });
      _cardFlipController.reverse();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _correctAnimationController.dispose();
    _tabooAnimationController.dispose();
    _skipAnimationController.dispose();
    _cardFlipController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TabuKurd (BêGotin)'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          if (_gameActive)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _timeLeft <= 10 ? Colors.red.shade600 : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '$_timeLeft',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.yellow.shade50,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Status bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${AppLocalizations.get('team', _settings.language)}: ${_teams[_currentTeamIndex].name}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${AppLocalizations.get('score', _settings.language)}: ${_teams[_currentTeamIndex].score}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Text(
                        '${AppLocalizations.get('round', _settings.language)}: $_currentRound/$_maxRounds',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Category selection or game card
                Expanded(
                  flex: 4,
                  child: _gameActive ? _buildGameCard() : _buildPreGameView(),
                ),
                
                // Game controls
                if (_gameActive) ...[
                  const SizedBox(height: 16),
                  _buildGameControls(),
                  const SizedBox(height: 12),
                  _buildPauseButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreGameView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.play_circle_fill,
            size: 100,
            color: Color(0xFF228B22),
          ),
          const SizedBox(height: 20),
          
          // Category selection
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FutureBuilder<List<String>>(
              future: TabooDataService.getCategories(_settings.language),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                
                return DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.get('category', _settings.language),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  items: snapshot.data!.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      _loadCards();
                    }
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            '${_cards.length} ${AppLocalizations.get('taboo_words', _settings.language)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: Text(
              AppLocalizations.get('start', _settings.language),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard() {
    if (_cards.isEmpty) {
      return Center(
        child: Text(AppLocalizations.get('no_cards', _settings.language)),
      );
    }
    
    final card = _cards[_currentCardIndex];
    
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _cardFlipAnimation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_cardFlipAnimation.value * 3.14159),
              child: Card(
                elevation: 12,
                shadowColor: Colors.green.withOpacity(0.3),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade600,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          card.category,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      FittedBox(
                        child: Text(
                          card.word,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.get('taboo_words', _settings.language),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Flexible(
                                child: Column(
                                  children: card.tabooWords.map((word) => Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: FittedBox(
                                      child: Text(
                                        word,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Feedback animations
        if (_showFeedback) _buildFeedbackAnimation(),
      ],
    );
  }

  Widget _buildFeedbackAnimation() {
    switch (_feedbackType) {
      case 'correct':
        return AnimatedBuilder(
          animation: _correctScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _correctScaleAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 80, color: Colors.white),
              ),
            );
          },
        );
      case 'taboo':
        return AnimatedBuilder(
          animation: _tabooShakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_tabooShakeAnimation.value * (1 - (_tabooAnimationController.value * 2 - 1).abs()), 0),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 80, color: Colors.white),
              ),
            );
          },
        );
      case 'skip':
        return AnimatedBuilder(
          animation: _skipSlideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_skipSlideAnimation.value, 0),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.skip_next, size: 80, color: Colors.white),
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGameControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(child: _buildControlButton('correct', Colors.green, Icons.check_circle)),
          const SizedBox(width: 12),
          Expanded(child: _buildControlButton('taboo', Colors.red, Icons.cancel)),
          const SizedBox(width: 12),
          Expanded(child: _buildControlButton('skip', _settings.skipsAllowed ? Colors.orange : Colors.grey, Icons.skip_next)),
        ],
      ),
    );
  }

  Widget _buildControlButton(String type, Color color, IconData icon) {
    VoidCallback? onTap;
    String label;
    
    switch (type) {
      case 'correct':
        onTap = _correctAnswer;
        label = AppLocalizations.get('correct', _settings.language);
        break;
      case 'taboo':
        onTap = _tabooViolation;
        label = AppLocalizations.get('taboo', _settings.language);
        break;
      case 'skip':
        onTap = _settings.skipsAllowed ? _skipCard : null;
        label = AppLocalizations.get('skip', _settings.language);
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.shade400, color.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton() {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.orange.shade300, Colors.orange.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _pauseGame,
          child: Center(
            child: Text(
              AppLocalizations.get('pause', _settings.language),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
