import 'item.dart';

enum PuzzleType {
  gyroscope,
  light,
  sequence,
  combination,
  reflection,
  sound,
  none,
}

class Hotspot {
  final String id;
  final double x;
  final double y;
  final double width;
  final double height;
  final String description;
  final String? itemToFind;
  final String? dialogue;
  final String? jumpscareId;
  final double dangerChance;
  final String? requiredItem;
  final String? targetScene;
  final PuzzleType? puzzleType;
  final bool isExamine;

  const Hotspot({
    required this.id,
    required this.x,
    required this.y,
    this.width = 100,
    this.height = 100,
    this.description = '',
    this.itemToFind,
    this.dialogue,
    this.jumpscareId,
    this.dangerChance = 0.0,
    this.requiredItem,
    this.targetScene,
    this.puzzleType,
    this.isExamine = true,
  });
}

class Scene {
  final String id;
  final String name;
  final String description;
  final String backgroundImage;
  final List<Hotspot> hotspots;
  final String? bgm;
  final String? ambientSound;
  final double dangerLevel;
  final bool isDark;
  final bool hasLight;
  final String? entryDialogue;
  final List<String> availableItems;

  const Scene({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundImage,
    this.hotspots = const [],
    this.bgm,
    this.ambientSound,
    this.dangerLevel = 0.3,
    this.isDark = false,
    this.hasLight = false,
    this.entryDialogue,
    this.availableItems = const [],
  });

