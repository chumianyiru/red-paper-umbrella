import 'package:flutter/foundation.dart';
import 'item.dart';
import '../game/item_database.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum SanityLevel { normal, anxious, terrified, insane }

class Player with ChangeNotifier {
  String _name = "林小雨";
  int _health = 100;
  int _maxHealth = 100;
  int _sanity = 100;
  int _maxSanity = 100;
  List<Item> _inventory = [];
  int _currentChapter = 1;
  String _currentScene = "";
  List<String> _collectedItems = [];
  List<String> _solvedPuzzles = [];
  List<String> _visitedScenes = [];
  List<int> _completedChapters = [];
  int _hintCount = 3;
  bool _hasAcceptedDisclaimer = false;
  double _playerX = 0;
  double _playerY = 0;
  String _playerSprite = "protagonist_normal";

  String get name => _name;
  int get health => _health;
  int get maxHealth => _maxHealth;
  int get sanity => _sanity;
  int get maxSanity => _maxSanity;
  List<Item> get inventory => List.unmodifiable(_inventory);
  int get currentChapter => _currentChapter;
  String get currentScene => _currentScene;
  List<String> get collectedItems => List.unmodifiable(_collectedItems);
  List<String> get solvedPuzzles => List.unmodifiable(_solvedPuzzles);
  List<String> get visitedScenes => List.unmodifiable(_visitedScenes);
  List<int> get completedChapters => List.unmodifiable(_completedChapters);
  int get hintCount => _hintCount;
  bool get hasAcceptedDisclaimer => _hasAcceptedDisclaimer;
  bool get disclaimerAccepted => _hasAcceptedDisclaimer;
  SanityLevel get sanityLevel {
    if (_sanity >= 75) return SanityLevel.normal;
    if (_sanity >= 50) return SanityLevel.anxious;
    if (_sanity >= 25) return SanityLevel.terrified;
    return SanityLevel.insane;
  }

  double get playerX => _playerX;
  double get playerY => _playerY;
  String get playerSprite => _playerSprite;

  void changeHealth(int amount) {
    if (amount > 0) {
      heal(amount);
    } else {
      takeDamage(-amount);
    }
  }

  void changeSanity(int amount) {
    if (amount > 0) {
      restoreSanity(amount);
    } else {
      decreaseSanity(-amount);
    }
  }

  void takeDamage(int amount) {
    _health = (_health - amount).clamp(0, _maxHealth).toInt();
    if (_health <= 0) {
      _onPlayerDeath();
    }
    notifyListeners();
  }

  void heal(int amount) {
    _health = (_health + amount).clamp(0, _maxHealth).toInt();
    notifyListeners();
  }

  void decreaseSanity(int amount) {
    _sanity = (_sanity - amount).clamp(0, _maxSanity).toInt();
    notifyListeners();
  }

  void restoreSanity(int amount) {
    _sanity = (_sanity + amount).clamp(0, _maxSanity).toInt();
    notifyListeners();
  }

  bool addItemById(String itemId) {
    final item = ItemDatabase.getItem(itemId);
    if (item != null) {
      return addItem(item);
    }
    return false;
  }

  bool addItem(Item item) {
    if (!_collectedItems.contains(item.id) && _inventory.length < 20) {
      _inventory.add(item);
      _collectedItems.add(item.id);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool removeItem(String itemId) {
    final index = _inventory.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _inventory.removeAt(index);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool hasItem(String itemId) {
    return _inventory.any((item) => item.id == itemId);
  }

  Item? getItem(String itemId) {
    try {
      return _inventory.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  void completeChapter(int chapterId) {
    if (!_completedChapters.contains(chapterId)) {
      _completedChapters.add(chapterId);
      notifyListeners();
    }
  }

  bool isChapterCompleted(int chapterId) {
    return _completedChapters.contains(chapterId);
  }

  void useHint() {
    if (_hintCount > 0) {
      _hintCount--;
      notifyListeners();
    }
  }

  void addHint() {
    _hintCount++;
    notifyListeners();
  }

  void setChapter(int chapter) {
    _currentChapter = chapter;
    notifyListeners();
  }

  void setScene(String sceneId) {
    _currentScene = sceneId;
    if (!_visitedScenes.contains(sceneId)) {
      _visitedScenes.add(sceneId);
    }
    notifyListeners();
  }

  void solvePuzzle(String puzzleId) {
    if (!_solvedPuzzles.contains(puzzleId)) {
      _solvedPuzzles.add(puzzleId);
      notifyListeners();
    }
  }

  bool isPuzzleSolved(String puzzleId) {
    return _solvedPuzzles.contains(puzzleId);
  }

  void setPlayerPosition(double x, double y) {
    _playerX = x;
    _playerY = y;
    notifyListeners();
  }

  void setPlayerSprite(String spriteName) {
    _playerSprite = spriteName;
    notifyListeners();
  }

  void acceptDisclaimer() {
    _hasAcceptedDisclaimer = true;
    notifyListeners();
  }

  void _onPlayerDeath() {
    _health = _maxHealth;
    _sanity = (_sanity - 20).clamp(0, _maxSanity).toInt();
  }

  void reset() {
    _health = _maxHealth;
    _sanity = _maxSanity;
    _inventory.clear();
    _currentChapter = 1;
    _currentScene = "";
    _collectedItems.clear();
    _solvedPuzzles.clear();
    _visitedScenes.clear();
    _completedChapters.clear();
    _hintCount = 3;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        'name': _name,
        'health': _health,
        'maxHealth': _maxHealth,
        'sanity': _sanity,
        'maxSanity': _maxSanity,
        'inventory': _inventory.map((item) => item.toJson()).toList(),
        'currentChapter': _currentChapter,
        'currentScene': _currentScene,
        'collectedItems': _collectedItems,
        'solvedPuzzles': _solvedPuzzles,
        'visitedScenes': _visitedScenes,
        'completedChapters': _completedChapters,
        'hintCount': _hintCount,
        'hasAcceptedDisclaimer': _hasAcceptedDisclaimer,
      };

  void fromJson(Map<String, dynamic> json) {
    _name = json['name'] ?? "林小雨";
    _health = json['health'] ?? 100;
    _maxHealth = json['maxHealth'] ?? 100;
    _sanity = json['sanity'] ?? 100;
    _maxSanity = json['maxSanity'] ?? 100;
    _currentChapter = json['currentChapter'] ?? 1;
    _currentScene = json['currentScene'] ?? "";
    _collectedItems = List<String>.from(json['collectedItems'] ?? []);
    _solvedPuzzles = List<String>.from(json['solvedPuzzles'] ?? []);
    _visitedScenes = List<String>.from(json['visitedScenes'] ?? []);
    _completedChapters = List<int>.from(json['completedChapters'] ?? []);
    _hintCount = json['hintCount'] ?? 3;
    _hasAcceptedDisclaimer = json['hasAcceptedDisclaimer'] ?? false;
    _inventory.clear();
    if (json['inventory'] != null) {
      for (final itemJson in (json['inventory'] as List)) {
        final item = Item.fromJson(itemJson);
        _inventory.add(item);
      }
    }
    notifyListeners();
  }

  Future<void> saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(toJson());
      await prefs.setString('red_paper_umbrella_save', jsonStr);
    } catch (e) {
      debugPrint('Save error: $e');
    }
  }

  Future<void> loadGame() async {
    try {
      ItemDatabase.initialize();
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('red_paper_umbrella_save');
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr);
        fromJson(json);
      }
    } catch (e) {
      debugPrint('Load error: $e');
    }
  }
}
