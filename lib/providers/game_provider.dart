import 'package:flutter/material.dart';
import 'package:legend_of_mushroom_bot/database/database_helper.dart';
import 'package:legend_of_mushroom_bot/models/models.dart';

class GameProvider extends ChangeNotifier {
  final db = DatabaseHelper();
  
  // Estado do jogo
  int currentPhase = 1;
  int playerLevel = 1;
  List<Pet> playerPets = [];
  List<Heritage> playerHeritages = [];
  List<Skill> playerSkills = [];
  
  // Cache
  Map<int, GamePhase> phasesCache = {};
  List<Build> buildsCache = [];
  List<Pet> petsCache = [];
  List<Heritage> heritagesCache = [];
  List<Skill> skillsCache = [];
  
  bool isLoading = false;
  String? error;

  // ============ INICIALIZAÇÃO ============
  
  Future<void> initializeGame() async {
    isLoading = true;
    notifyListeners();
    
    try {
      // Carregar progresso do usuário
      final progress = await db.getUserProgress();
      if (progress != null) {
        currentPhase = progress['currentPhase'] as int;
        playerLevel = progress['currentLevel'] as int;
      }
      
      // Pré-carregar dados em cache
      await _loadGameData();
      
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadGameData() async {
    try {
      petsCache = await db.getAllPets();
      heritagesCache = await db.getAllHeritages();
      skillsCache = await db.getAllSkills();
      buildsCache = await db.getAllBuilds();
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  // ============ FASES ============
  
  Future<GamePhase?> getPhaseData(int phaseNumber) async {
    // Verificar cache primeiro
    if (phasesCache.containsKey(phaseNumber)) {
      return phasesCache[phaseNumber];
    }
    
    try {
      final phase = await db.getPhaseByNumber(phaseNumber);
      if (phase != null) {
        phasesCache[phaseNumber] = phase;
      }
      return phase;
    } catch (e) {
      error = 'Erro ao carregar fase: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> updateCurrentPhase(int phaseNumber) async {
    currentPhase = phaseNumber;
    await _saveProgress();
    notifyListeners();
  }

  // ============ PETS DO JOGADOR ============
  
  Future<void> addPetToTeam(String petId) async {
    final pet = await db.getPetById(petId);
    if (pet != null) {
      playerPets.add(pet);
      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> removePetFromTeam(String petId) async {
    playerPets.removeWhere((p) => p.id == petId);
    await _saveProgress();
    notifyListeners();
  }

  void clearPlayerPets() {
    playerPets.clear();
    notifyListeners();
  }

  // ============ HERANÇAS DO JOGADOR ============
  
  Future<void> addHeritageToTeam(String heritageId) async {
    final heritage = await db.getHeritageById(heritageId);
    if (heritage != null) {
      playerHeritages.add(heritage);
      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> removeHeritageFromTeam(String heritageId) async {
    playerHeritages.removeWhere((h) => h.id == heritageId);
    await _saveProgress();
    notifyListeners();
  }

  void clearPlayerHeritages() {
    playerHeritages.clear();
    notifyListeners();
  }

  // ============ SKILLS DO JOGADOR ============
  
  Future<void> addSkillToTeam(String skillId) async {
    final skill = await db.getSkillById(skillId);
    if (skill != null && playerSkills.length < 4) {
      playerSkills.add(skill);
      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> removeSkillFromTeam(String skillId) async {
    playerSkills.removeWhere((s) => s.id == skillId);
    await _saveProgress();
    notifyListeners();
  }

  void clearPlayerSkills() {
    playerSkills.clear();
    notifyListeners();
  }

  // ============ BUILDS ============
  
  Future<void> applyBuild(String buildId) async {
    try {
      final build = await db.getBuildById(buildId);
      if (build != null) {
        clearPlayerPets();
        clearPlayerHeritages();
        clearPlayerSkills();
        
        // Aplicar build
        for (final petId in build.petIds) {
          await addPetToTeam(petId);
        }
        for (final heritageId in build.heritageIds) {
          await addHeritageToTeam(heritageId);
        }
        for (final skillId in build.skillIds) {
          await addSkillToTeam(skillId);
        }
        
        notifyListeners();
      }
    } catch (e) {
      error = 'Erro ao aplicar build: $e';
      notifyListeners();
    }
  }

  Future<List<Build>> getRecommendedBuilds(int phaseNumber) async {
    return await db.getBuildsByPhase(phaseNumber);
  }

  Future<List<Build>> getBuildsForLevel(int level) async {
    return await db.getBuildsByMinLevel(level);
  }

  // ============ NÍVEL DO JOGADOR ============
  
  Future<void> updatePlayerLevel(int newLevel) async {
    playerLevel = newLevel;
    await _saveProgress();
    notifyListeners();
  }

  // ============ ESTATÍSTICAS ============
  
  int calculateTotalAttack() {
    int total = playerPets.fold(0, (sum, pet) => sum + pet.attack);
    total += playerHeritages.fold(0, (sum, h) => sum + (h.bonus ~/ 100 * (h.type == 'ATK' ? 1 : 0)));
    return total;
  }

  int calculateTotalDefense() {
    int total = playerPets.fold(0, (sum, pet) => sum + pet.defense);
    total += playerHeritages.fold(0, (sum, h) => sum + (h.bonus ~/ 100 * (h.type == 'DEF' ? 1 : 0)));
    return total;
  }

  int calculateTotalSpeed() {
    int total = playerPets.fold(0, (sum, pet) => sum + pet.speed);
    total += playerHeritages.fold(0, (sum, h) => sum + (h.bonus ~/ 100 * (h.type == 'SPD' ? 1 : 0)));
    return total;
  }

  double calculateEfficiency() {
    if (playerPets.isEmpty) return 0;
    
    final avgAttack = calculateTotalAttack() / playerPets.length;
    final avgDefense = calculateTotalDefense() / playerPets.length;
    final avgSpeed = calculateTotalSpeed() / playerPets.length;
    
    return ((avgAttack * 0.4) + (avgDefense * 0.3) + (avgSpeed * 0.3)) / 10;
  }

  // ============ ARMAZENAMENTO ============
  
  Future<void> _saveProgress() async {
    try {
      await db.updateUserProgress(
        currentPhase: currentPhase,
        currentLevel: playerLevel,
        petIds: playerPets.map((p) => p.id).toList(),
        heritageIds: playerHeritages.map((h) => h.id).toList(),
        skillIds: playerSkills.map((s) => s.id).toList(),
      );
    } catch (e) {
      error = 'Erro ao salvar progresso: $e';
      notifyListeners();
    }
  }

  Future<void> loadProgress() async {
    try {
      await initializeGame();
    } catch (e) {
      error = 'Erro ao carregar progresso: $e';
      notifyListeners();
    }
  }

  // ============ BUSCA ============
  
  List<Pet> searchPets(String query) {
    return petsCache
        .where((pet) => pet.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Build> searchBuilds(String query) {
    return buildsCache
        .where((build) => build.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Build> filterBuildsByType(String type) {
    return buildsCache.where((build) => build.type == type).toList();
  }

  List<Build> filterBuildsByMinLevel(int level) {
    return buildsCache.where((build) => build.minLevel <= level).toList();
  }
}
