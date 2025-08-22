import 'package:flutter/material.dart';
import 'team_setup_screen.dart';
import 'settings_screen.dart';
import 'rules_screen.dart';
import 'custom_card_screen.dart';
import '../models/game_settings.dart';
import '../services/localization_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/language_switcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameSettings _settings = GameSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'TabuKurd ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '(BêGotin)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.yellow,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade100,
        foregroundColor: Colors.green.shade800,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CompactLanguageSwitcher(
              currentLanguage: _settings.language,
              onLanguageChanged: (String newLanguage) {
                setState(() {
                  _settings = _settings.copyWith(language: newLanguage);
                });
              },
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
            padding: const EdgeInsets.all(16.0), // Reduced from 20
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title section
                Container(
                  padding: const EdgeInsets.all(20), // Reduced from 30
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const AppLogo(size: 100, animated: true), // Reduced from 120
                      const SizedBox(height: 16), // Reduced from 20
                      Text(
                        'KURDISH',
                        style: TextStyle(
                          fontSize: 28, // Reduced from 32
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          letterSpacing: 3,
                        ),
                      ),
                      Text(
                        'Taboo',
                        style: TextStyle(
                          fontSize: 20, // Reduced from 24
                          fontWeight: FontWeight.w300,
                          color: Colors.orange.shade600,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8), // Reduced from 10
                      Text(
                        AppLocalizations.get('family_game', _settings.language),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Menu buttons
                _buildMenuButton(
                  context,
                  title: AppLocalizations.get('new_game', _settings.language),
                  icon: Icons.play_arrow,
                  color: Colors.green.shade600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamSetupScreen(settings: _settings),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12), // Reduced from 16
                
                _buildMenuButton(
                  context,
                  title: AppLocalizations.get('rules', _settings.language),
                  icon: Icons.rule,
                  color: Colors.blue.shade600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RulesScreen(language: _settings.language),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12), // Reduced from 16
                
                _buildMenuButton(
                  context,
                  title: AppLocalizations.get('settings', _settings.language),
                  icon: Icons.settings,
                  color: Colors.orange.shade600,
                  onTap: () async {
                    final updatedSettings = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(settings: _settings),
                      ),
                    );
                    if (updatedSettings != null) {
                      setState(() {
                        _settings = updatedSettings;
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 12), // Reduced from 16
                
                _buildMenuButton(
                  context,
                  title: AppLocalizations.get('custom_cards', _settings.language),
                  icon: Icons.create,
                  color: Colors.purple.shade600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomCardScreen(language: _settings.language),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12), // Reduced from 16
                
                _buildMenuButton(
                  context,
                  title: AppLocalizations.get('about', _settings.language),
                  icon: Icons.info_outline,
                  color: Colors.purple.shade600,
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                
                const SizedBox(height: 24), // Reduced from 40
                
                // Footer text
                Text(
                  AppLocalizations.get('made_with_love', _settings.language),
                  style: TextStyle(
                    fontSize: 10, // Reduced from 12
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 60, // Reduced from 70
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TabuKurd',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF228B22),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'BêGotin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF228B22),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BêGotin - یارییا وشەیا قەدەخەیا کوردی',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF228B22),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Kurdish Word Guessing Game',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TabuKurd is a fun word guessing game designed for Kurdish families and friends. Challenge your teammates to guess words without using the forbidden words!',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Features:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF228B22),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Kurdish language support (Kurmanci & Sorani)\n'
                '• Multiple game categories\n'
                '• Team-based scoring\n'
                '• Customizable game settings\n'
                '• Sound effects and animations',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.get('created_by', _settings.language),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF228B22),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF228B22),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
