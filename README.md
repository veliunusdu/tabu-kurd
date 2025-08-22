# Kurdish Taboo - Taboya Kurdî - تابۆی کوردی

A comprehensive multilingual Kurdish word guessing game built with Flutter! Perfect for family gatherings and friends. Now supports **Kurmanci (Northern Kurdish)**, **Sorani (Central Kurdish)**, and **Turkish**.

## 🌟 New Features

### 🎮 Enhanced Game Features
- **Multi-language Support**: Full support for Kurmanci, Sorani, and Turkish
- **Team Management**: Create 2-6 teams with custom names
- **Round-based Gameplay**: Play 1-10 rounds with different teams
- **Player Count Configuration**: 2-8 players per team
- **Skip Control**: Enable/disable skipping with configurable limits (1-5 skips per round)
- **Offline Capability**: Works completely offline without internet connection
- **Advanced Timer**: Configurable time limits (30-120 seconds per round)

### 🏆 Team & Competition Features
- **Team Setup Screen**: Create and name your teams before starting
- **Score Tracking**: Individual team scores across multiple rounds
- **Round Management**: Automatic team rotation between rounds
- **Winner Declaration**: Automatic winner calculation at game end
- **Skip Tracking**: Monitor remaining skips per round

### 🌍 Language Features
- **Default Language**: Kurmanci (Northern Kurdish) as the default
- **Language Switching**: Change language in settings
- **Localized Content**: All UI elements translated to all three languages
- **Multi-script Support**: Latin script (Kurmanci/Turkish) and Arabic script (Sorani)

## 🎯 How to Play

### Game Setup
1. **Language Selection**: Choose Kurmanci, Sorani, or Turkish in settings
2. **Team Creation**: Set up 2-6 teams with custom names
3. **Configure Settings**: Adjust rounds, time limits, and skip rules
4. **Start Playing**: Begin the multi-round tournament

### Gameplay
1. **Team Turns**: Teams take turns describing words
2. **Word Description**: Describe the word without using taboo words
3. **Team Guessing**: Team members try to guess the correct word
4. **Scoring**: +1 point for correct guesses, skip if needed
5. **Round Rotation**: Teams alternate after each round

### Winning
- Play multiple rounds with all teams
- Team with highest total score wins
- Automatic winner declaration at game end

## 📱 Enhanced Screens

### Home Screen
- Language-aware welcome message
- Clean navigation to all features
- Settings integration

### Team Setup Screen
- Configure number of teams (2-6)
- Custom team naming
- Player count per team
- Game settings summary

### Enhanced Game Screen
- Real-time team and round tracking
- Skip counter (if enabled)
- Multi-language card display
- Round-end summaries

### Advanced Settings Screen
- **Game Duration**: 30-120 seconds per round
- **Number of Rounds**: 1-10 rounds
- **Players per Team**: 2-8 players
- **Skip Settings**: Enable/disable with configurable limits
- **Language Selection**: Kurmanci/Sorani/Turkish
- **Offline Mode**: Complete offline functionality

### Multilingual Rules Screen
- Complete rules in selected language
- Game objective and strategy tips
- Scoring system explanation

## 🗂️ Sample Cards by Language

### Kurmanci (Northern Kurdish)
- **Malbat**: Dê (Mother), Bav (Father), Bira (Brother), Xwişk (Sister)
- **Heywan**: Şêr (Lion), Se (Dog), Pisîk (Cat)
- **Xwarin**: Nan (Bread), Av (Water), Çay (Tea)
- **Sirûşt**: Roj (Sun), Heyv (Moon)

### Sorani (Central Kurdish)
- **خێزان**: دایک (Mother), باوک (Father), برا (Brother)
- **ئاژەڵان**: شێر (Lion), سەگ (Dog), پشیلە (Cat)
- **خواردن**: نان (Bread), ئاو (Water), چا (Tea)
- **سروشت**: خۆر (Sun), مانگ (Moon)

