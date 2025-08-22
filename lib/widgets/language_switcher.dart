import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class LanguageSwitcher extends StatefulWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;
  final bool showLabels;

  const LanguageSwitcher({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
    this.showLabels = true,
  });

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showLanguageDialog() {
    _animationController.forward().then((_) => _animationController.reverse());
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.language,
                color: Color(0xFF228B22),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.get('select_language', widget.currentLanguage),
                style: const TextStyle(
                  color: Color(0xFF228B22),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                'kurmanci',
                'کورمانجی',
                'Kurmancî',
                Icons.flag,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildLanguageOption(
                'sorani',
                'سۆرانی',
                'Soranî',
                Icons.flag,
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildLanguageOption(
                'turkish',
                'Türkçe',
                'Turkish',
                Icons.flag,
                Colors.red,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.get('cancel', widget.currentLanguage),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String languageCode,
    String nativeName,
    String englishName,
    IconData icon,
    Color color,
  ) {
    final bool isSelected = widget.currentLanguage == languageCode;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          nativeName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? color : Colors.black87,
          ),
        ),
        subtitle: Text(
          englishName,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? color.withOpacity(0.8) : Colors.grey.shade600,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              )
            : null,
        onTap: () {
          widget.onLanguageChanged(languageCode);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 0.1, // Subtle rotation
            child: InkWell(
              onTap: _showLanguageDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF228B22).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF228B22).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language,
                      color: Color(0xFF228B22),
                      size: 20,
                    ),
                    if (widget.showLabels) ...[
                      const SizedBox(width: 8),
                      Text(
                        _getLanguageDisplayName(widget.currentLanguage),
                        style: const TextStyle(
                          color: Color(0xFF228B22),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF228B22),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'kurmanci':
        return 'کورمانجی';
      case 'sorani':
        return 'سۆرانی';
      case 'turkish':
        return 'Türkçe';
      default:
        return 'Language';
    }
  }
}

// Compact language switcher for app bars
class CompactLanguageSwitcher extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const CompactLanguageSwitcher({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LanguageSwitcher(
      currentLanguage: currentLanguage,
      onLanguageChanged: onLanguageChanged,
      showLabels: false,
    );
  }
}
