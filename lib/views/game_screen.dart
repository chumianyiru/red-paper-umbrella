import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../models/scene.dart';
import '../models/hotspot.dart';
import '../services/audio_service.dart';
import '../game/chapter1_scenes.dart';
import '../game/item_database.dart';
import '../widgets/hud_widget.dart';
import '../widgets/inventory_widget.dart';
import '../widgets/jumpscare_widget.dart';
import '../widgets/item_detail_dialog.dart';
import '../widgets/scene_painter.dart';
import 'chapter_select_screen.dart';

class GameScreen extends StatefulWidget {
  final int chapterId;

  const GameScreen({super.key, required this.chapterId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Map<String, Scene> _scenes;
  late Scene _currentScene;
  bool _isInventoryOpen = false;
  String? _selectedItemId;
  bool _showDialogue = false;
  List<DialogueLine> _currentDialogue = [];
  int _dialogueIndex = 0;
  bool _showJumpscare = false;
  double _jumpscareIntensity = 0.5;
  String? _messageText;
  final Set<String> _collectedHotspots = {};
  final Set<String> _usedHotspots = {};
  late AnimationController _sceneAnimController;
  late Animation<double> _sceneAnimation;

  @override
  void initState() {
    super.initState();
    _sceneAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _sceneAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sceneAnimController, curve: Curves.easeInOut),
    );
    _initializeScenes();
    _loadChapter();
  }

  @override
  void dispose() {
    _sceneAnimController.dispose();
    super.dispose();
  }

  void _initializeScenes() {
    ItemDatabase.initialize();
    _scenes = {};
    final sceneList = Chapter1Scenes.getScenes();
    for (final scene in sceneList) {
      _scenes[scene.id] = scene;
    }
  }

  void _loadChapter() {
    String startSceneId;
    switch (widget.chapterId) {
      case 1:
        startSceneId = 'ch1_entrance';
        break;
      default:
        startSceneId = 'ch1_entrance';
    }
    _currentScene = _scenes[startSceneId]!;
    _onSceneEnter();
  }

  void _onSceneEnter() {
    final audioService = Provider.of<AudioService>(context, listen: false);

    if (_currentScene.ambientSound != null) {
      audioService.playSfx(_currentScene.ambientSound!, loop: true);
    }

    if (_currentScene.onEnterDialogue.isNotEmpty) {
      setState(() {
        _currentDialogue = _currentScene.onEnterDialogue;
        _dialogueIndex = 0;
        _showDialogue = true;
      });
    }

    _currentScene.onEnter?.call();
  }

  void _navigateToScene(String sceneId) {
    final audioService = Provider.of<AudioService>(context, listen: false);
    audioService.stopSfx();

    if (_scenes.containsKey(sceneId)) {
      setState(() {
        _currentScene = _scenes[sceneId]!;
        _selectedItemId = null;
      });
      _onSceneEnter();
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (_showDialogue || _showJumpscare || _isInventoryOpen) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final Size size = box.size;

    Hotspot? tappedHotspot;
    for (final hotspot in _currentScene.hotspots) {
      if (hotspot.isHidden && !_isHotspotRevealed(hotspot)) continue;
      final hotspotKey = '${_currentScene.id}_${hotspot.id}';
      if (_collectedHotspots.contains(hotspotKey) && hotspot.oneTime) continue;

      final rect = Rect.fromLTRB(
        hotspot.position.left * size.width,
        hotspot.position.top * size.height,
        hotspot.position.right * size.width,
        hotspot.position.bottom * size.height,
      );

      if (rect.contains(localPosition)) {
        tappedHotspot = hotspot;
        break;
      }
    }

    if (tappedHotspot != null) {
      _handleHotspotTap(tappedHotspot);
    }
  }

  bool _isHotspotRevealed(Hotspot hotspot) {
    if (hotspot.id == 'drawer') {
      return true;
    }
    if (hotspot.id == 'secret_switch') {
      return _usedHotspots.contains('ch1_wedding_wooden_box_placed') ||
             Provider.of<Player>(context, listen: false).hasItem('wooden_box');
    }
    return true;
  }

  void _handleHotspotTap(Hotspot hotspot) {
    final player = Provider.of<Player>(context, listen: false);
    final audioService = Provider.of<AudioService>(context, listen: false);

    if (_selectedItemId != null) {
      _useItemOnHotspot(_selectedItemId!, hotspot);
      return;
    }

    switch (hotspot.type) {
      case HotspotType.item:
        final itemKey = '${_currentScene.id}_${hotspot.id}';
        if (hotspot.itemId != null && !_collectedHotspots.contains(itemKey)) {
          _collectItem(hotspot);
        }
        break;
      case HotspotType.examine:
        _examineHotspot(hotspot);
        break;
      case HotspotType.navigation:
        if (hotspot.targetSceneId != null) {
          audioService.playSfx('footstep');
          _navigateToScene(hotspot.targetSceneId!);
        }
        break;
      case HotspotType.puzzle:
        _handlePuzzleHotspot(hotspot);
        break;
      case HotspotType.jumpscare:
        _triggerJumpscare(hotspot.jumpscareIntensity);
        break;
      case HotspotType.npc:
        _examineHotspot(hotspot);
        break;
      case HotspotType.gyro:
        _handlePuzzleHotspot(hotspot);
        break;
      case HotspotType.raster:
        _handlePuzzleHotspot(hotspot);
        break;
    }
  }

  void _collectItem(Hotspot hotspot) {
    final player = Provider.of<Player>(context, listen: false);
    final audioService = Provider.of<AudioService>(context, listen: false);
    final item = ItemDatabase.getItem(hotspot.itemId!);

    if (item != null) {
      player.addItemById(hotspot.itemId!);
      audioService.playSfx('item_pickup');

      setState(() {
        _collectedHotspots.add('${_currentScene.id}_${hotspot.id}');
        _messageText = hotspot.onPickupMessage ?? '你获得了${item.name}';
      });
      _showMessage();

      if (hotspot.pickupJumpscare) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _triggerJumpscare(hotspot.jumpscareIntensity);
        });
      }

