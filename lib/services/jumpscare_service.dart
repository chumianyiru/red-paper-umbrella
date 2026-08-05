import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import '../models/character.dart';
import '../models/game_state.dart';
import 'audio_service.dart';

class JumpscareService {
  static final JumpscareService _instance = JumpscareService._internal();
  factory JumpscareService() => _instance;
  JumpscareService._internal();

  final AudioService _audioService = AudioService();
  final Random _random = Random();

  GameState? _gameState;
  bool _isJumpscareActive = false;
  Character? _currentJumpscareCharacter;
  CharacterSprite? _currentJumpscareSprite;
  final _jumpscareController = StreamController<JumpscareEvent>.broadcast();

  Stream<JumpscareEvent> get jumpscareStream => _jumpscareController.stream;
  bool get isJumpscareActive => _isJumpscareActive;
  Character? get currentCharacter => _currentJumpscareCharacter;
  CharacterSprite? get currentSprite => _currentJumpscareSprite;

  void init(GameState gameState) {
    _gameState = gameState;
  }

  Future<void> triggerRandomJumpscare(double dangerChance) async {
    if (_isJumpscareActive) return;
    if (_random.nextDouble() > dangerChance) return;

    final characters = Character.allCharacters.where((c) => c.isHostile).toList();
    if (characters.isEmpty) return;

    final character = characters[_random.nextInt(characters.length)];
    await triggerJumpscare(character);
  }

  Future<void> triggerJumpscare(Character character) async {
    if (_isJumpscareActive) return;
    _isJumpscareActive = true;
    _gameState?.setPhase(GamePhase.jumpscare);

    final jumpscareSprites = character.sprites.where((s) => s.isJumpscare).toList();
    final sprite = jumpscareSprites.isNotEmpty
        ? jumpscareSprites[_random.nextInt(jumpscareSprites.length)]
        : character.sprites.last;

    _currentJumpscareCharacter = character;
    _currentJumpscareSprite = sprite;

    _jumpscareController.add(JumpscareEvent(
      character: character,
      sprite: sprite,
      type: JumpscareType.appear,
    ));

    if (character.jumpscareSound != null) {
      await _audioService.playJumpscare(character.jumpscareSound!);
    } else if (sprite.soundEffect != null) {
      await _audioService.playJumpscare(sprite.soundEffect!);
    }

    if (_gameState?.vibrationEnabled ?? true) {
      try {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(
            pattern: [0, 200, 100, 300, 100, 400],
            intensities: [255, 200, 255, 200, 255],
          );
        }
      } catch (_) {}
    }

    final damage = 10 + _random.nextInt(20);
    _gameState?.takeDamage(damage);
    _gameState?.reduceSanity(15 + _random.nextInt(20));

    await Future.delayed(Duration(milliseconds: sprite.duration > 0 ? sprite.duration : 1500));

    _jumpscareController.add(JumpscareEvent(
      character: character,
      sprite: sprite,
      type: JumpscareType.disappear,
    ));

    _isJumpscareActive = false;
    _currentJumpscareCharacter = null;
    _currentJumpscareSprite = null;
    _gameState?.setPhase(GamePhase.playing);
  }

  Future<void> triggerJumpscareById(String jumpscareId, {VoidCallback? onComplete}) async {
    Character? character;
    try {
      character = Character.allCharacters.firstWhere(
        (c) => c.id == jumpscareId || c.jumpscareSound?.contains(jumpscareId) == true,
      );
    } catch (_) {
      character = Character.allCharacters.firstWhere(
        (c) => c.id == 'shadow',
      );
    }

    await triggerJumpscare(character);
    if (onComplete != null) {
      onComplete();
    }
  }

  Future<void> triggerQuickJumpscare() async {
    if (_isJumpscareActive) return;

    _isJumpscareActive = true;
    final shadow = Character.allCharacters.firstWhere((c) => c.id == 'shadow');
    final sprite = shadow.sprites.where((s) => s.isJumpscare).first;

    _currentJumpscareCharacter = shadow;
    _currentJumpscareSprite = sprite;

    _jumpscareController.add(JumpscareEvent(
      character: shadow,
      sprite: sprite,
      type: JumpscareType.flash,
    ));

    try {
      _audioService.playJumpscare('shadow_flash.mp3');
    } catch (_) {}

    if (_gameState?.vibrationEnabled ?? true) {
      try {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 300);
        }
      } catch (_) {}
    }

    _gameState?.reduceSanity(10);

    await Future.delayed(const Duration(milliseconds: 500));

    _jumpscareController.add(JumpscareEvent(
      character: shadow,
      sprite: sprite,
      type: JumpscareType.disappear,
    ));

    _isJumpscareActive = false;
    _currentJumpscareCharacter = null;
    _currentJumpscareSprite = null;
  }

  void dispose() {
    _jumpscareController.close();
  }
}

enum JumpscareType {
  appear,
  disappear,
  flash,
}

class JumpscareEvent {
  final Character character;
  final CharacterSprite sprite;
  final JumpscareType type;

  const JumpscareEvent({
    required this.character,
    required this.sprite,
    required this.type,
  });
}
