import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../services/localization_service.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings? settings;
  
  const SettingsScreen({super.key, this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings ?? GameSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get('settings', _settings.language)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSettingsCard(
                    title: AppLocalizations.get('game_duration', _settings.language),
                    icon: Icons.timer,
                    child: Column(
                      children: [
                        Text(
                          '${AppLocalizations.get('time', _settings.language)}: ${_settings.timePerRound} ${AppLocalizations.get('seconds', _settings.language)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Slider(
                          value: _settings.timePerRound.toDouble(),
                          min: 30,
                          max: 120,
                          divisions: 9,
                          label: '${_settings.timePerRound}s',
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(
                                timePerRound: value.round(),
                              );
                            });
                          },
                        ),
                        Text(
                          '30 ${AppLocalizations.get('seconds', _settings.language)} - 120 ${AppLocalizations.get('seconds', _settings.language)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  _buildSettingsCard(
                    title: AppLocalizations.get('number_of_rounds', _settings.language),
                    icon: Icons.repeat,
                    child: Column(
                      children: [
                        Text(
                          '${AppLocalizations.get('number_of_rounds', _settings.language)}: ${_settings.numberOfRounds}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Slider(
                          value: _settings.numberOfRounds.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: '${_settings.numberOfRounds}',
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(
                                numberOfRounds: value.round(),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  _buildSettingsCard(
                    title: AppLocalizations.get('players_per_team', _settings.language),
                    icon: Icons.group,
                    child: Column(
                      children: [
                        Text(
                          '${AppLocalizations.get('players_per_team', _settings.language)}: ${_settings.playersPerTeam}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Slider(
                          value: _settings.playersPerTeam.toDouble(),
                          min: 2,
                          max: 8,
                          divisions: 6,
                          label: '${_settings.playersPerTeam}',
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(
                                playersPerTeam: value.round(),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  _buildSettingsCard(
                    title: AppLocalizations.get('target_score', _settings.language),
                    icon: Icons.flag,
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            _settings.useTargetScore 
                                ? AppLocalizations.get('enabled', _settings.language)
                                : AppLocalizations.get('disabled', _settings.language),
                          ),
                          subtitle: Text(
                            _settings.useTargetScore
                                ? AppLocalizations.get('target_reached', _settings.language)
                                : AppLocalizations.get('play_all_rounds', _settings.language),
                          ),
                          value: _settings.useTargetScore,
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(
                                useTargetScore: value,
                              );
                            });
                          },
                        ),
                        if (_settings.useTargetScore) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.get('target_score', _settings.language)}: ${_settings.targetScore} ${AppLocalizations.get('points', _settings.language)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Slider(
                            value: _settings.targetScore.toDouble(),
                            min: 10,
                            max: 50,
                            divisions: 8,
                            label: '${_settings.targetScore}',
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(
                                  targetScore: value.round(),
                                );
                              });
                            },
                          ),
                          Text(
                            '10 ${AppLocalizations.get('points', _settings.language)} - 50 ${AppLocalizations.get('points', _settings.language)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),

                  _buildSettingsCard(
                    title: AppLocalizations.get('skips_allowed', _settings.language),
                    icon: Icons.skip_next,
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            _settings.skipsAllowed 
                                ? AppLocalizations.get('enabled', _settings.language)
                                : AppLocalizations.get('disabled', _settings.language),
                          ),
                          value: _settings.skipsAllowed,
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(skipsAllowed: value);
                            });
                          },
                        ),
                        if (_settings.skipsAllowed) ...[
                          Text(
                            '${AppLocalizations.get('max_skips_per_round', _settings.language)}: ${_settings.maxSkipsPerRound}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Slider(
                            value: _settings.maxSkipsPerRound.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: '${_settings.maxSkipsPerRound}',
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(
                                  maxSkipsPerRound: value.round(),
                                );
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  _buildSettingsCard(
                    title: AppLocalizations.get('language', _settings.language),
                    icon: Icons.language,
                    child: DropdownButtonFormField<String>(
                      value: _settings.language,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'kurmanci',
                          child: Text(AppLocalizations.getLanguageDisplayName('kurmanci')),
                        ),
                        DropdownMenuItem(
                          value: 'sorani',
                          child: Text(AppLocalizations.getLanguageDisplayName('sorani')),
                        ),
                        DropdownMenuItem(
                          value: 'turkish',
                          child: Text(AppLocalizations.getLanguageDisplayName('turkish')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _settings = _settings.copyWith(language: value);
                          });
                        }
                      },
                    ),
                  ),

                  _buildSettingsCard(
                    title: AppLocalizations.get('work_offline', _settings.language),
                    icon: Icons.wifi_off,
                    child: SwitchListTile(
                      title: Text(
                        _settings.workOffline 
                            ? AppLocalizations.get('enabled', _settings.language)
                            : AppLocalizations.get('disabled', _settings.language),
                      ),
                      value: _settings.workOffline,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(workOffline: value);
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.get('about', _settings.language),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${AppLocalizations.get('app_title', _settings.language)}\n${AppLocalizations.get('version', _settings.language)}\n\n${AppLocalizations.get('family_game', _settings.language)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.get('made_with_love', _settings.language),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.get('created_by', _settings.language),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _settings = GameSettings(); // Reset to defaults
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.get('settings_reset', _settings.language)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.get('reset', _settings.language)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save settings (in a real app, you'd save to SharedPreferences)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.get('settings_saved', _settings.language)),
                        ),
                      );
                      Navigator.pop(context, _settings); // Return the settings
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF228B22),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.get('save', _settings.language)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF228B22)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
