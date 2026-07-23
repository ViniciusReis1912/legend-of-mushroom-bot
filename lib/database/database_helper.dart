import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:legend_of_mushroom_bot/models/models.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'legend_of_mushroom.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Pets table
    await db.execute('''
      CREATE TABLE pets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rarity TEXT NOT NULL,
        level INTEGER NOT NULL,
        attack INTEGER NOT NULL,
        defense INTEGER NOT NULL,
        speed INTEGER NOT NULL,
        skills TEXT NOT NULL,
        element TEXT NOT NULL,
        synergy TEXT NOT NULL,
        data TEXT NOT NULL
      )
    ''');

    // Heritages table
    await db.execute('''
      CREATE TABLE heritages (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        level INTEGER NOT NULL,
        bonus INTEGER NOT NULL,
        rarity TEXT NOT NULL,
        compatibility TEXT NOT NULL,
        data TEXT NOT NULL
      )
    ''');

    // Skills table
    await db.execute('''
      CREATE TABLE skills (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        cooldown INTEGER NOT NULL,
        manaCost INTEGER NOT NULL,
        damage INTEGER NOT NULL,
        level INTEGER NOT NULL,
        element TEXT NOT NULL,
        data TEXT NOT NULL
      )
    ''');

    // Phases table
    await db.execute('''
      CREATE TABLE phases (
        phaseNumber INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        recommendedLevel INTEGER NOT NULL,
        difficulty INTEGER NOT NULL,
        enemies TEXT NOT NULL,
        rewards INTEGER NOT NULL,
        strategy TEXT NOT NULL,
        data TEXT NOT NULL
      )
    ''');

    // Builds table
    await db.execute('''
      CREATE TABLE builds (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        petIds TEXT NOT NULL,
        heritageIds TEXT NOT NULL,
        skillIds TEXT NOT NULL,
        minLevel INTEGER NOT NULL,
        efficiency REAL NOT NULL,
        compatiblePhases TEXT NOT NULL,
        strategy TEXT NOT NULL,
        data TEXT NOT NULL
      )
    ''');

    // User Progress
    await db.execute('''
      CREATE TABLE user_progress (
        id TEXT PRIMARY KEY,
        currentPhase INTEGER NOT NULL,
        currentLevel INTEGER NOT NULL,
        petIds TEXT NOT NULL,
        heritageIds TEXT NOT NULL,
        skillIds TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    // Favorites
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        entityId TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  // ============ PET OPERATIONS ============

  Future<void> insertPet(Pet pet) async {
    final db = await database;
    await db.insert(
      'pets',
      {
        'id': pet.id,
        'name': pet.name,
        'rarity': pet.rarity,
        'level': pet.level,
        'attack': pet.attack,
        'defense': pet.defense,
        'speed': pet.speed,
        'skills': jsonEncode(pet.skills),
        'element': pet.element,
        'synergy': pet.synergy,
        'data': jsonEncode(pet.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Pet>> getAllPets() async {
    final db = await database;
    final maps = await db.query('pets');
    return [
      for (final map in maps) Pet.fromJson(jsonDecode(map['data'] as String))
    ];
  }

  Future<Pet?> getPetById(String id) async {
    final db = await database;
    final maps = await db.query('pets', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Pet.fromJson(jsonDecode(maps.first['data'] as String));
  }

  Future<List<Pet>> getPetsByElement(String element) async {
    final db = await database;
    final maps = await db.query('pets', where: 'element = ?', whereArgs: [element]);
    return [
      for (final map in maps) Pet.fromJson(jsonDecode(map['data'] as String))
    ];
  }

  // ============ HERITAGE OPERATIONS ============

  Future<void> insertHeritage(Heritage heritage) async {
    final db = await database;
    await db.insert(
      'heritages',
      {
        'id': heritage.id,
        'name': heritage.name,
        'description': heritage.description,
        'type': heritage.type,
        'level': heritage.level,
        'bonus': heritage.bonus,
        'rarity': heritage.rarity,
        'compatibility': jsonEncode(heritage.compatibility),
        'data': jsonEncode(heritage.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Heritage>> getAllHeritages() async {
    final db = await database;
    final maps = await db.query('heritages');
    return [
      for (final map in maps)
        Heritage.fromJson(jsonDecode(map['data'] as String))
    ];
  }

  Future<Heritage?> getHeritageById(String id) async {
    final db = await database;
    final maps =
        await db.query('heritages', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Heritage.fromJson(jsonDecode(maps.first['data'] as String));
  }

  // ============ SKILL OPERATIONS ============

  Future<void> insertSkill(Skill skill) async {
    final db = await database;
    await db.insert(
      'skills',
      {
        'id': skill.id,
        'name': skill.name,
        'description': skill.description,
        'type': skill.type,
        'cooldown': skill.cooldown,
        'manaCost': skill.manaCost,
        'damage': skill.damage,
        'level': skill.level,
        'element': skill.element,
        'data': jsonEncode(skill.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Skill>> getAllSkills() async {
    final db = await database;
    final maps = await db.query('skills');
    return [
      for (final map in maps) Skill.fromJson(jsonDecode(map['data'] as String))
    ];
  }

  Future<Skill?> getSkillById(String id) async {
    final db = await database;
    final maps = await db.query('skills', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Skill.fromJson(jsonDecode(maps.first['data'] as String));
  }

  // ============ PHASE OPERATIONS ============

  Future<void> insertPhase(GamePhase phase) async {
    final db = await database;
    await db.insert(
      'phases',
      {
        'phaseNumber': phase.phaseNumber,
        'name': phase.name,
        'description': phase.description,
        'recommendedLevel': phase.recommendedLevel,
        'difficulty': phase.difficulty,
        'enemies': jsonEncode(phase.enemies.map((e) => e.toJson()).toList()),
        'rewards': phase.rewards,
        'strategy': phase.strategy,
        'data': jsonEncode(phase.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GamePhase>> getAllPhases() async {
    final db = await database;
    final maps =
        await db.query('phases', orderBy: 'phaseNumber ASC');
    return [
      for (final map in maps)
        GamePhase.fromJson(jsonDecode(map['data'] as String))
    ];
  }

  Future<GamePhase?> getPhaseByNumber(int number) async {
    final db = await database;
    final maps = await db.query('phases',
        where: 'phaseNumber = ?', whereArgs: [number]);
    if (maps.isEmpty) return null;
    return GamePhase.fromJson(jsonDecode(maps.first['data'] as String));
  }

  // ============ BUILD OPERATIONS ============

  Future<void> insertBuild(Build build) async {
    final db = await database;
    await db.insert(
      'builds',
      {
        'id': build.id,
        'name': build.name,
        'description': build.description,
        'type': build.type,
        'petIds': jsonEncode(build.petIds),
        'heritageIds': jsonEncode(build.heritageIds),
        'skillIds': jsonEncode(build.skillIds),
        'minLevel': build.minLevel,
        'efficiency': build.efficiency,
        'compatiblePhases': jsonEncode(build.compatiblePhases),
        'strategy': build.strategy,
        'data': jsonEncode(build.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Build>> getAllBuilds() async {
    final db = await database;
    final maps = await db.query('builds');
    return [
      for (final map in maps) Build.fromJson(jsonDecode(map['data'] as String))
    ];
  }

  Future<List<Build>> getBuildsByType(String type) async {
    final db = await database;
    final maps = await db.query('builds', where: 'type = ?', whereArgs: [type]);
    return [
      for (final map in maps) Build.fromJson(jsonDecode(map['data'] as String))
    ];
  }

  Future<Build?> getBuildById(String id) async {
    final db = await database;
    final maps = await db.query('builds', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Build.fromJson(jsonDecode(maps.first['data'] as String));
  }

  Future<List<Build>> getBuildsByPhase(int phaseNumber) async {
    final db = await database;
    final allBuilds = await getAllBuilds();
    return allBuilds
        .where((build) => build.compatiblePhases.contains(phaseNumber))
        .toList();
  }

  Future<List<Build>> getBuildsByMinLevel(int level) async {
    final db = await database;
    final maps = await db.query('builds',
        where: 'minLevel <= ?',
        whereArgs: [level],
        orderBy: 'efficiency DESC');
    return [
      for (final map in maps) Build.fromJson(jsonDecode(map['data'] as String))
    ];
  }

  // ============ USER PROGRESS ============

  Future<void> updateUserProgress({
    required int currentPhase,
    required int currentLevel,
    required List<String> petIds,
    required List<String> heritageIds,
    required List<String> skillIds,
  }) async {
    final db = await database;
    await db.insert(
      'user_progress',
      {
        'id': 'main_progress',
        'currentPhase': currentPhase,
        'currentLevel': currentLevel,
        'petIds': jsonEncode(petIds),
        'heritageIds': jsonEncode(heritageIds),
        'skillIds': jsonEncode(skillIds),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserProgress() async {
    final db = await database;
    final maps =
        await db.query('user_progress', where: 'id = ?', whereArgs: ['main_progress']);
    if (maps.isEmpty) return null;
    return maps.first;
  }

  // ============ FAVORITES ============

  Future<void> addFavorite(String type, String entityId) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'id': '${type}_$entityId',
        'type': type,
        'entityId': entityId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(String type, String entityId) async {
    final db = await database;
    await db.delete('favorites',
        where: 'type = ? AND entityId = ?', whereArgs: [type, entityId]);
  }

  Future<List<String>> getFavoritesByType(String type) async {
    final db = await database;
    final maps =
        await db.query('favorites', where: 'type = ?', whereArgs: [type]);
    return [for (final map in maps) map['entityId'] as String];
  }
}
