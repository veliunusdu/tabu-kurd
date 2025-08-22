import 'package:flutter/services.dart';

class SoundService {
  static bool _soundEnabled = true;

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  static bool get isSoundEnabled => _soundEnabled;

  // Play sound using system sounds for cross-platform compatibility
  static Future<void> playCorrectSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail if sound can't be played
    }
  }

  static Future<void> playTabooSound() async {
    if (!_soundEnabled) return;
    try {
      // Use alert sound for taboo violations
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Silently fail if sound can't be played
    }
  }

  static Future<void> playSkipSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail if sound can't be played
    }
  }

  static Future<void> playTimeUpSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Silently fail if sound can't be played
    }
  }

  static Future<void> playGameOverSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail if sound can't be played
    }
  }

  static Future<void> playRoundEndSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail if sound can't be played
    }
  }
}
