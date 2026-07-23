import 'package:json_serializable/json_serializable.dart';

part 'models.g.dart';

// ============ PLAYER & STATS ============

@JsonSerializable()
class PlayerStats {
  final int level;
  final int exp;
  final int maxExp;
  final int hp;
  final int maxHp;
  final int attack;
  final int defense;
  final int speed;
  final int luck;

  PlayerStats({
    required this.level,
    required this.exp,
    required this.maxExp,
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.luck,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerStatsToJson(this);

  int get totalPower => attack + defense + speed + luck;
}

// ============ PETS ============

@JsonSerializable()
class Pet {
  final String id;
  final String name;
  final String rarity; // Common, Rare, Epic, Legendary
  final int level;
  final int attack;
  final int defense;
  final int speed;
  final List<String> skills;
  final String element; // Fire, Water, Grass, Electric, etc
  final String synergy; // Sinergia com outros pets

  Pet({
    required this.id,
    required this.name,
    required this.rarity,
    required this.level,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.skills,
    required this.element,
    required this.synergy,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
  Map<String, dynamic> toJson() => _$PetToJson(this);

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] as String,
      name: map['name'] as String,
      rarity: map['rarity'] as String,
      level: map['level'] as int,
      attack: map['attack'] as int,
      defense: map['defense'] as int,
      speed: map['speed'] as int,
      skills: (map['skills'] as String).split(','),
      element: map['element'] as String,
      synergy: map['synergy'] as String,
    );
  }

  int get totalStats => attack + defense + speed;
}

// ============ HERANÇAS (INHERITANCES) ============

@JsonSerializable()
class Heritage {
  final String id;
  final String name;
  final String description;
  final String type; // ATK, DEF, SPD, HP, MIXED
  final int level;
  final int bonus; // Percentual de bonus
  final String rarity; // Comum, Raro, Épico, Lendário
  final List<String> compatibility; // IDs de pets compatíveis

  Heritage({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.level,
    required this.bonus,
    required this.rarity,
    required this.compatibility,
  });

  factory Heritage.fromJson(Map<String, dynamic> json) =>
      _$HeritageFromJson(json);
  Map<String, dynamic> toJson() => _$HeritageToJson(this);

  factory Heritage.fromMap(Map<String, dynamic> map) {
    return Heritage(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      level: map['level'] as int,
      bonus: map['bonus'] as int,
      rarity: map['rarity'] as String,
      compatibility: (map['compatibility'] as String).split(','),
    );
  }
}

// ============ SKILLS & ABILITIES ============

@JsonSerializable()
class Skill {
  final String id;
  final String name;
  final String description;
  final String type; // ATK, DEF, HEAL, BUFF, DEBUFF
  final int cooldown;
  final int manaCost;
  final int damage;
  final int level;
  final String element;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.cooldown,
    required this.manaCost,
    required this.damage,
    required this.level,
    required this.element,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);
  Map<String, dynamic> toJson() => _$SkillToJson(this);

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      cooldown: map['cooldown'] as int,
      manaCost: map['manaCost'] as int,
      damage: map['damage'] as int,
      level: map['level'] as int,
      element: map['element'] as String,
    );
  }
}

// ============ FASES ============

@JsonSerializable()
class GamePhase {
  final int phaseNumber;
  final String name;
  final String description;
  final int recommendedLevel;
  final int difficulty; // 1-10
  final List<Enemy> enemies;
  final int rewards;
  final String strategy;

  GamePhase({
    required this.phaseNumber,
    required this.name,
    required this.description,
    required this.recommendedLevel,
    required this.difficulty,
    required this.enemies,
    required this.rewards,
    required this.strategy,
  });

  factory GamePhase.fromJson(Map<String, dynamic> json) =>
      _$GamePhaseFromJson(json);
  Map<String, dynamic> toJson() => _$GamePhaseToJson(this);

  factory GamePhase.fromMap(Map<String, dynamic> map) {
    return GamePhase(
      phaseNumber: map['phaseNumber'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      recommendedLevel: map['recommendedLevel'] as int,
      difficulty: map['difficulty'] as int,
      enemies: _decodeEnemies(map['enemies'] as String),
      rewards: map['rewards'] as int,
      strategy: map['strategy'] as String,
    );
  }

  static List<Enemy> _decodeEnemies(String encoded) {
    // Placeholder - seria implementado com serialização JSON completa
    return [];
  }
}

// ============ INIMIGOS ============

@JsonSerializable()
class Enemy {
  final String id;
  final String name;
  final int level;
  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final String element;
  final List<String> skills;
  final String weakness; // Elemento fraco
  final String strength; // Elemento forte

  Enemy({
    required this.id,
    required this.name,
    required this.level,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.element,
    required this.skills,
    required this.weakness,
    required this.strength,
  });

  factory Enemy.fromJson(Map<String, dynamic> json) => _$EnemyFromJson(json);
  Map<String, dynamic> toJson() => _$EnemyToJson(this);

  int get totalStats => attack + defense + speed;
}

// ============ BUILD ============

@JsonSerializable()
class Build {
  final String id;
  final String name;
  final String description;
  final String type; // PvE, PvP, Support, Damage
  final List<String> petIds;
  final List<String> heritageIds;
  final List<String> skillIds;
  final int minLevel;
  final double efficiency; // 0-100
  final List<int> compatiblePhases;
  final String strategy;

  Build({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.petIds,
    required this.heritageIds,
    required this.skillIds,
    required this.minLevel,
    required this.efficiency,
    required this.compatiblePhases,
    required this.strategy,
  });

  factory Build.fromJson(Map<String, dynamic> json) => _$BuildFromJson(json);
  Map<String, dynamic> toJson() => _$BuildToJson(this);

  factory Build.fromMap(Map<String, dynamic> map) {
    return Build(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      petIds: (map['petIds'] as String).split(',').where((id) => id.isNotEmpty).toList(),
      heritageIds: (map['heritageIds'] as String).split(',').where((id) => id.isNotEmpty).toList(),
      skillIds: (map['skillIds'] as String).split(',').where((id) => id.isNotEmpty).toList(),
      minLevel: map['minLevel'] as int,
      efficiency: (map['efficiency'] as num).toDouble(),
      compatiblePhases: (map['compatiblePhases'] as String)
          .split(',')
          .where((p) => p.isNotEmpty)
          .map(int.parse)
          .toList(),
      strategy: map['strategy'] as String,
    );
  }
}

// ============ RECOMENDAÇÃO ============

@JsonSerializable()
class Recommendation {
  final String title;
  final String description;
  final String priority; // HIGH, MEDIUM, LOW
  final String action;
  final int expectedDifficultyReduction;
  final Build suggestedBuild;

  Recommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.action,
    required this.expectedDifficultyReduction,
    required this.suggestedBuild,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationToJson(this);
}

// ============ PVP OPPONENT ============

@JsonSerializable()
class PvPOpponent {
  final String id;
  final String name;
  final int level;
  final int wins;
  final int losses;
  final List<String> petIds;
  final List<String> heritageIds;
  final String mainElement;

  PvPOpponent({
    required this.id,
    required this.name,
    required this.level,
    required this.wins,
    required this.losses,
    required this.petIds,
    required this.heritageIds,
    required this.mainElement,
  });

  factory PvPOpponent.fromJson(Map<String, dynamic> json) =>
      _$PvPOpponentFromJson(json);
  Map<String, dynamic> toJson() => _$PvPOpponentToJson(this);
}
