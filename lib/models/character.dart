enum CharacterType {
  bride,
  ghost,
  child,
  oldWoman,
  paperMan,
  zombie,
  bridegroom,
  unknown,
}

class CharacterSprite {
  final String id;
  final String imagePath;
  final String description;
  final bool isJumpscare;
  final String? soundEffect;
  final int duration;

  const CharacterSprite({
    required this.id,
    required this.imagePath,
    this.description = '',
    this.isJumpscare = false,
    this.soundEffect,
    this.duration = 0,
  });
}

class Character {
  final String id;
  final String name;
  final CharacterType type;
  final String description;
  final List<CharacterSprite> sprites;
  final String? bgm;
  final double dangerLevel;
  final bool isHostile;
  final String? encounterDialogue;
  final String? jumpscareSound;

  const Character({
    required this.id,
    required this.name,
    required this.type,
    this.description = '',
    this.sprites = const [],
    this.bgm,
    this.dangerLevel = 0.5,
    this.isHostile = false,
    this.encounterDialogue,
    this.jumpscareSound,
  });

  static List<Character> get allCharacters => [
        Character(
          id: 'hong_yi_bride',
          name: '红衣新娘',
          type: CharacterType.bride,
          description: '身着红色嫁衣的女子，手持红纸伞，徘徊在老宅中...',
          dangerLevel: 0.9,
          isHostile: true,
          encounterDialogue: '你...看见我的伞了吗？',
          jumpscareSound: 'jumpscare_bride.mp3',
          sprites: List.generate(10, (i) => CharacterSprite(
            id: 'bride_$i',
            imagePath: 'assets/images/characters/bride_$i.png',
            isJumpscare: i >= 7,
            soundEffect: i >= 7 ? 'jumpscare_bride.mp3' : null,
            duration: i >= 7 ? 1500 : 0,
          )),
        ),
        Character(
          id: 'white_ghost',
          name: '白衣女鬼',
          type: CharacterType.ghost,
          description: '飘荡在走廊尽头的白色身影，长发遮面...',
          dangerLevel: 0.8,
          isHostile: true,
          encounterDialogue: '还我命来...',
          jumpscareSound: 'jumpscare_ghost.mp3',
          sprites: List.generate(10, (i) => CharacterSprite(
            id: 'ghost_$i',
            imagePath: 'assets/images/characters/ghost_$i.png',
            isJumpscare: i >= 6,
            soundEffect: i >= 6 ? 'jumpscare_ghost.mp3' : null,
            duration: i >= 6 ? 2000 : 0,
          )),
        ),
        Character(
          id: 'ghost_child',
          name: '童魂',
          type: CharacterType.child,
          description: '角落里传来孩童的笑声，却看不见人影...',
          dangerLevel: 0.7,
          isHostile: false,
          encounterDialogue: '姐姐/哥哥，陪我玩捉迷藏吧...',
          jumpscareSound: 'jumpscare_child.mp3',
          sprites: List.generate(10, (i) => CharacterSprite(
            id: 'child_$i',
            imagePath: 'assets/images/characters/child_$i.png',
            isJumpscare: i >= 8,
            soundEffect: i >= 8 ? 'jumpscare_child.mp3' : 'child_laugh.mp3',
            duration: i >= 8 ? 1200 : 0,
          )),
        ),
        Character(
          id: 'old_woman',
          name: '纸人婆婆',
          type: CharacterType.oldWoman,
          description: '坐在太师椅上的老婆婆，脸色惨白如纸...',
          dangerLevel: 0.85,
          isHostile: true,
          encounterDialogue: '年轻人...来陪老婆子说说话...',
          jumpscareSound: 'jumpscare_old.mp3',
          sprites: List.generate(10, (i) => CharacterSprite(
            id: 'old_$i',
            imagePath: 'assets/images/characters/old_$i.png',
            isJumpscare: i >= 5,
            soundEffect: i >= 5 ? 'jumpscare_old.mp3' : null,
            duration: i >= 5 ? 1800 : 0,
          )),
        ),
        Character(
          id: 'paper_servant',
          name: '纸扎人',
          type: CharacterType.paperMan,
          description: '灵堂里摆放的纸人，眼睛似乎在动...',
          dangerLevel: 0.75,
          isHostile: true,
          encounterDialogue: '...',
          jumpscareSound: 'jumpscare_paper.mp3',
          sprites: List.generate(10, (i) => CharacterSprite(
            id: 'paper_$i',
            imagePath: 'assets/images/characters/paper_$i.png',
            isJumpscare: i >= 6,
            soundEffect: i >= 6 ? 'jumpscare_paper.mp3' : 'paper_rustle.mp3',
            duration: i >= 6 ? 1000 : 0,
          )),
        ),
        Character(
          id: 'jiangshi',
          name: '僵尸',
          type: CharacterType.zombie,
          description: '穿着清朝官服的尸体，额头贴着黄符...',
          dangerLevel: 0.95,
          isHostile: true,
          encounterDialogue: '吼——',
          jumpscareSound: 'jumpscare_zombie.mp3',
          sprites: List.generate(10, (i) => CharacterSprite(
            id: 'zombie_$i',
            imagePath: 'assets/images/characters/zombie_$i.png',
            isJumpscare: i >= 7,
            soundEffect: i >= 7 ? 'jumpscare_zombie.mp3' : 'zombie_groan.mp3',
            duration: i >= 7 ? 2000 : 0,
          )),
        ),
        Character(
          id: 'dead_groom',
          name: '已故新郎',
          type: CharacterType.bridegroom,
          description: '新娘等待的那个人，早已不在人世...',
          dangerLevel: 0.6,
          isHostile: false,
          encounterDialogue: '快走...这里危险...',
          jumpscareSound: null,
          sprites: List.generate(10, (i) => CharacterSprite(
            id: 'groom_$i',
            imagePath: 'assets/images/characters/groom_$i.png',
            isJumpscare: false,
            soundEffect: null,
            duration: 0,
          )),
        ),
        Character(
          id: 'shadow',
          name: '不明黑影',
          type: CharacterType.unknown,
          description: '眼角余光瞥见的影子，回头却什么都没有...',
          dangerLevel: 1.0,
          isHostile: true,
          encounterDialogue: null,
          jumpscareSound: 'jumpscare_shadow.mp3',
          sprites: List.generate(10, (i) => CharacterSprite(
            id: 'shadow_$i',
            imagePath: 'assets/images/characters/shadow_$i.png',
            isJumpscare: i >= 4,
            soundEffect: i >= 4 ? 'jumpscare_shadow.mp3' : 'heartbeat.mp3',
            duration: i >= 4 ? 2500 : 0,
          )),
        ),
      ];
}
