import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class RulesScreen extends StatelessWidget {
  final String? language;
  
  const RulesScreen({super.key, this.language});

  @override
  Widget build(BuildContext context) {
    final lang = language ?? 'kurmanci';
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get('rules', lang)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleCard(
              title: AppLocalizations.get('game_objective', lang),
              content: AppLocalizations.get('objective_text', lang),
              icon: Icons.flag,
              color: const Color(0xFF228B22),
            ),
            
            _buildRuleCard(
              title: AppLocalizations.get('how_to_play', lang),
              content: AppLocalizations.get('how_to_play_text', lang),
              icon: Icons.play_arrow,
              color: const Color(0xFFFFD700),
            ),
            
            _buildRuleCard(
              title: AppLocalizations.get('rules_title', lang),
              content: AppLocalizations.get('rules_text', lang),
              icon: Icons.rule,
              color: const Color(0xFFDC143C),
            ),
            
            _buildRuleCard(
              title: AppLocalizations.get('scoring_title', lang),
              content: AppLocalizations.get('scoring_text', lang),
              icon: Icons.stars,
              color: const Color(0xFF9C27B0),
            ),
            
            _buildRuleCard(
              title: AppLocalizations.get('tips_title', lang),
              content: AppLocalizations.get('tips_text', lang),
              icon: Icons.lightbulb,
              color: const Color(0xFFFF9800),
            ),
            
            const SizedBox(height: 20),
            
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  AppLocalizations.get('back', lang),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
