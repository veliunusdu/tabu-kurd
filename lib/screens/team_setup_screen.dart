import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/team.dart';
import '../services/localization_service.dart';
import 'game_flow_screen.dart';

class TeamSetupScreen extends StatefulWidget {
  final GameSettings settings;

  const TeamSetupScreen({super.key, required this.settings});

  @override
  State<TeamSetupScreen> createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends State<TeamSetupScreen> {
  int _numberOfTeams = 2;
  List<Team> _teams = [];
  final List<TextEditingController> _teamNameControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeTeams();
  }

  void _initializeTeams() {
    _teams.clear();
    _teamNameControllers.clear();
    
    for (int i = 0; i < _numberOfTeams; i++) {
      final controller = TextEditingController();
      controller.text = '${AppLocalizations.get('team', widget.settings.language)} ${i + 1}';
      _teamNameControllers.add(controller);
      _teams.add(Team(name: controller.text));
    }
    setState(() {});
  }

  void _updateTeamNames() {
    for (int i = 0; i < _teams.length; i++) {
      _teams[i] = Team(name: _teamNameControllers[i].text.trim().isEmpty 
          ? '${AppLocalizations.get('team', widget.settings.language)} ${i + 1}'
          : _teamNameControllers[i].text.trim());
    }
  }

  @override
  void dispose() {
    for (var controller in _teamNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get('team_setup', widget.settings.language)),
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Number of teams selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.get('number_of_teams', widget.settings.language),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _numberOfTeams,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [2, 3, 4, 5, 6].map((number) {
                        return DropdownMenuItem(
                          value: number,
                          child: Text('$number'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _numberOfTeams = value;
                            _initializeTeams();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Players per team info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: Color(0xFF228B22)),
                    const SizedBox(width: 12),
                    Text(
                      '${AppLocalizations.get('players_per_team', widget.settings.language)}: ${widget.settings.playersPerTeam}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Team name inputs
            SizedBox(
              height: 300, // Fixed height for team inputs
              child: ListView.builder(
                itemCount: _numberOfTeams,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppLocalizations.get('team', widget.settings.language)} ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _teamNameControllers[index],
                            decoration: InputDecoration(
                              labelText: AppLocalizations.get('team_name', widget.settings.language),
                              hintText: AppLocalizations.get('enter_team_name', widget.settings.language),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.group),
                            ),
                            onChanged: (value) {
                              _teams[index] = _teams[index].copyWith(name: value);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Game settings summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      '${AppLocalizations.get('number_of_rounds', widget.settings.language)}: ${widget.settings.numberOfRounds}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${AppLocalizations.get('game_duration', widget.settings.language)}: ${widget.settings.timePerRound} ${AppLocalizations.get('seconds', widget.settings.language)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${AppLocalizations.get('skips_allowed', widget.settings.language)}: ${widget.settings.skipsAllowed ? AppLocalizations.get('enabled', widget.settings.language) : AppLocalizations.get('disabled', widget.settings.language)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (widget.settings.skipsAllowed)
                      Text(
                        '${AppLocalizations.get('max_skips_per_round', widget.settings.language)}: ${widget.settings.maxSkipsPerRound}',
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Start game button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppLocalizations.get('start', widget.settings.language),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  void _startGame() {
    // Validate team names
    for (int i = 0; i < _teams.length; i++) {
      if (_teamNameControllers[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.get('enter_team_name', widget.settings.language)} ${i + 1}',
            ),
          ),
        );
        return;
      }
      _teams[i] = _teams[i].copyWith(name: _teamNameControllers[i].text.trim());
    }

    // Navigate to game flow screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameFlowScreen(
          settings: widget.settings,
          teams: _teams,
        ),
      ),
    );
  }
}
