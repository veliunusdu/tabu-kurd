import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/taboo_card.dart';
import '../models/team.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../services/taboo_data_service.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';

class NewGameScreen extends StatefulWidget {
  final GameSettings settings;
  final List<Team> teams;
  final GameState gameState;
  final Function(GameState) onRoundComplete;

  const NewGameScreen({
    super.key,
    required this.settings,
    required this.teams,
    required this.gameState,
    required this.onRoundComplete,
  });

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> with TickerProviderStateMixin {
  List<TabooCard> _cards = [];
  int _currentCardIndex = 0;
  int _timeLeft = 60;
  bool _gameActive = false;
  Timer? _timer;
  String _selectedCategory = "";
  late GameState _gameState;
  int _skipsUsed = 0;
  
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

  Future<void> _triggerHapticFeedback(String type) async {
    try {
      switch (type) {
        case 'success':
          await HapticFeedback.lightImpact();
          break;
        case 'error':
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
    _gameState = widget.gameState;
    _selectedCategory = AppLocalizations.get('all', widget.settings.language);
    _timeLeft = widget.settings.timePerRound;
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
    
    // Start pulse animation for timer when game is active
    _pulseController.repeat(reverse: true);
    
    // Auto-start the game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
    });
  }

  void _loadCards() async {
    final cards = await TabooDataService.getCardsByCategory(_selectedCategory, widget.settings.language);
    setState(() {
      _cards = cards;
      _cards.shuffle();
      _currentCardIndex = 0;
    });
  }

  void _startGame() {
    setState(() {
      _gameActive = true;
      _timeLeft = widget.settings.timePerRound;
      _currentCardIndex = 0;
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
    });

    // Update team scores
    final currentTeam = _gameState.currentTeam;
    final pointsEarned = _currentRoundCorrectWords.length - _currentRoundTabooWords.length;
    
    // Update the team in the teams list
    final updatedTeams = List<Team>.from(_gameState.teams);
    updatedTeams[_gameState.currentTeamIndex] = currentTeam.copyWith(
      score: currentTeam.score + pointsEarned,
      correctGuesses: currentTeam.correctGuesses + _currentRoundCorrectWords.length,
      skippedWords: currentTeam.skippedWords + _currentRoundSkippedWords.length,
      tabooViolations: currentTeam.tabooViolations + _currentRoundTabooWords.length,
      wordsGuessed: [...currentTeam.wordsGuessed, ..._currentRoundCorrectWords],
      wordsSkipped: [...currentTeam.wordsSkipped, ..._currentRoundSkippedWords],
      tabooWordsUsed: [...currentTeam.tabooWordsUsed, ..._currentRoundTabooWords],
    );

    // Create new game state
    final newGameState = _gameState.copyWith(teams: updatedTeams);
    
    // Show round summary and then call completion callback
    _showRoundSummary(newGameState);
  }

  void _showRoundSummary(GameState newGameState) {
    final currentTeam = newGameState.currentTeam;
    final pointsEarned = _currentRoundCorrectWords.length - _currentRoundTabooWords.length;
    
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
                AppLocalizations.get('round_completed', widget.settings.language),
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current team info
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
                          '${AppLocalizations.get('team', widget.settings.language)}: ${currentTeam.name}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${AppLocalizations.get('points_earned', widget.settings.language)}: $pointsEarned',
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.w600,
                            color: pointsEarned >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // All Teams Current Scores
                  Container(
                    width: double.infinity,
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
                            Icon(Icons.leaderboard, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.get('current_scores', widget.settings.language),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...newGameState.teams.map((team) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  team.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: team == currentTeam ? FontWeight.bold : FontWeight.normal,
                                    color: team == currentTeam ? Colors.blue.shade800 : Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '${team.score} ${AppLocalizations.get('points', widget.settings.language)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: team == currentTeam ? Colors.blue.shade800 : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Round statistics (condensed)
                  if (_currentRoundCorrectWords.isNotEmpty || _currentRoundTabooWords.isNotEmpty || _currentRoundSkippedWords.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.get('round_statistics', widget.settings.language),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('✓ ${AppLocalizations.get('correct', widget.settings.language)}:', 
                                style: TextStyle(color: Colors.green.shade700)),
                              Text('${_currentRoundCorrectWords.length}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('❌ ${AppLocalizations.get('taboo', widget.settings.language)}:', 
                                style: TextStyle(color: Colors.red.shade700)),
                              Text('${_currentRoundTabooWords.length}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('⏭ ${AppLocalizations.get('skipped', widget.settings.language)}:', 
                                style: TextStyle(color: Colors.orange.shade700)),
                              Text('${_currentRoundSkippedWords.length}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Call the completion callback with updated game state
                widget.onRoundComplete(newGameState);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.get('continue', widget.settings.language)),
            ),
          ],
        );
      },
    );
  }

