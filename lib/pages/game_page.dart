import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/horror_theme.dart';
import '../widgets/horror_painter.dart';
import '../widgets/procedural_scene.dart';
import '../models/game_state.dart';
import '../models/scene.dart';
import '../models/item.dart';
import '../services/audio_service.dart';
import '../services/jumpscare_service.dart';
import '../services/gyroscope_service.dart';
import '../services/ad_service.dart';
import '../services/storage_service.dart';
import 'main_menu_page.dart';
import 'puzzle_page.dart';
import 'ad_page.dart';
import 'jumpscare_overlay.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final _audioService = AudioService();
  final _jumpscareService = JumpscareService();
  final _gyroService = GyroscopeService();
  final _adService = AdService();
  final _storageService = StorageService();
  final _random = Random();

  late AnimationController _sceneFadeController;
  late AnimationController _pulseController;
  late AnimationController _sanityController;
  late Animation<double> _sceneFade;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sanityAnimation;

  String? _currentDialogue;
  bool _showInventory = false;
  bool _isTransitioning = false;
  Offset? _tapPosition;
  Hotspot? _selectedHotspot;
  bool _showHotspotInfo = false;

  @override
  void initState() {
    super.initState();

    _sceneFadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _sanityController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _sceneFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sceneFadeController, curve: Curves.easeIn),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _sanityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sanityController, curve: Curves.easeInOut),
    );

    _sceneFadeController.forward();
    _initGyro();
    _playSceneBgm();
    _startRandomJumpscareTimer();
  }

  Future<void> _initGyro() async {
    final available = await _gyroService.isGyroAvailable();
    if (mounted) {
      context.read<GameState>().setGyroAvailable(available);
    }
  }

  void _playSceneBgm() {
    final scene = context.read<GameState>().currentScene;
    if (scene?.bgm != null) {
      try {
        _audioService.playBgm(scene!.bgm!);
      } catch (_) {}
    }
    if (scene?.ambientSound != null) {
      try {
        _audioService.playAmbient(scene!.ambientSound!);
      } catch (_) {}
    }
  }

  void _startRandomJumpscareTimer() {
    Future.delayed(Duration(seconds: 10 + _random.nextInt(20)), () {
      if (mounted && context.read<GameState>().phase == GamePhase.playing) {
        final scene = context.read<GameState>().currentScene;
        if (scene != null && _random.nextDouble() < scene.dangerLevel) {
          _triggerRandomJumpscare();
        }
        _startRandomJumpscareTimer();
      }
    });
  }

  void _triggerRandomJumpscare() {
    final jumpTypes = ['shadow', 'ghost', 'bride', 'zombie'];
    final type = jumpTypes[_random.nextInt(jumpTypes.length)];
    _jumpscareService.init(context.read<GameState>());
    _jumpscareService.triggerJumpscareById(
      type,
      onComplete: () {
        if (mounted) {
          context.read<GameState>().takeDamage(10 + _random.nextInt(15));
          context.read<GameState>().reduceSanity(5 + _random.nextInt(10));
        }
      },
    );
  }

  @override
  void dispose() {
    _sceneFadeController.dispose();
    _pulseController.dispose();
    _sanityController.dispose();
    _gyroService.dispose();
    super.dispose();
  }

  void _onSceneTap(TapDownDetails details, Scene scene) {
    if (_isTransitioning) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final size = box.size;

    final relativeX = localPosition.dx / size.width;
    final relativeY = localPosition.dy / size.height;

    setState(() {
      _tapPosition = localPosition;
    });

    for (final hotspot in scene.hotspots) {
      final hotspotX = hotspot.x * size.width;
      final hotspotY = hotspot.y * size.height;
      final hotspotRect = Rect.fromLTWH(
        hotspotX,
        hotspotY,
        hotspot.width,
        hotspot.height,
      );

      if (hotspotRect.contains(localPosition)) {
        _interactWithHotspot(hotspot);
        return;
      }
    }

    _showDialogue('这里好像没什么特别的...');
  }

  void _interactWithHotspot(Hotspot hotspot) {
    final gameState = context.read<GameState>();

    if (hotspot.requiredItem != null && !gameState.hasItem(hotspot.requiredItem!)) {
      _showDialogue('需要特定的物品才能互动...');
      try {
        _audioService.playSfx('locked.mp3');
      } catch (_) {}
      return;
    }

    if (hotspot.dangerChance > 0 && _random.nextDouble() < hotspot.dangerChance) {
      if (hotspot.jumpscareId != null) {
        _jumpscareService.init(gameState);
        _jumpscareService.triggerJumpscareById(
          hotspot.jumpscareId!,
          onComplete: () {
            gameState.takeDamage(15 + _random.nextInt(20));
            gameState.reduceSanity(10 + _random.nextInt(15));
          },
        );
        return;
      }
    }

    if (hotspot.dialogue != null) {
      _showDialogue(hotspot.dialogue!);
    } else if (hotspot.description.isNotEmpty) {
      _showDialogue(hotspot.description);
    }

    try {
      _audioService.playSfx('interact.mp3');
    } catch (_) {}

    if (hotspot.itemToFind != null && !gameState.collectedItems.contains(hotspot.itemToFind)) {
      final item = Item.getById(hotspot.itemToFind!);
      if (item != null) {
        _collectItem(item);
      }
    }

    if (hotspot.targetScene != null) {
      _transitionToScene(hotspot.targetScene!);
    }

    if (hotspot.puzzleType != null) {
      _startPuzzle(hotspot);
    }
  }

  void _collectItem(Item item) {
    final gameState = context.read<GameState>();
    gameState.addItem(item);

    showDialog(
      context: context,
      builder: (context) => _ItemFoundDialog(item: item),
    );

    try {
      _audioService.playSfx('item_get.mp3');
    } catch (_) {}
  }

  void _transitionToScene(String sceneId) {
    setState(() => _isTransitioning = true);
    _sceneFadeController.reverse().then((_) {
      context.read<GameState>().goToScene(sceneId);
      _playSceneBgm();
      _sceneFadeController.forward();
      setState(() => _isTransitioning = false);
    });
  }

  void _startPuzzle(Hotspot hotspot) {
    if (hotspot.puzzleType == PuzzleType.gyroscope) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PuzzlePage(
            puzzleType: hotspot.puzzleType!,
            onComplete: () {
              context.read<GameState>().solvePuzzle(hotspot.id);
              if (hotspot.targetScene != null) {
                _transitionToScene(hotspot.targetScene!);
              }
            },
          ),
        ),
      );
    }
  }

  void _showDialogue(String text) {
    setState(() => _currentDialogue = text);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _currentDialogue = null);
      }
    });
  }

  void _useItem(Item item) {
    final gameState = context.read<GameState>();

    if (item.healAmount != null) {
      gameState.useItem(item);
      try {
        _audioService.playSfx('heal.mp3');
      } catch (_) {}
      _showDialogue('使用了${item.name}');
      return;
    }

    gameState.equipItem(gameState.equippedItem == item.id ? null : item.id);
    setState(() => _showInventory = false);
  }

  void _requestHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HorrorTheme.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: HorrorTheme.bloodRed, width: 2),
        ),
        title: const Text('获取提示', style: TextStyle(color: HorrorTheme.bloodRed)),
        content: const Text(
          '观看30秒广告即可获得提示，是否继续？',
          style: TextStyle(color: HorrorTheme.ghostWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: HorrorTheme.paleSkin)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdPage()),
              ).then((_) {
                _showHint();
              });
            },
            child: const Text('观看广告', style: TextStyle(color: HorrorTheme.bloodRed)),
          ),
        ],
      ),
    );
  }

  void _showHint() {
    final hints = [
      '仔细检查每个场景的角落，可能会有意外发现...',
      '有些物品需要组合使用才能发挥作用...',
      '黑暗的地方需要光源才能看清...',
      '红纸伞是关键，但要小心它带来的诅咒...',
      '石狮子的眼睛似乎藏着秘密...',
      '枯井里有重要的东西，但要小心...',
    ];
    final hint = hints[_random.nextInt(hints.length)];
    _showDialogue('【提示】$hint');
  }

  void _toggleInventory() {
    setState(() => _showInventory = !_showInventory);
    try {
      _audioService.playSfx(_showInventory ? 'inventory_open.mp3' : 'inventory_close.mp3');
    } catch (_) {}
  }

  void _pauseGame() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PauseDialog(
        onResume: () => Navigator.pop(context),
        onSave: () {
          final gs = context.read<GameState>();
          _storageService.saveGame({
            'health': gs.health,
            'sanity': gs.sanity,
            'currentSceneId': gs.currentSceneId,
            'inventory': gs.inventory.map((i) => i.id).toList(),
            'collectedItems': gs.collectedItems.toList(),
            'solvedPuzzles': gs.solvedPuzzles.toList(),
            'visitedScenes': gs.visitedScenes.toList(),
            'hasLight': gs.hasLight,
            'chapter': gs.chapter,
            'hasRedUmbrella': gs.hasRedUmbrella,
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('游戏已保存'),
              backgroundColor: HorrorTheme.darkRed,
            ),
          );
        },
        onQuit: () {
          _audioService.stopBgm();
          _audioService.stopAmbient();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainMenuPage()),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        if (gameState.phase == GamePhase.gameOver) {
          return _buildGameOverScreen();
        }
        if (gameState.phase == GamePhase.ending && gameState.hasRedUmbrella) {
          return _buildEndingScreen();
        }

        final scene = gameState.currentScene;
        if (scene == null) {
          return const Scaffold(
            backgroundColor: HorrorTheme.deepBlack,
            body: Center(child: CircularProgressIndicator(color: HorrorTheme.bloodRed)),
          );
        }

        return Scaffold(
          backgroundColor: HorrorTheme.deepBlack,
          body: Stack(
            children: [
              GestureDetector(
                onTapDown: (details) => _onSceneTap(details, scene),
                child: FadeTransition(
                  opacity: _sceneFade,
                  child: Stack(
                    children: [
                      _buildSceneBackground(scene),
                      if (scene.isDark && !gameState.hasLight)
                        _buildDarknessOverlay(),
                      _buildHotspots(scene),
                      _buildVignette(),
                    ],
                  ),
                ),
              ),
              _buildHUD(gameState),
              if (_currentDialogue != null)
                _buildDialogueBox(),
              if (_showInventory)
                _buildInventory(gameState),
              const JumpscareOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSceneBackground(Scene scene) {
    return Positioned.fill(
      child: ProceduralScene(
        sceneId: scene.id,
        child: CustomPaint(
          painter: FogPainter(
            fogDensity: scene.dangerLevel * 0.5,
          ),
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildDarknessOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.1 + (_pulseAnimation.value - 0.8) * 0.05,
                  colors: [
                    Colors.transparent,
                    HorrorTheme.deepBlack.withOpacity(0.95),
                  ],
                  stops: const [0, 1],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHotspots(Scene scene) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: scene.hotspots.map((hotspot) {
            final x = hotspot.x * constraints.maxWidth;
            final y = hotspot.y * constraints.maxHeight;
            return Positioned(
              left: x,
              top: y,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.0 + (hotspot.dangerChance > 0 ? _pulseAnimation.value * 0.1 : 0),
                    child: Container(
                      width: hotspot.width,
                      height: hotspot.height,
                      decoration: hotspot.dangerChance > 0
                          ? BoxDecoration(
                              border: Border.all(
                                color: HorrorTheme.bloodRed.withOpacity(0.3),
                                width: 1,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildVignette() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: VignettePainter(),
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildHUD(GameState gameState) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildStatusBars(gameState),
                  const Spacer(),
                  _buildHUDButtons(),
                ],
              ),
              const SizedBox(height: 8),
              _buildSceneName(gameState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBars(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HorrorTheme.deepBlack.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHealthBar(gameState),
          const SizedBox(height: 8),
          _buildSanityBar(gameState),
        ],
      ),
    );
  }

  Widget _buildHealthBar(GameState gameState) {
    final healthPercent = gameState.health / gameState.maxHealth;
    final healthColor = healthPercent > 0.5
        ? HorrorTheme.bloodRed
        : healthPercent > 0.25
            ? Colors.orange
            : Colors.redAccent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.favorite, color: HorrorTheme.bloodRed, size: 16),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(
                      height: 12,
                      color: HorrorTheme.darkGray,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 12,
                      width: 120 * healthPercent,
                      decoration: BoxDecoration(
                        color: healthColor,
                        boxShadow: [
                          BoxShadow(
                            color: healthColor.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '生命 ${gameState.health}',
                style: const TextStyle(
                  color: HorrorTheme.ghostWhite,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSanityBar(GameState gameState) {
    final sanityPercent = gameState.sanity / 100;
    final sanityColor = sanityPercent > 0.5
        ? Colors.purple
        : sanityPercent > 0.25
            ? Colors.deepPurple
            : HorrorTheme.bloodRed;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.psychology, color: Colors.purple, size: 16),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      color: HorrorTheme.darkGray,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: 120 * sanityPercent,
                      decoration: BoxDecoration(
                        color: sanityColor,
                        boxShadow: [
                          BoxShadow(
                            color: sanityColor.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '理智 ${gameState.sanity}',
                style: const TextStyle(
                  color: HorrorTheme.ghostWhite,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHUDButtons() {
    return Row(
      children: [
        _HUDCircleButton(
          icon: Icons.lightbulb_outline,
          onPressed: _requestHint,
          tooltip: '提示',
        ),
        const SizedBox(width: 8),
        _HUDCircleButton(
          icon: Icons.backpack,
          onPressed: _toggleInventory,
          tooltip: '物品栏',
          isActive: _showInventory,
        ),
        const SizedBox(width: 8),
        _HUDCircleButton(
          icon: Icons.pause,
          onPressed: _pauseGame,
          tooltip: '暂停',
        ),
      ],
    );
  }

  Widget _buildSceneName(GameState gameState) {
    final scene = gameState.currentScene;
    if (scene == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedBuilder(
        animation: _sceneFadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _sceneFade.value * 0.7,
            child: Text(
              scene.name,
              style: const TextStyle(
                color: HorrorTheme.ghostWhite,
                fontSize: 18,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: HorrorTheme.bloodRed,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogueBox() {
    return Positioned(
      bottom: 100,
      left: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HorrorTheme.deepBlack.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: HorrorTheme.bloodRed.withOpacity(0.5 + _pulseAnimation.value * 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: HorrorTheme.bloodRed.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Text(
              _currentDialogue!,
              style: const TextStyle(
                color: HorrorTheme.ghostWhite,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventory(GameState gameState) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleInventory,
        child: Container(
          color: Colors.black87,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: HorrorTheme.darkGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HorrorTheme.bloodRed, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '物品栏',
                    style: TextStyle(
                      color: HorrorTheme.bloodRed,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (gameState.inventory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        '暂无物品',
                        style: TextStyle(color: HorrorTheme.paleSkin),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: gameState.inventory.map((item) {
                        final isEquipped = gameState.equippedItem == item.id;
                        return _InventoryItem(
                          item: item,
                          isEquipped: isEquipped,
                          onTap: () => _useItem(item),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _toggleInventory,
                    child: const Text(
                      '关闭',
                      style: TextStyle(color: HorrorTheme.bloodRed),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Scaffold(
      backgroundColor: HorrorTheme.deepBlack,
      body: HorrorBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '你死了',
                style: TextStyle(
                  color: HorrorTheme.bloodRed,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: HorrorTheme.bloodRed,
                      blurRadius: 50,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '红纸伞的诅咒...还是降临到了你身上...',
                style: TextStyle(
                  color: HorrorTheme.paleSkin,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 64),
              _HorrorMenuButton(
                text: '重新开始',
                onPressed: () {
                  context.read<GameState>().restartGame();
                },
              ),
              const SizedBox(height: 16),
              _HorrorMenuButton(
                text: '返回主菜单',
                onPressed: () {
                  _audioService.stopBgm();
                  _audioService.stopAmbient();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainMenuPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndingScreen() {
    return Scaffold(
      backgroundColor: HorrorTheme.deepBlack,
      body: HorrorBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '结局',
                style: TextStyle(
                  color: HorrorTheme.bloodRed,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: HorrorTheme.darkGray.withOpacity(0.8),
                  border: Border.all(color: HorrorTheme.bloodRed),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '你撑起了红纸伞，伞下传来女子的轻声啜泣...\n\n"谢谢你...来找我..."\n\n红纸伞缓缓闭合，老宅的诅咒终于解除。\n但你知道，她会一直在伞下等你...',
                  style: TextStyle(
                    color: HorrorTheme.ghostWhite,
                    fontSize: 16,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 64),
              _HorrorMenuButton(
                text: '返回主菜单',
                onPressed: () {
                  _audioService.stopBgm();
                  _audioService.stopAmbient();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainMenuPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HUDCircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isActive;

  const _HUDCircleButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isActive = false,
  });

  @override
  State<_HUDCircleButton> createState() => _HUDCircleButtonState();
}

class _HUDCircleButtonState extends State<_HUDCircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isActive || _pressed
                ? HorrorTheme.bloodRed
                : HorrorTheme.deepBlack.withOpacity(0.8),
            border: Border.all(
              color: widget.isActive ? Colors.white : HorrorTheme.bloodRed,
              width: 2,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: HorrorTheme.bloodRed.withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            widget.icon,
            color: widget.isActive || _pressed ? Colors.white : HorrorTheme.bloodRed,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _InventoryItem extends StatefulWidget {
  final Item item;
  final bool isEquipped;
  final VoidCallback onTap;

  const _InventoryItem({
    required this.item,
    required this.isEquipped,
    required this.onTap,
  });

  @override
  State<_InventoryItem> createState() => _InventoryItemState();
}

class _InventoryItemState extends State<_InventoryItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: HorrorTheme.darkGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: HorrorTheme.bloodRed, width: 2),
            ),
            title: Text(widget.item.name, style: const TextStyle(color: HorrorTheme.bloodRed)),
            content: Text(
              widget.item.description,
              style: const TextStyle(color: HorrorTheme.ghostWhite),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定', style: TextStyle(color: HorrorTheme.bloodRed)),
              ),
            ],
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: _pressed
              ? HorrorTheme.bloodRed
              : widget.isEquipped
                  ? HorrorTheme.darkRed
                  : HorrorTheme.deepBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isEquipped ? Colors.white : HorrorTheme.bloodRed.withOpacity(0.5),
            width: widget.isEquipped ? 2 : 1,
          ),
          boxShadow: widget.isEquipped
              ? [
                  BoxShadow(
                    color: HorrorTheme.bloodRed.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getItemIcon(widget.item.type),
              color: widget.isEquipped || _pressed ? Colors.white : HorrorTheme.bloodRed,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.name.length > 4
                  ? widget.item.name.substring(0, 4)
                  : widget.item.name,
              style: TextStyle(
                color: widget.isEquipped || _pressed ? Colors.white : HorrorTheme.paleSkin,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getItemIcon(ItemType type) {
    switch (type) {
      case ItemType.key:
        return Icons.vpn_key;
      case ItemType.note:
        return Icons.description;
      case ItemType.weapon:
        return Icons.campaign;
      case ItemType.tool:
        return Icons.build;
      case ItemType.clue:
        return Icons.search;
      case ItemType.consumable:
        return Icons.medical_services;
      case ItemType.special:
        return Icons.star;
    }
  }
}

class _ItemFoundDialog extends StatelessWidget {
  final Item item;

  const _ItemFoundDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HorrorTheme.darkGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: HorrorTheme.bloodRed, width: 2),
      ),
      title: const Text(
        '获得物品',
        style: TextStyle(color: HorrorTheme.bloodRed),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: HorrorTheme.deepBlack,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: HorrorTheme.bloodRed),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: HorrorTheme.bloodRed,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.name,
            style: const TextStyle(
              color: HorrorTheme.ghostWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: const TextStyle(
              color: HorrorTheme.paleSkin,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('确定', style: TextStyle(color: HorrorTheme.bloodRed)),
        ),
      ],
    );
  }
}

class _PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onSave;
  final VoidCallback onQuit;

  const _PauseDialog({
    required this.onResume,
    required this.onSave,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HorrorTheme.darkGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: HorrorTheme.bloodRed, width: 2),
      ),
      title: const Text(
        '游戏暂停',
        style: TextStyle(color: HorrorTheme.bloodRed),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PauseButton(text: '继续游戏', onPressed: onResume),
          const SizedBox(height: 12),
          _PauseButton(text: '保存游戏', onPressed: onSave),
          const SizedBox(height: 12),
          _PauseButton(text: '返回主菜单', onPressed: onQuit),
        ],
      ),
    );
  }
}

class _PauseButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _PauseButton({required this.text, required this.onPressed});

  @override
  State<_PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<_PauseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _pressed ? HorrorTheme.bloodRed : Colors.transparent,
          border: Border.all(color: HorrorTheme.bloodRed),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              color: _pressed ? Colors.white : HorrorTheme.bloodRed,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _HorrorMenuButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _HorrorMenuButton({required this.text, required this.onPressed});

  @override
  State<_HorrorMenuButton> createState() => _HorrorMenuButtonState();
}

class _HorrorMenuButtonState extends State<_HorrorMenuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _pressed ? HorrorTheme.darkRed : Colors.transparent,
          border: Border.all(color: HorrorTheme.bloodRed, width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: HorrorTheme.bloodRed.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              color: _pressed ? Colors.white : HorrorTheme.bloodRed,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}
