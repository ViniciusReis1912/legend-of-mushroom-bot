import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legend_of_mushroom_bot/providers/game_provider.dart';
import 'package:legend_of_mushroom_bot/screens/phase_analyzer_screen.dart';
import 'package:legend_of_mushroom_bot/screens/builds_screen.dart';
import 'package:legend_of_mushroom_bot/screens/pvp_screen.dart';
import 'package:legend_of_mushroom_bot/screens/team_builder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          PhaseAnalyzerScreen(),
          TeamBuilderScreen(),
          BuildsScreen(),
          PvPScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Fases',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Time',
          ),
          NavigationDestination(
            icon: Icon(Icons.build),
            label: 'Builds',
          ),
          NavigationDestination(
            icon: Icon(Icons.sword),
            label: 'PvP',
          ),
        ],
      ),
    );
  }
}