  void _pauseGame() {
    _timer?.cancel();
    _showPauseDialog();
  }

  void _resumeGame() {
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
          title: Text(AppLocalizations.get('game_paused', widget.settings.language)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.get('current_team', widget.settings.language)}: ${_gameState.currentTeam.name}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.get('time_left', widget.settings.language)}: $_timeLeft ${AppLocalizations.get('seconds', widget.settings.language)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.get('score', widget.settings.language)}: ${_gameState.currentTeam.score}',
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
              child: Text(AppLocalizations.get('back_to_game', widget.settings.language)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.get('end_game', widget.settings.language)),
            ),
          ],
        );
      },
    );
  }

  void _correctGuess() {
    if (!_gameActive || _currentCardIndex >= _cards.length) return;
    
    final currentCard = _cards[_currentCardIndex];
    SoundService.playCorrectSound();
    
    // Add haptic feedback for correct answer
    _triggerHapticFeedback('success');
    
    // Trigger correct animation
    _correctAnimationController.forward().then((_) {
      _correctAnimationController.reverse();
    });
    
    setState(() {
      _currentRoundCorrectWords.add(currentCard.word);
      _nextCard();
    });
  }

  void _tabooViolation() {
    if (!_gameActive || _currentCardIndex >= _cards.length) return;
    
    final currentCard = _cards[_currentCardIndex];
    SoundService.playTabooSound();
    
    // Add haptic feedback for taboo violation
    _triggerHapticFeedback('error');
    
    // Trigger taboo animation
    _tabooAnimationController.forward().then((_) {
      _tabooAnimationController.reverse();
    });
    
    setState(() {
      _currentRoundTabooWords.add(currentCard.word);
      _nextCard();
    });
  }

  void _skipCard() {
    if (!_gameActive || _currentCardIndex >= _cards.length) return;
    
    if (widget.settings.skipsAllowed && _skipsUsed < widget.settings.maxSkipsPerRound) {
      final currentCard = _cards[_currentCardIndex];
      SoundService.playSkipSound();
      
      // Add haptic feedback for skip
      _triggerHapticFeedback('skip');
      
      // Trigger skip animation
      _skipAnimationController.forward().then((_) {
        _skipAnimationController.reverse();
      });
      
      setState(() {
        _skipsUsed++;
        _currentRoundSkippedWords.add(currentCard.word);
        _nextCard();
      });
    } else if (!widget.settings.skipsAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('skips_not_allowed', widget.settings.language)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('no_more_skips', widget.settings.language)),
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
        title: Row(
          children: [
            Expanded(
              child: Text(AppLocalizations.get('taboo_game', widget.settings.language)),
            ),
            // Timer in AppBar
            if (_gameActive)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _gameActive ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 70, // Increased from 60 to 70
                      height: 70, // Increased from 60 to 70
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _timeLeft <= 10
                            ? Colors.red.shade600
                            : Colors.white.withOpacity(0.9),
                        border: Border.all(
                          color: _timeLeft <= 10 ? Colors.red.shade800 : const Color(0xFF228B22),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_timeLeft',
                          style: TextStyle(
                            fontSize: 24, // Increased from 20 to 24
                            fontWeight: FontWeight.bold,
                            color: _timeLeft <= 10 ? Colors.white : const Color(0xFF228B22),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        actions: [
          if (_gameActive) ...[
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: _pauseGame,
            ),
          ],
        ],
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
          child: Column(
            children: [
              // Game Status Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8), // Reduced from 16 to 8
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusItem(
                      AppLocalizations.get('team', widget.settings.language),
                      _gameState.currentTeam.name,
                      Icons.group,
                      const Color(0xFF228B22),
                    ),
                    Container(height: 30, width: 1, color: Colors.grey.shade300), // Reduced height from 40 to 30
                    _buildStatusItem(
                      AppLocalizations.get('score', widget.settings.language),
                      '${_gameState.currentTeam.score}',
                      Icons.stars,
                      Colors.orange.shade600,
                    ),
                    Container(height: 30, width: 1, color: Colors.grey.shade300), // Reduced height from 40 to 30
                    _buildStatusItem(
                      AppLocalizations.get('round', widget.settings.language),
                      '${_gameState.currentRound}/${_gameState.maxRounds}',
                      Icons.refresh,
                      Colors.blue.shade600,
                    ),
                  ],
                ),
              ),
              
              // Card Display (Made Much Larger)
              Expanded(
                flex: 4, // Increased from 3 to 4 for bigger cards
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: AnimatedBuilder(
                    animation: _cardFlipAnimation,
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_cardFlipAnimation.value * 3.14159),
                        child: SizedBox(
                          height: double.infinity,
                          child: _cards.isNotEmpty
                              ? _buildLargeCard(_cards[_currentCardIndex])
                              : _buildLoadingCard(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Skip Counter
              if (widget.settings.skipsAllowed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.skip_next, color: Colors.orange.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '${AppLocalizations.get('skips_remaining', widget.settings.language)}: ${widget.settings.maxSkipsPerRound - _skipsUsed}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Taboo Button
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _tabooShakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_tabooShakeAnimation.value, 0),
                            child: Container(
                              height: 80,
                              margin: const EdgeInsets.only(right: 8),
                              child: ElevatedButton(
                                onPressed: _gameActive ? _tabooViolation : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.cancel, size: 28),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalizations.get('taboo', widget.settings.language),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Skip Button (if enabled)
                    if (widget.settings.skipsAllowed) ...[
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _skipSlideAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _skipSlideAnimation.value),
                              child: Container(
                                height: 80,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                  onPressed: (_gameActive && _skipsUsed < widget.settings.maxSkipsPerRound) 
                                      ? _skipCard 
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade600,
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.skip_next, size: 28),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppLocalizations.get('skip', widget.settings.language),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    
                    // Correct Button
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _correctScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _correctScaleAnimation.value,
                            child: Container(
                              height: 80,
                              margin: const EdgeInsets.only(left: 8),
                              child: ElevatedButton(
                                onPressed: _gameActive ? _correctGuess : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, size: 28),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalizations.get('correct', widget.settings.language),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18), // Reduced from 24 to 18
        const SizedBox(height: 2), // Reduced from 4 to 2
        Text(
          label,
          style: TextStyle(
            fontSize: 10, // Reduced from 12 to 10
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 1), // Reduced from 2 to 1
        Text(
          value,
          style: TextStyle(
            fontSize: 14, // Reduced from 16 to 14
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLargeCard(TabooCard card) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Main Word - No border, better fitting
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF228B22).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  card.word,
                  style: const TextStyle(
                    fontSize: 32, // Larger size that will scale down if needed
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF228B22),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Taboo Words Section Header
            Text(
              AppLocalizations.get('taboo_words', widget.settings.language),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 4),
            
            // Taboo Words List - Flexible to take remaining space
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: card.tabooWords.map((tabooWord) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          tabooWord,
                          style: TextStyle(
                            fontSize: 20, // Larger size that will scale down if needed
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
