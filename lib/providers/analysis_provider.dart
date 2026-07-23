import 'package:flutter/material.dart';
import 'package:legend_of_mushroom_bot/models/models.dart';
import 'package:legend_of_mushroom_bot/database/database_helper.dart';

class AnalysisProvider extends ChangeNotifier {
  final db = DatabaseHelper();

  Recommendation? currentRecommendation;
  List<Recommendation> allRecommendations = [];
  PvPOpponent? analyzedOpponent;
  List<Build> suggestedCounterBuilds = [];
  bool isAnalyzing = false;
  String? error;

  // ============ ANÁLISE DE FASE ============

  Future<Recommendation?> analyzePhase({
    required int phaseNumber,
    required int playerLevel,
    required int playerAttack,
    required int playerDefense,
    required int playerSpeed,
    required List<Pet> playerPets,
    required List<Heritage> playerHeritages,
  }) async {
    isAnalyzing = true;
    notifyListeners();

    try {
      final phase = await db.getPhaseByNumber(phaseNumber);
      if (phase == null) {
        error = 'Fase não encontrada';
        isAnalyzing = false;
        notifyListeners();
        return null;
      }

      // Calcular dificuldade relativa
      final difficultyGap = phase.difficulty - (playerLevel ~/ 10);
      final isPhaseDoable = playerLevel >= phase.recommendedLevel;

      if (!isPhaseDoable) {
        currentRecommendation = Recommendation(
          title: 'Nível insuficiente',
          description:
              'Você precisa de nível ${phase.recommendedLevel} para essa fase (você tem ${playerLevel})',
          priority: 'HIGH',
          action: 'Farm na fase anterior para subir de nível',
          expectedDifficultyReduction: 0,
          suggestedBuild: await _getSuggestedBuild(phaseNumber, playerLevel),
        );
      } else {
        // Analisar build recomendado
        final suggestedBuild =
            await _analyzePhaseEnemies(phase, playerPets, playerHeritages);
        final synergy = _calculateTeamSynergy(playerPets, playerHeritages);
        final effectiveness = _calculateEffectiveness(
          playerPets,
          phase.enemies,
          playerAttack,
          playerDefense,
        );

        currentRecommendation = Recommendation(
          title: 'Build Recomendado para ${phase.name}',
          description: suggestedBuild.strategy,
          priority: effectiveness < 50 ? 'HIGH' : 'MEDIUM',
          action: _generateAction(phase, effectiveness, synergy),
          expectedDifficultyReduction: (effectiveness * 0.8).toInt(),
          suggestedBuild: suggestedBuild,
        );
      }

      error = null;
    } catch (e) {
      error = 'Erro ao analisar fase: $e';
      currentRecommendation = null;
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }

    return currentRecommendation;
  }

  Future<Build> _analyzePhaseEnemies(
    GamePhase phase,
    List<Pet> playerPets,
    List<Heritage> playerHeritages,
  ) async {
    // Encontrar elemento fraco dos inimigos
    final enemyElements =
        phase.enemies.map((e) => e.element).toSet().toList();
    final recommendedElements = _getCounterElements(enemyElements);

    // Buscar pets com elementos recomendados
    final allPets = await db.getAllPets();
    final recommendedPets = allPets
        .where((p) => recommendedElements.contains(p.element))
        .toList()
      ..sort((a, b) => b.attack.compareTo(a.attack));

    // Criar build sugerido
    final build = Build(
      id: 'auto_${phase.phaseNumber}',
      name: 'Build para ${phase.name}',
      description:
          'Build otimizado contra ${enemyElements.join(", ")}',
      type: 'PvE',
      petIds: recommendedPets.take(3).map((p) => p.id).toList(),
      heritageIds: [],
      skillIds: [],
      minLevel: phase.recommendedLevel,
      efficiency: 75.0,
      compatiblePhases: [phase.phaseNumber],
      strategy: _generateStrategy(phase, recommendedPets),
    );

    return build;
  }

  List<String> _getCounterElements(List<String> enemyElements) {
    final elementChart = {
      'Fire': 'Water',
      'Water': 'Grass',
      'Grass': 'Electric',
      'Electric': 'Water',
      'Ice': 'Fire',
      'Rock': 'Water',
    };

    final counters = <String>{};
    for (final element in enemyElements) {
      final counter = elementChart[element];
      if (counter != null) counters.add(counter);
    }

    return counters.toList();
  }

  String _generateStrategy(GamePhase phase, List<Pet> recommendedPets) {
    final petNames = recommendedPets.take(3).map((p) => p.name).join(', ');
    return '''
Estratégia para ${phase.name}:

1. Use pets com elemento ${phase.enemies.first.weakness} para contra-atacar
2. Pets recomendados: $petNames
3. Foque em atacar ${phase.enemies.first.name} primeiro
4. Mantenha defesa alta contra ${phase.enemies.last.name}
5. Use skills especiais quando mana estiver cheia
''';
  }

  double _calculateTeamSynergy(
      List<Pet> pets, List<Heritage> heritages) {
    if (pets.isEmpty) return 0;

    // Calcular sinergia entre pets
    double synergy = 0;
    final elements = pets.map((p) => p.element).toSet();

    // Bônus por variedade de elementos
    synergy += elements.length * 10;

    // Bônus por heritages
    synergy += heritages.length * 5;

    return synergy.clamp(0, 100);
  }

