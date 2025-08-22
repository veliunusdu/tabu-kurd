import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/taboo_card.dart';
import 'localization_service.dart';

class TabooDataService {
  // Cache for loaded data
  static Map<String, dynamic>? _cachedData;
  static final Map<String, List<TabooCard>> _cardCache = {};
  static final Map<String, List<String>> _categoryCache = {};
  
  // Load data once and cache it
  static Future<void> _loadData() async {
    if (_cachedData != null) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/taboo_cards.json');
      _cachedData = json.decode(jsonString);
    } catch (e) {
      print('Error loading taboo cards: $e');
      // Fallback to hardcoded data if JSON fails
      _cachedData = _getFallbackData();
    }
  }

  // Efficient card loading with caching
  static Future<List<TabooCard>> getAllCards(String language) async {
    final cacheKey = 'all_$language';
    if (_cardCache.containsKey(cacheKey)) {
      return _cardCache[cacheKey]!;
    }

    await _loadData();
    final List<TabooCard> cards = [];
    
    final languageData = _cachedData?[language] as Map<String, dynamic>?;
    if (languageData == null) return cards;

    for (final categoryName in languageData.keys) {
      final categoryCards = languageData[categoryName] as List<dynamic>;
      final localizedCategory = AppLocalizations.get(categoryName, language);
      
      for (final cardData in categoryCards) {
        cards.add(TabooCard(
          word: cardData['word'] as String,
          tabooWords: List<String>.from(cardData['tabooWords']),
          category: localizedCategory,
        ));
      }
    }
    
    // Cache the result
    _cardCache[cacheKey] = cards;
    return cards;
  }

  // Efficient category loading with caching
  static Future<List<String>> getCategories(String language) async {
    if (_categoryCache.containsKey(language)) {
      return _categoryCache[language]!;
    }

    final categories = [
      AppLocalizations.get('all', language),
      AppLocalizations.get('family', language),
      AppLocalizations.get('animals', language),
      AppLocalizations.get('food', language),
      AppLocalizations.get('drinks', language),
      AppLocalizations.get('nature', language),
      AppLocalizations.get('body', language),
      AppLocalizations.get('colors', language),
      AppLocalizations.get('transportation', language),
      AppLocalizations.get('education', language),
    ];
    
    _categoryCache[language] = categories;
    return categories;
  }

  // Efficient filtered card loading
  static Future<List<TabooCard>> getCardsByCategory(String category, String language) async {
    final allCategory = AppLocalizations.get('all', language);
    if (category == allCategory) {
      return getAllCards(language);
    }

    final cacheKey = '${category}_$language';
    if (_cardCache.containsKey(cacheKey)) {
      return _cardCache[cacheKey]!;
    }

    final allCards = await getAllCards(language);
    final filteredCards = allCards.where((card) => card.category == category).toList();
    
    _cardCache[cacheKey] = filteredCards;
    return filteredCards;
  }

  // Get a specific number of random cards for memory efficiency
  static Future<List<TabooCard>> getRandomCards(String language, {int count = 50}) async {
    final allCards = await getAllCards(language);
    if (allCards.length <= count) return allCards;
    
    final shuffled = List<TabooCard>.from(allCards)..shuffle();
    return shuffled.take(count).toList();
  }

  // Clear cache to free memory when needed
  static void clearCache() {
    _cardCache.clear();
    _categoryCache.clear();
    _cachedData = null;
  }

  // Preload data for better performance
  static Future<void> preloadData(String language) async {
    await getAllCards(language);
    await getCategories(language);
  }

  // Fallback data in case JSON loading fails
  static Map<String, dynamic> _getFallbackData() {
    return {
      'kurmanci': {
        'family': [
          {
            'word': 'Dê (Mother)',
            'tabooWords': ['Bav', 'Zarok', 'Mal', 'Xizm', 'Jin']
          },
          {
            'word': 'Bav (Father)',
            'tabooWords': ['Dê', 'Kur', 'Keç', 'Mal', 'Mêr']
          }
        ],
        'animals': [
          {
            'word': 'Şêr (Lion)',
            'tabooWords': ['Heywan', 'Gur', 'Dar', 'Nêçîr', 'Gazî']
          }
        ]
      },
      'turkish': {
        'family': [
          {
            'word': 'Anne (Mother)',
            'tabooWords': ['Baba', 'Çocuk', 'Ev', 'Aile', 'Kadın']
          }
        ]
      }
    };
  }
}
