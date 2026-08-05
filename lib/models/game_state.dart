import 'package:flutter/foundation.dart';
import 'item.dart';
import 'scene.dart';

enum GamePhase {
  mainMenu,
  disclaimer,
  playing,
  paused,
  jumpscare,
  advertisement,
  puzzle,
  gameOver,
  ending,
}

class GameState extends ChangeNotifier {
  GamePhase _phase = GamePhase.mainMenu;
  int _health = 100;
  int _maxHealth = 100;
  int _sanity = 100;
  int _currentSceneIndex = 0;
  String? _currentSceneId;
  final List<Item> _inventory = [];
  final Set<String> _visitedScenes = {};
  final Set<String> _collectedItems = {};
  final Set<String> _solvedPuzzles = {};
  final List<String> _dialogueHistory = [];
  String? _equippedItem;
  bool _hasLight = false;
  double _volume = 0.8;
  bool _sfxEnabled = true;
  bool _bgmEnabled = true;
  bool _vibrationEnabled = true;
  bool _gyroAvailable = false;
  bool _firstPlay = true;
  int _chapter = 1;
  bool _hasRedUmbrella = false;

  GamePhase get phase => _phase;
  int get health => _health;
  int get maxHealth => _maxHealth;
  int get sanity => _sanity;
  String? get currentSceneId => _currentSceneId;
  List<Item> get inventory => List.unmodifiable(_inventory);
  Set<String> get visitedScenes => Set.unmodifiable(_visitedScenes);
  Set<String> get collectedItems => Set.unmodifiable(_collectedItems);
  Set<String> get solvedPuzzles => Set.unmodifiable(_solvedPuzzles);
  List<String> get dialogueHistory => List.unmodifiable(_dialogueHistory);
  String? get equippedItem => _equippedItem;
  bool get hasLight => _hasLight;
  double get volume => _volume;
  bool get sfxEnabled => _sfxEnabled;
  bool get bgmEnabled => _bgmEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get gyroAvailable => _gyroAvailable;
  bool get firstPlay => _firstPlay;
  int get chapter => _chapter;
  bool get hasRedUmbrella => _hasRedUmbrella;

  Scene? get currentScene {
    if (_currentSceneId == null) return null;
    return Scene.getById(_currentSceneId!);
  }

  void setPhase(GamePhase phase) {
    _phase = phase;
    notifyListeners();
  }

  void setHealth(int value) {
    _health = value.clamp(0, _maxHealth);
    if (_health <= 0) {
      _phase = GamePhase.gameOver;
    }
    notifyListeners();
  }

  void takeDamage(int amount) {
    setHealth(_health - amount);
  }

  void heal(int amount) {
    setHealth(_health + amount);
  }

  void setSanity(int value) {
    _sanity = value.clamp(0, 100);
    notifyListeners();
  }

  void reduceSanity(int amount) {
    setSanity(_sanity - amount);
  }

  void goToScene(String sceneId) {
    _currentSceneId = sceneId;
    _visitedScenes.add(sceneId);
    final scene = Scene.getById(sceneId);
    if (scene?.entryDialogue != null) {
      addDialogue(scene!.entryDialogue!);
    }
    notifyListeners();
  }

  void addItem(Item item) {
    if (!_collectedItems.contains(item.id)) {
      _inventory.add(item);
      _collectedItems.add(item.id);
      if (item.id == 'lit_candle') {
        _hasLight = true;
      }
      if (item.id == 'red_umbrella') {
        _hasRedUmbrella = true;
      }
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _inventory.removeWhere((item) => item.id == itemId);
    if (itemId == 'lit_candle') {
      _hasLight = false;
    }
    notifyListeners();
  }

  bool hasItem(String itemId) {
    return _inventory.any((item) => item.id == itemId);
  }

  Item? getItem(String itemId) {
    try {
      return _inventory.firstWhere((item) => item.id == itemId);
    } catch (_) {
      return null;
    }
  }

  void equipItem(String? itemId) {
    _equippedItem = itemId;
    notifyListeners();
  }

  void useItem(Item item) {
    if (item.healAmount != null) {
      heal(item.healAmount!);
      _inventory.remove(item);
    }
    if (item.useDescription != null) {
      addDialogue(item.useDescription!);
    }
    notifyListeners();
  }

  void combineItems(Item item1, Item item2) {
    if (item1.combineWith == item2.id && item1.combineResult != null) {
      final result = Item.getById(item1.combineResult!);
      if (result != null) {
        _inventory.remove(item1);
        _inventory.remove(item2);
        addItem(result);
      }
    }
  }

  void addDialogue(String text) {
    _dialogueHistory.add(text);
    notifyListeners();
  }

  void clearDialogue() {
    _dialogueHistory.clear();
    notifyListeners();
  }

  void solvePuzzle(String puzzleId) {
    _solvedPuzzles.add(puzzleId);
    notifyListeners();
  }

  bool isPuzzleSolved(String puzzleId) {
    return _solvedPuzzles.contains(puzzleId);
  }

  void setGyroAvailable(bool available) {
    _gyroAvailable = available;
    notifyListeners();
  }

  void setFirstPlay(bool value) {
    _firstPlay = value;
    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value;
    notifyListeners();
  }

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
    notifyListeners();
  }

  void setBgmEnabled(bool enabled) {
    _bgmEnabled = enabled;
    notifyListeners();
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    notifyListeners();
  }

  void startNewGame() {
    _phase = GamePhase.playing;
    _health = _maxHealth;
    _sanity = 100;
    _currentSceneId = 'main_gate';
    _inventory.clear();
    _visitedScenes.clear();
    _collectedItems.clear();
    _solvedPuzzles.clear();
    _dialogueHistory.clear();
    _equippedItem = null;
    _hasLight = false;
    _chapter = 1;
    _hasRedUmbrella = false;
    _visitedScenes.add('main_gate');
    notifyListeners();
  }

  void restartGame() {
    startNewGame();
  }

  void showGoodEnding() {
    _phase = GamePhase.ending;
    notifyListeners();
  }

  void showBadEnding() {
    _phase = GamePhase.gameOver;
    notifyListeners();
  }
}