  static List<Scene> get allScenes => [
        Scene(
          id: 'main_gate',
          name: '老宅大门',
          description: '荒废多年的聂家老宅，大门上贴着褪色的红纸...',
          backgroundImage: 'assets/images/scenes/main_gate.png',
          bgm: 'main_theme.mp3',
          ambientSound: 'wind_howl.mp3',
          dangerLevel: 0.2,
          entryDialogue: '红纸伞...我终于找到这里了...',
          hotspots: [
            Hotspot(
              id: 'gate_door',
              x: 0.4,
              y: 0.3,
              width: 200,
              height: 300,
              description: '虚掩的大门，发出吱呀的响声...',
              targetScene: 'courtyard',
              dangerChance: 0.1,
              dialogue: '门...自己开了？',
            ),
            Hotspot(
              id: 'gate_couplet',
              x: 0.2,
              y: 0.1,
              width: 80,
              height: 200,
              description: '褪色的对联，字迹已经模糊不清...',
            ),
            Hotspot(
              id: 'gate_stone_lion',
              x: 0.1,
              y: 0.5,
              width: 100,
              height: 150,
              description: '石狮子的眼睛...好像在动？',
              jumpscareId: 'shadow',
              dangerChance: 0.3,
            ),
          ],
          availableItems: ['old_note'],
        ),
        Scene(
          id: 'courtyard',
          name: '天井',
          description: '老宅的天井，地上散落着纸钱...',
          backgroundImage: 'assets/images/scenes/courtyard.png',
          bgm: 'courtyard.mp3',
          ambientSound: 'drip.mp3',
          dangerLevel: 0.4,
          entryDialogue: '好冷...这里明明是夏天...',
          hotspots: [
            Hotspot(
              id: 'well',
              x: 0.5,
              y: 0.6,
              width: 120,
              height: 120,
              description: '枯井，井里传来奇怪的声音...',
              dangerChance: 0.5,
              jumpscareId: 'ghost',
              itemToFind: 'jade_pendant',
            ),
            Hotspot(
              id: 'main_hall_door',
              x: 0.35,
              y: 0.2,
              width: 250,
              height: 250,
              description: '正厅的门，挂着白色的灯笼...',
              targetScene: 'main_hall',
            ),
            Hotspot(
              id: 'east_wing_door',
              x: 0.05,
              y: 0.4,
              width: 100,
              height: 200,
              description: '东厢房的门...',
              targetScene: 'east_wing',
            ),
            Hotspot(
              id: 'west_wing_door',
              x: 0.8,
              y: 0.4,
              width: 100,
              height: 200,
              description: '西厢房的门...',
              targetScene: 'west_wing',
            ),
          ],
          availableItems: ['paper_money', 'candle', 'matches'],
        ),
        Scene(
          id: 'main_hall',
          name: '正厅',
          description: '灵堂，中央摆放着一口棺材...',
          backgroundImage: 'assets/images/scenes/main_hall.png',
          bgm: 'funeral.mp3',
          ambientSound: 'crying.mp3',
          dangerLevel: 0.6,
          isDark: true,
          entryDialogue: '这是...灵堂？',
          hotspots: [
            Hotspot(
              id: 'coffin',
              x: 0.35,
              y: 0.5,
              width: 300,
              height: 200,
              description: '棺材...盖子好像没钉紧...',
              dangerChance: 0.7,
              jumpscareId: 'zombie',
              requiredItem: 'bronze_key',
              itemToFind: 'red_umbrella',
            ),
            Hotspot(
              id: 'altar',
              x: 0.4,
              y: 0.15,
              width: 200,
              height: 150,
              description: '供桌，上面摆着牌位和遗像...',
              itemToFind: 'spirit_tablet',
              dialogue: '遗像上的人...怎么这么眼熟？',
            ),
            Hotspot(
              id: 'paper_servants',
              x: 0.1,
              y: 0.3,
              width: 80,
              height: 200,
              description: '纸扎人排列在两边...它们的脸...',
              jumpscareId: 'paper',
              dangerChance: 0.4,
            ),
          ],
          availableItems: ['incense', 'photograph', 'bronze_key'],
        ),
        Scene(
          id: 'east_wing',
          name: '新娘房',
          description: '布置成喜房的样子，红色的嫁衣还挂在衣架上...',
          backgroundImage: 'assets/images/scenes/east_wing.png',
          bgm: 'bridal_chamber.mp3',
          ambientSound: 'wedding_music.mp3',
          dangerLevel: 0.8,
          entryDialogue: '这是...新娘的房间？',
          hotspots: [
            Hotspot(
              id: 'bridal_bed',
              x: 0.5,
              y: 0.5,
              width: 250,
              height: 200,
              description: '婚床，帐子里好像躺着人...',
              jumpscareId: 'bride',
              dangerChance: 0.8,
              dialogue: '帐子...在动？',
            ),
            Hotspot(
              id: 'dresser',
              x: 0.1,
              y: 0.3,
              width: 150,
              height: 180,
              description: '梳妆台，镜子上蒙着布...',
              requiredItem: 'lit_candle',
              itemToFind: 'mirror_shard',
            ),
            Hotspot(
              id: 'wardrobe',
              x: 0.75,
              y: 0.2,
              width: 120,
              height: 250,
              description: '衣柜...里面有声音？',
              dangerChance: 0.5,
              puzzleType: PuzzleType.gyroscope,
              targetScene: 'secret_room',
            ),
          ],
          availableItems: ['red_string', 'herb_medicine', 'wooden_doll'],
        ),
        Scene(
          id: 'west_wing',
          name: '书房',
          description: '积满灰尘的书房，书架上的书散落一地...',
          backgroundImage: 'assets/images/scenes/west_wing.png',
          bgm: 'study.mp3',
          ambientSound: 'page_flip.mp3',
          dangerLevel: 0.5,
          entryDialogue: '这里是书房...',
          hotspots: [
            Hotspot(
              id: 'desk',
              x: 0.3,
              y: 0.5,
              width: 250,
              height: 150,
              description: '书桌，上面放着一本日记...',
              itemToFind: 'old_note',
            ),
            Hotspot(
              id: 'bookshelf',
              x: 0.05,
              y: 0.1,
              width: 200,
              height: 350,
              description: '书架...有本书好像在动？',
              puzzleType: PuzzleType.sequence,
            ),
            Hotspot(
              id: 'window',
              x: 0.6,
              y: 0.2,
              width: 200,
              height: 200,
              description: '窗户...外面有人影？',
              jumpscareId: 'child',
              dangerChance: 0.3,
            ),
          ],
        ),
        Scene(
          id: 'secret_room',
          name: '密室',
          description: '衣柜后面的密室，墙上贴着符纸...',
          backgroundImage: 'assets/images/scenes/secret_room.png',
          bgm: 'secret.mp3',
          ambientSound: 'heartbeat.mp3',
          dangerLevel: 0.95,
          isDark: true,
          entryDialogue: '这里...是什么地方？',
          hotspots: [
            Hotspot(
              id: 'altar_secret',
              x: 0.4,
              y: 0.3,
              width: 200,
              height: 200,
              description: '法坛...上面放着红纸伞？',
              requiredItem: 'jade_pendant',
              itemToFind: 'red_umbrella',
              isExamine: false,
            ),
            Hotspot(
              id: 'corner_shadow',
              x: 0.0,
              y: 0.5,
              width: 100,
              height: 200,
              description: '角落...有什么东西？',
              jumpscareId: 'shadow',
              dangerChance: 0.9,
            ),
          ],
        ),
      ];

  static Scene? getById(String id) {
    try {
      return allScenes.firstWhere((scene) => scene.id == id);
    } catch (_) {
      return null;
    }
  }
}