  double _calculateEffectiveness(
    List<Pet> pets,
    List<Enemy> enemies,
    int playerAttack,
    int playerDefense,
  ) {
    if (pets.isEmpty || enemies.isEmpty) return 0;

    double avgPetAttack = pets.fold(0, (sum, p) => sum + p.attack) / pets.length;
    double avgEnemyDefense =
        enemies.fold(0, (sum, e) => sum + e.defense) / enemies.length;

    final effectiveness = ((avgPetAttack - avgEnemyDefense) / avgEnemyDefense) *
        100 +
        50;
    return effectiveness.clamp(0, 100);
  }

  String _generateAction(
      GamePhase phase, double effectiveness, double synergy) {
    if (effectiveness < 50) {
      return 'Suba de nível e melhore seus pets antes de tentar essa fase';
    } else if (synergy < 30) {
      return 'Melhore a sinergia do seu time ajustando heranças e skills';
    } else {
      return 'Seu time está pronto! Execute a estratégia recomendada';
    }
  }

  Future<Build> _getSuggestedBuild(int phaseNumber, int playerLevel) async {
    final builds = await db.getBuildsByMinLevel(playerLevel);
    if (builds.isNotEmpty) {
      return builds.first;
    }

    return Build(
      id: 'default',
      name: 'Build Padrão',
      description: 'Build padrão para começar',
      type: 'PvE',
      petIds: [],
      heritageIds: [],
      skillIds: [],
      minLevel: 1,
      efficiency: 50.0,
      compatiblePhases: [],
      strategy: 'Aumente seu nível primeiro',
    );
  }

  // ============ ANÁLISE PVP ============

  Future<List<Build>> analyzePvPOpponent({
    required PvPOpponent opponent,
    required int playerLevel,
    required List<Pet> playerPets,
  }) async {
    isAnalyzing = true;
    notifyListeners();

    try {
      analyzedOpponent = opponent;

      // Encontrar elementos principais do oponente
      final opponentPets = await Future.wait(
        opponent.petIds.map((id) => db.getPetById(id)),
      );

      final opponentElements =
          opponentPets.whereType<Pet>().map((p) => p.element).toSet().toList();

      // Buscar builds counter
      final allBuilds = await db.getAllBuilds();
      suggestedCounterBuilds = allBuilds
          .where((build) =>
              build.type == 'PvP' &&
              build.minLevel <= playerLevel &&
              _isCounterBuild(build, opponentElements, opponentPets.whereType<Pet>().toList()))
          .toList()
        ..sort((a, b) => b.efficiency.compareTo(a.efficiency));

      error = null;
    } catch (e) {
      error = 'Erro ao analisar oponente: $e';
      suggestedCounterBuilds = [];
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }

    return suggestedCounterBuilds;
  }

  bool _isCounterBuild(
      Build build, List<String> opponentElements, List<Pet> opponentPets) {
    // Simples verificação de contador de elemento
    return true; // Pode ser expandido com lógica mais complexa
  }

  // ============ COMPARAÇÃO DE BUILDS ============

  Map<String, dynamic> compareBuild(Build build1, Build build2) {
    return {
      'nameComparison': '${build1.name} vs ${build2.name}',
      'efficiencyDiff': build1.efficiency - build2.efficiency,
      'build1Better': build1.efficiency > build2.efficiency,
      'recommendation':
          build1.efficiency > build2.efficiency ? build1.name : build2.name,
    };
  }

  // ============ OTIMIZAÇÃO ============

  Future<Build> optimizeBuild({
    required List<Pet> selectedPets,
    required List<Heritage> selectedHeritages,
    required List<Skill> selectedSkills,
  }) async {
    double efficiency = _calculateBuildEfficiency(
      selectedPets,
      selectedHeritages,
      selectedSkills,
    );

    return Build(
      id: 'optimized_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Build Otimizado',
      description: 'Build otimizado para máxima eficiência',
      type: 'PvE',
      petIds: selectedPets.map((p) => p.id).toList(),
      heritageIds: selectedHeritages.map((h) => h.id).toList(),
      skillIds: selectedSkills.map((s) => s.id).toList(),
      minLevel: selectedPets.isEmpty ? 1 : selectedPets.first.level,
      efficiency: efficiency,
      compatiblePhases: [],
      strategy: 'Build customizado para máxima eficiência',
    );
  }

  double _calculateBuildEfficiency(
    List<Pet> pets,
    List<Heritage> heritages,
    List<Skill> skills,
  ) {
    double efficiency = 0;

    // Stats dos pets
    final totalAttack =
        pets.fold(0, (sum, p) => sum + p.attack).toDouble();
    final totalDefense =
        pets.fold(0, (sum, p) => sum + p.defense).toDouble();
    final totalSpeed =
        pets.fold(0, (sum, p) => sum + p.speed).toDouble();

    efficiency += (totalAttack / pets.length.clamp(1, double.infinity)) * 0.4;
    efficiency += (totalDefense / pets.length.clamp(1, double.infinity)) * 0.3;
    efficiency += (totalSpeed / pets.length.clamp(1, double.infinity)) * 0.3;

    // Bônus de heritages
    efficiency += heritages.length * 5;

    // Bônus de skills
    efficiency += skills.length * 3;

    return efficiency.clamp(0, 100);
  }

  // ============ FAVORITOS ============

  Future<void> addFavoriteBuild(String buildId) async {
    await db.addFavorite('build', buildId);
    notifyListeners();
  }

  Future<void> removeFavoriteBuild(String buildId) async {
    await db.removeFavorite('build', buildId);
    notifyListeners();
  }

  Future<List<String>> getFavoriteBuilds() async {
    return await db.getFavoritesByType('build');
  }
}
