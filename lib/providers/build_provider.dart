import 'package:flutter/foundation.dart';
import 'package:legend_of_mushroom_bot/database/database_helper.dart';
import 'package:legend_of_mushroom_bot/models/models.dart';

class BuildProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Build> _allBuilds = [];
  List<Build> _filteredBuilds = [];
  Build? _selectedBuild;
  bool _isLoading = false;

  List<Build> get allBuilds => _allBuilds;
  List<Build> get filteredBuilds => _filteredBuilds;
  Build? get selectedBuild => _selectedBuild;
  bool get isLoading => _isLoading;

  Future<void> loadBuilds() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allBuilds = await _databaseHelper.getAllBuilds();
      _filteredBuilds = _allBuilds;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByType(String type) {
    if (type == 'all') {
      _filteredBuilds = _allBuilds;
    } else {
      _filteredBuilds = _allBuilds.where((build) => build.type == type).toList();
    }
    notifyListeners();
  }

  void filterByLevel(int playerLevel) {
    _filteredBuilds = _allBuilds.where((build) => build.minLevel <= playerLevel).toList();
    notifyListeners();
  }

  void selectBuild(Build build) {
    _selectedBuild = build;
    notifyListeners();
  }

  void clearSelection() {
    _selectedBuild = null;
    notifyListeners();
  }
}