### Turkish
- **Aile**: Anne (Mother), Baba (Father), Kardeş (Sibling)
- **Hayvanlar**: Aslan (Lion), Köpek (Dog), Kedi (Cat)
- **Yemek**: Ekmek (Bread), Su (Water), Çay (Tea)
- **Doğa**: Güneş (Sun), Ay (Moon)

## 🔧 Technical Enhancements

### Architecture Updates
```
lib/
├── main.dart                           # App entry point
├── models/
│   └── taboo_card.dart                # Enhanced models with Team class
├── screens/
│   ├── home_screen.dart               # Enhanced home with language support
│   ├── team_setup_screen.dart         # NEW: Team configuration
│   ├── game_screen.dart               # Enhanced with rounds and teams
│   ├── rules_screen.dart              # Multilingual rules
│   └── settings_screen.dart           # Advanced settings
├── services/
│   ├── localization_service.dart      # NEW: Multi-language support
│   └── taboo_data_service.dart        # Enhanced with 3 languages
└── widgets/                           # Reusable components
```

### New Models
- **Team Class**: Name and score tracking
- **Enhanced GameSettings**: All new configuration options
- **Localization Service**: Complete translation system

### Data Structure
- **Language-specific Cards**: Separate card sets for each language
- **Category Localization**: Translated category names
- **Dynamic Content**: Language-aware UI updates

## 🎮 Game Configuration

### Team Settings
- **Teams**: 2-6 teams supported
- **Players**: 2-8 players per team
- **Naming**: Custom team names

### Round Settings
- **Rounds**: 1-10 rounds per game
- **Duration**: 30-120 seconds per round
- **Rotation**: Automatic team switching

### Skip Settings
- **Toggle**: Enable/disable skipping
- **Limits**: 1-5 skips per round
- **Tracking**: Real-time skip counter

### Language Settings
- **Default**: Kurmanci (Northern Kurdish)
- **Options**: Kurmanci, Sorani, Turkish
- **Runtime**: Change language without restart

## 🌐 Platform Support
- ✅ Android (Native performance)
- ✅ iOS (Native performance)
- ✅ Web (Cross-platform access)
- ✅ Windows (Desktop experience)
- ✅ macOS (Desktop experience)
- ✅ Linux (Desktop experience)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Development environment (Android Studio/VS Code)

### Installation & Run
```bash
# Get dependencies
flutter pub get

# Run on preferred platform
flutter run                    # Auto-detect platform
flutter run -d windows         # Windows desktop
flutter run -d chrome          # Web browser
flutter run -d android         # Android device/emulator
```

## 🎯 Usage Examples

### Family Game Night
1. Set language to family preference
2. Create teams with family member names
3. Configure 3-5 rounds for longer play
4. Enable skips for younger players

### Educational Setting
1. Use appropriate language for students
2. Disable skips for challenge
3. Short rounds (30-45 seconds)
4. Multiple teams for competition

### Casual Friends
1. Mixed language cards if multilingual group
2. Enable maximum skips for fun
3. Longer rounds for relaxed play
4. Custom team names for humor

## 🔮 Future Enhancements

- [ ] **Sound Effects**: Audio feedback for actions
- [ ] **Card Collections**: Themed card packs
- [ ] **Statistics**: Game history and performance tracking
- [ ] **Custom Cards**: User-created word cards
- [ ] **Network Play**: Remote team participation
- [ ] **More Languages**: Additional Kurdish dialects

## 🤝 Contributing

We welcome contributions for:
- New word cards in any supported language
- Additional Kurdish dialect support
- UI/UX improvements
- Bug fixes and optimizations
- Translation improvements

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🏆 Credits

- **Languages**: Kurmanci, Sorani, Turkish communities
- **Development**: GitHub Copilot & Flutter team
- **Design**: Material Design principles
- **Cultural Consultant**: Kurdish language experts

---

**بە خۆشییەوە یاری بکەن! (Kurmanci)**  
**Bi kêfa xwe lîstik bikin! (Sorani)**  
**Oyunun tadını çıkarın! (Turkish)**

---

*Made with ❤️ for the Kurdish community and language preservation*
