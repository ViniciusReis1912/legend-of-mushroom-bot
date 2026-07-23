import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:legend_of_mushroom_bot/models/models.dart';
import 'package:legend_of_mushroom_bot/data/game_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'legend_of_mushroom_bot.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
        synergy TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE heritages (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        level INTEGER NOT NULL,
        bonus INTEGER NOT NULL,
        rarity TEXT NOT NULL,
        compatibility TEXT NOT NULL
      )
    ''');

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
        element TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE phases (
        phaseNumber INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        recommendedLevel INTEGER NOT NULL,
        difficulty INTEGER NOT NULL,
        enemies TEXT NOT NULL,
        rewards INTEGER NOT NULL,
        strategy TEXT NOT NULL
      )
    ''');

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
        strategy TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY,
        currentPhase INTEGER NOT NULL,
        currentLevel INTEGER NOT NULL,
        petIds TEXT NOT NULL,
        heritageIds TEXT NOT NULL,
        skillIds TEXT NOT NULL,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        itemId TEXT NOT NULL,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(type, itemId)
      )
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    for (final pet in GameData.defaultPets) {
      await db.insert('pets', {
        'id': pet.id,
        'name': pet.name,
        'rarity': pet.rarity,
        'level': pet.level,
        'attack': pet.attack,
        'defense': pet.defense,
        'speed': pet.speed,
        'skills': pet.skills.join(','),
        'element': pet.element,
        'synergy': pet.synergy,
      });
    }

    for (final heritage in GameData.defaultHeritages) {
      await db.insert('heritages', {
        'id': heritage.id,
        'name': heritage.name,
        'description': heritage.description,
        'type': heritage.type,
        'level': heritage.level,
        'bonus': heritage.bonus,
        'rarity': heritage.rarity,
        'compatibility': heritage.compatibility.join(','),
      });
    }

    for (final skill in GameData.defaultSkills) {
      await db.insert('skills', {
        'id': skill.id,
        'name': skill.name,
        'description': skill.description,
        'type': skill.type,
        'cooldown': skill.cooldown,
        'manaCost': skill.manaCost,
        'damage': skill.damage,
        'level': skill.level,
        'element': skill.element,
      });
    }

    for (final phase in GameData.defaultPhases) {
      await db.insert('phases', {
        'phaseNumber': phase.phaseNumber,
        'name': phase.name,
        'description': phase.description,
        'recommendedLevel': phase.recommendedLevel,
        'difficulty': phase.difficulty,
        'enemies': _encodeEnemies(phase.enemies),
        'rewards': phase.rewards,
        'strategy': phase.strategy,
      });
    }

    for (final build in GameData.defaultBuilds) {
      await db.insert('builds', {
        'id': build.id,
        'name': build.name,
        'description': build.description,
        'type': build.type,
        'petIds': build.petIds.join(','),
        'heritageIds': build.heritageIds.join(','),
        'skillIds': build.skillIds.join(','),
        'minLevel': build.minLevel,
        'efficiency': build.efficiency,
        'compatiblePhases': build.compatiblePhases.join(','),
        'strategy': build.strategy,
      });
    }

    await db.insert('user_progress', {
      'currentPhase': 1,
      'currentLevel': 1,
      'petIds': '',
      'heritageIds': '',
      'skillIds': '',
    });
  }

  Future<List<Pet>> getAllPets() async {
    final db = await database;
    final result = await db.query('pets');
    return result.map((map) => Pet.fromMap(map)).toList();
  }

  Future<Pet?> getPetById(String id) async {
    final db = await database;
    final result = await db.query('pets', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Pet.fromMap(result.first);
  }

  Future<List<Heritage>> getAllHeritages() async {
    final db = await database;
    final result = await db.query('heritages');
    return result.map((map) => Heritage.fromMap(map)).toList();
  }

  Future<Heritage?> getHeritageById(String id) async {
    final db = await database;
    final result = await db.query('heritages', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Heritage.fromMap(result.first);
  }

  Future<List<Skill>> getAllSkills() async {
    final db = await database;
    final result = await db.query('skills');
    return result.map((map) => Skill.fromMap(map)).toList();
  }

  Future<Skill?> getSkillById(String id) async {
    final db = await database;
    final result = await db.query('skills', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Skill.fromMap(result.first);
  }

  Future<GamePhase?> getPhaseByNumber(int phaseNumber) async {
    final db = await database;
    final result = await db.query('phases', where: 'phaseNumber = ?', whereArgs: [phaseNumber]);
    if (result.isEmpty) return null;
    return GamePhase.fromMap(result.first);
  }

  Future<List<GamePhase>> getAllPhases() async {
    final db = await database;
    final result = await db.query('phases');
    return result.map((map) => GamePhase.fromMap(map)).toList();
  }

  Future<List<Build>> getAllBuilds() async {
    final db = await database;
    final result = await db.query('builds');
    return result.map((map) => Build.fromMap(map)).toList();
  }

  Future<Build?> getBuildById(String id) async {
    final db = await database;
    final result = await db.query('builds', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Build.fromMap(result.first);
  }

  Future<List<Build>> getBuildsByType(String type) async {
    final db = await database;
    final result = await db.query('builds', where: 'type = ?', whereArgs: [type]);
    return result.map((map) => Build.fromMap(map)).toList();
  }

  Future<List<Build>> getBuildsByMinLevel(int minLevel) async {
    final db = await database;
    final result = await db.query(
      'builds',
      where: 'minLevel <= ?',
      whereArgs: [minLevel],
      orderBy: 'efficiency DESC',
    );
    return result.map((map) => Build.fromMap(map)).toList();
  }

  String _encodeEnemies(List<Enemy> enemies) {
    return enemies.map((e) => e.toJson().toString()).join('|');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
