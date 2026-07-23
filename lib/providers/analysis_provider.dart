import 'package:flutter/foundation.dart';
import 'package:legend_of_mushroom_bot/models/models.dart';

class AnalysisProvider extends ChangeNotifier {
  Recommendation? _currentRecommendation;
  List<Build> _suggestedCounterBuilds = [];
  bool _isAnalyzing = false;
  String? _error;

  Recommendation? get currentRecommendation => _currentRecommendation;
  List<Build> get suggestedCounterBuilds => _suggestedCounterBuilds;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;

  Future<void> analyzePhase({
    required int phaseNumber,
    required int playerLevel,
    required int playerAttack,
    required int playerDefense,
    required int playerSpeed,
    required List<Pet> playerPets,
    required List<Heritage> playerHeritages,
  }) async {
    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final difficulty = _calculateDifficulty(
        phaseNumber,
        playerLevel,
        playerAttack,
        playerDefense,
      );

      final recommendation = _generateRecommendation(
        phaseNumber: phaseNumber,
        difficulty: difficulty,
        playerLevel: playerLevel,
        playerPets: playerPets,
      );

      _currentRecommendation = recommendation;
    } catch (e) {
      _error = 'Erro ao analisar a fase: $e';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> analyzePvPOpponent({
    required PvPOpponent opponent,
    required int playerLevel,
    required List<Pet> playerPets,
  }) async {
    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _suggestedCounterBuilds = _generateCounterBuilds(
        opponent: opponent,
        playerLevel: playerLevel,
        playerPets: playerPets,
      );
    } catch (e) {
      _error = 'Erro ao analisar oponente: $e';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  int _calculateDifficulty(
    int phaseNumber,
    int playerLevel,
    int playerAttack,
    int playerDefense,
  ) {
    final baseDifficulty = phaseNumber * 2;
    final levelDiff = (playerLevel * 5) - baseDifficulty;
    final statDiff = ((playerAttack + playerDefense) ~/ 2) - (phaseNumber * 3);

    return (baseDifficulty - (levelDiff ~/ 5) - (statDiff ~/ 10)).clamp(1, 10);
  }

  Recommendation _generateRecommendation({
    required int phaseNumber,
    required int difficulty,
    required int playerLevel,
    required List<Pet> playerPets,
  }) {
    final isHighPriority = difficulty >= 7;
    final recommendedBuild = _selectBestBuild(phaseNumber, playerLevel);

    return Recommendation(
      title: isHighPriority ? 'Fase Muito Desafiadora' : 'Fase Viável',
      description:
          'Nível de dificuldade: ${difficulty.toStringAsFixed(1)}/10. '
          'Seus pets atuais: ${playerPets.length}/3. ',
      priority: isHighPriority ? 'HIGH' : 'MEDIUM',
      action: isHighPriority
          ? 'Aumente o level ou mude de build antes de enfrentar'
          : 'Você pode enfrentar esta fase com preparação adequada',
      expectedDifficultyReduction: (difficulty * 15).toInt().clamp(0, 80),
      suggestedBuild: recommendedBuild,
    );
  }

  Build _selectBestBuild(int phaseNumber, int playerLevel) {
    // Mock implementation
    return Build(
      id: 'best_build_${phaseNumber}_${playerLevel}',
      name: 'Build Otimizado Fase $phaseNumber',
      description: 'Build customizado para máximo desempenho',
      type: 'PvE',
      petIds: ['pet_fire_1', 'pet_water_1', 'pet_grass_1'],
      heritageIds: ['her_atk_1', 'her_def_1'],
      skillIds: ['skill_fire_1', 'skill_water_1', 'skill_heal_1'],
      minLevel: playerLevel - 5,
      efficiency: 82.5,
      compatiblePhases: [phaseNumber],
      strategy: 'Estratégia otimizada para esta fase específica',
    );
  }

  List<Build> _generateCounterBuilds({
    required PvPOpponent opponent,
    required int playerLevel,
    required List<Pet> playerPets,
  }) {
    final counterBuilds = <Build>[];

    // Mock counter builds baseado no elemento principal do oponente
    if (opponent.mainElement == 'Fire') {
      counterBuilds.add(Build(
        id: 'counter_water_fire',
        name: 'Counter Água vs Fogo',
        description: 'Build específico contra pets de fogo',
        type: 'PvP',
        petIds: ['pet_water_1', 'pet_water_2', 'pet_water_3'],
        heritageIds: ['her_def_1', 'her_spd_1'],
        skillIds: ['skill_water_1', 'skill_water_3', 'skill_heal_1'],
        minLevel: playerLevel - 3,
        efficiency: 85.0,
        compatiblePhases: [],
        strategy: 'Use água para explorar fraqueza de fogo',
      ));
    } else if (opponent.mainElement == 'Water') {
      counterBuilds.add(Build(
        id: 'counter_grass_water',
        name: 'Counter Grama vs Água',
        description: 'Build específico contra pets de água',
        type: 'PvP',
        petIds: ['pet_grass_1', 'pet_grass_2', 'pet_grass_3'],
        heritageIds: ['her_atk_1', 'her_spd_2'],
        skillIds: ['skill_grass_1', 'skill_grass_2', 'skill_buff_1'],
        minLevel: playerLevel - 3,
        efficiency: 84.0,
        compatiblePhases: [],
        strategy: 'Use grama para explorar fraqueza de água',
      ));
    } else if (opponent.mainElement == 'Electric') {
      counterBuilds.add(Build(
        id: 'counter_grass_electric',
        name: 'Counter Grama vs Elétrico',
        description: 'Build específico contra pets elétricos',
        type: 'PvP',
        petIds: ['pet_grass_1', 'pet_grass_2', 'pet_grass_3'],
        heritageIds: ['her_def_1', 'her_atk_1'],
        skillIds: ['skill_grass_1', 'skill_grass_3', 'skill_heal_1'],
        minLevel: playerLevel - 3,
        efficiency: 83.0,
        compatiblePhases: [],
        strategy: 'Use grama para neutralizar ataques elétricos',
      ));
    }

    return counterBuilds;
  }

  void clearRecommendation() {
    _currentRecommendation = null;
    _suggestedCounterBuilds = [];
    notifyListeners();
  }
}