      if (hotspot.grantsItem != null) {
        player.addItemById(hotspot.grantsItem!);
      }
    }
  }

  void _examineHotspot(Hotspot hotspot) {
    final player = Provider.of<Player>(context, listen: false);
    final audioService = Provider.of<AudioService>(context, listen: false);

    audioService.playSfx('examine');

    setState(() {
      _messageText = hotspot.examineMessage ?? hotspot.description;
    });
    _showMessage();

    if (hotspot.jumpscareOnExamine) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _triggerJumpscare(hotspot.jumpscareIntensity);
      });
    }

    if (hotspot.decreasesSanity != null) {
      player.changeSanity(-hotspot.decreasesSanity!);
    }

    if (hotspot.decreasesHealth != null) {
      player.changeHealth(-hotspot.decreasesHealth!);
    }

    if (hotspot.targetSceneId != null && !hotspot.isHidden) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        _navigateToScene(hotspot.targetSceneId!);
      });
    }

    if (hotspot.chapterEndTrigger) {
      Future.delayed(const Duration(seconds: 2), () {
        _showChapterEnd();
      });
    }
  }

  void _handlePuzzleHotspot(Hotspot hotspot) {
    final player = Provider.of<Player>(context, listen: false);

    if (hotspot.requiredItem != null) {
      if (!player.hasItem(hotspot.requiredItem!)) {
        setState(() {
          _messageText = hotspot.lockedMessage ?? '这里需要特定的物品...';
        });
        _showMessage();
        return;
      }
    }

    if (hotspot.useItemMessage != null) {
      setState(() {
        _messageText = hotspot.useItemMessage;
        _usedHotspots.add('${_currentScene.id}_${hotspot.id}_used');
      });
      _showMessage();
    }

    if (hotspot.targetSceneId != null) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        _navigateToScene(hotspot.targetSceneId!);
      });
    }
  }

  void _useItemOnHotspot(String itemId, Hotspot hotspot) {
    final player = Provider.of<Player>(context, listen: false);
    final audioService = Provider.of<AudioService>(context, listen: false);
    final item = ItemDatabase.getItem(itemId);

    if (hotspot.requiredItem == itemId) {
      audioService.playSfx('item_use');

      String? resultMessage = hotspot.useItemMessage;

      if (hotspot.id == 'well_rope' && itemId == 'red_umbrella') {
        player.removeItem('red_umbrella');
        player.addItemById('wooden_box');
        resultMessage = '你用红纸伞勾住井绳，慢慢往上拉...拉上来一个湿漉漉的木盒！红纸伞不小心掉进了井里...';
        _usedHotspots.add('ch1_well_red_umbrella_used');
        _collectedHotspots.add('ch1_well_red_umbrella');
        _collectedHotspots.add('${_currentScene.id}_${hotspot.id}');
      }

      if (hotspot.id == 'locked_door' && itemId == 'bronze_key') {
        resultMessage = '钥匙插入锁孔，门缓缓打开，里面是喜堂！';
        _collectedHotspots.add('${_currentScene.id}_${hotspot.id}');
      }

      if (hotspot.id == 'secret_switch' && itemId == 'wooden_box') {
        resultMessage = '你把木盒放在供桌上，触发了机关...墙壁后是密室！';
        _usedHotspots.add('ch1_wedding_wooden_box_placed');
        _collectedHotspots.add('${_currentScene.id}_${hotspot.id}');
        player.removeItem('wooden_box');
      }

      setState(() {
        _messageText = resultMessage;
        _selectedItemId = null;
      });
      _showMessage();

      if (hotspot.targetSceneId != null) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          _navigateToScene(hotspot.targetSceneId!);
        });
      }
    } else {
      setState(() {
        _messageText = '${item?.name ?? "这个物品"}在这里没有用...';
      });
      _showMessage();
    }
  }

  void _triggerJumpscare(double intensity) {
    final audioService = Provider.of<AudioService>(context, listen: false);
    final player = Provider.of<Player>(context, listen: false);

    audioService.playSfx('jumpscare');
    HapticFeedback.heavyImpact();

    int sanityLoss = (20 * intensity).round();
    int healthLoss = (10 * intensity).round();
    player.changeSanity(-sanityLoss);
    player.changeHealth(-healthLoss);

    setState(() {
      _showJumpscare = true;
      _jumpscareIntensity = intensity;
    });

    Future.delayed(Duration(milliseconds: (800 * intensity).round()), () {
      if (mounted) {
        setState(() {
          _showJumpscare = false;
        });
      }
    });
  }

  void _showMessage() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _messageText = null;
        });
      }
    });
  }

  void _showChapterEnd() {
    final player = Provider.of<Player>(context, listen: false);
    player.completeChapter(widget.chapterId);
    player.saveGame();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a0a),
        title: const Text(
          '第一章 完',
          style: TextStyle(color: Color(0xFF8B0000), fontFamily: 'MaShanZheng'),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          '红纸伞的秘密才刚刚揭开...\n那个穿着嫁衣的女人到底是谁？\n阿明又在哪里？\n\n第二章：冥婚迎娶',
          style: TextStyle(color: Color(0xFFD3D3D3)),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChapterSelectScreen()),
              );
            },
            child: const Text('返回章节选择', style: TextStyle(color: Color(0xFF8B0000))),
          ),
        ],
      ),
    );
  }

  void _advanceDialogue() {
    if (_dialogueIndex < _currentDialogue.length - 1) {
      setState(() {
        _dialogueIndex++;
      });
    } else {
      setState(() {
        _showDialogue = false;
        _currentDialogue = [];
        _dialogueIndex = 0;
      });
    }
  }

  void _toggleInventory() {
    setState(() {
      _isInventoryOpen = !_isInventoryOpen;
      if (!_isInventoryOpen) {
        _selectedItemId = null;
      }
    });
  }

  void _onItemSelected(String? itemId) {
    setState(() {
      _selectedItemId = itemId;
    });
  }

  void _showItemDetail(String itemId) {
    showDialog(
      context: context,
      builder: (context) => ItemDetailDialog(
        itemId: itemId,
        onUse: () {
          setState(() {
            _selectedItemId = itemId;
            _isInventoryOpen = false;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Set<String> get _collectedHotspotIds {
    return _collectedHotspots.map((key) => key.split('_').last).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<Player>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: _onTapDown,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedBuilder(
                  animation: _sceneAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ScenePainter(
                        sceneId: _currentScene.id,
                        animationValue: _sceneAnimation.value,
                        sanity: player.sanity,
                        isJumpscare: _showJumpscare,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
                CustomPaint(
                  painter: HotspotOverlayPainter(
                    hotspots: _currentScene.hotspots,
                    selectedItemId: _selectedItemId,
                    collectedHotspotIds: _collectedHotspotIds,
                    isHotspotRevealed: _isHotspotRevealed,
                  ),
                  size: Size.infinite,
                ),
                if (_messageText != null) _buildMessageOverlay(),
                if (_showDialogue) _buildDialogueBox(),
                HudWidget(
                  onInventoryTap: _toggleInventory,
                  onBackTap: () => _showQuitDialog(),
                  selectedItemId: _selectedItemId,
                ),
                if (_isInventoryOpen)
                  InventoryWidget(
                    isOpen: _isInventoryOpen,
                    onClose: _toggleInventory,
                    onItemSelected: _onItemSelected,
                    onItemTap: _showItemDetail,
                    selectedItemId: _selectedItemId,
                  ),
                if (_showJumpscare)
                  JumpscareWidget(intensity: _jumpscareIntensity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageOverlay() {
    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xDD0a0a0a),
          border: Border.all(color: const Color(0xFF4a0000)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _messageText!,
          style: const TextStyle(
            color: Color(0xFFD3D3D3),
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDialogueBox() {
    final dialogue = _currentDialogue[_dialogueIndex];
    final isNarrator = dialogue.speaker == '旁白' || dialogue.speaker == '???' ||
                       dialogue.emotion == 'sfx' || dialogue.emotion == 'whisper';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: _advanceDialogue,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xF00a0505)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isNarrator)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B0000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    dialogue.speaker,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                dialogue.text,
                style: TextStyle(
                  color: isNarrator ? const Color(0xFFAAAAAA) : Colors.white,
                  fontSize: 18,
                  height: 1.6,
                  fontStyle: isNarrator ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Color(0x88FFFFFF),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a0a),
        title: const Text('返回主菜单？', style: TextStyle(color: Color(0xFF8B0000))),
        content: const Text('进度将自动保存。', style: TextStyle(color: Color(0xFFD3D3D3))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final player = Provider.of<Player>(context, listen: false);
              player.saveGame();
              final audioService = Provider.of<AudioService>(context, listen: false);
              audioService.stopBgm();
              audioService.stopSfx();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChapterSelectScreen()),
              );
            },
            child: const Text('确定', style: TextStyle(color: Color(0xFF8B0000))),
          ),
        ],
      ),
    );
  }
}
