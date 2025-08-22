import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/team.dart';
import '../services/taboo_data_service.dart';
import '../services/localization_service.dart';

/// Optimized Game Card Widget with minimal rebuilds
class OptimizedGameCard extends StatelessWidget {
  final String word;
  final List<String> tabooWords;
  final String category;
  final VoidCallback? onCorrect;
  final VoidCallback? onTaboo;
  final VoidCallback? onSkip;
  final bool gameActive;
  final String language;

  const OptimizedGameCard({
    super.key,
    required this.word,
    required this.tabooWords,
    required this.category,
    this.onCorrect,
    this.onTaboo,
    this.onSkip,
    required this.gameActive,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 350,
          maxHeight: 500,
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Main word
            Text(
              word,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Taboo words label
            Text(
              AppLocalizations.get('taboo_words', language),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Taboo words list
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tabooWords.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        tabooWords[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            if (gameActive) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    onPressed: onCorrect,
                    icon: Icons.check_circle,
                    color: Colors.green,
                    label: AppLocalizations.get('correct', language),
                  ),
                  _ActionButton(
                    onPressed: onTaboo,
                    icon: Icons.cancel,
                    color: Colors.red,
                    label: AppLocalizations.get('taboo', language),
                  ),
                  _ActionButton(
                    onPressed: onSkip,
                    icon: Icons.skip_next,
                    color: Colors.orange,
                    label: AppLocalizations.get('skip', language),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;
  final String label;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: color,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized Timer Widget with minimal rebuilds
class OptimizedTimer extends StatelessWidget {
  final int timeLeft;
  final int totalTime;
  final bool isActive;

  const OptimizedTimer({
    super.key,
    required this.timeLeft,
    required this.totalTime,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final progress = timeLeft / totalTime;
    final isLowTime = timeLeft <= 10;

    return RepaintBoundary(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress circle
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isLowTime ? Colors.red : Colors.blue,
                ),
              ),
            ),
            // Time text
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isLowTime ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: isLowTime ? Colors.red : Colors.blue.shade800,
              ),
              child: Text('$timeLeft'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Performance-optimized Team Score Widget
class OptimizedTeamScore extends StatelessWidget {
  final Team team;
  final bool isCurrentTeam;
  final String language;

  const OptimizedTeamScore({
    super.key,
    required this.team,
    required this.isCurrentTeam,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrentTeam ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentTeam ? Colors.blue : Colors.grey.shade300,
            width: isCurrentTeam ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              team.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrentTeam ? Colors.blue.shade800 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.get('score', language)}: ${team.score}',
              style: TextStyle(
                fontSize: 14,
                color: isCurrentTeam ? Colors.blue.shade600 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
