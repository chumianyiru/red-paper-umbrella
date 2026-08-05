enum CharacterType { protagonist, npc, ghost, enemy, ally }

class Character {
  final String id;
  final String name;
  final String description;
  final List<String> sprites;
  final CharacterType type;
  final List<String> dialogues;
  final List<String> jumpscareSounds;
  final List<String> jumpscareImages;
  final String? voiceActor;
  final bool isHostile;
  final int damageOnContact;
  final int sanityDamageOnSight;
  final Map<String, String>? customExpressions;

  const Character({
    required this.id,
    required this.name,
    required this.description,
    required this.sprites,
    required this.type,
    this.dialogues = const [],
    this.jumpscareSounds = const [],
    this.jumpscareImages = const [],
    this.voiceActor,
    this.isHostile = false,
    this.damageOnContact = 0,
    this.sanityDamageOnSight = 0,
    this.customExpressions,
  });
}

class CharacterManager {
  static final Map<String, Character> _characters = {};

  static void initialize() {
    _characters['protagonist'] = const Character(
      id: 'protagonist',
      name: '林晚卿',
      description: '本作女主角，为寻找失踪的姐姐来到古镇。',
      sprites: [
        'assets/images/characters/protagonist_01.png',
        'assets/images/characters/protagonist_02.png',
        'assets/images/characters/protagonist_03.png',
        'assets/images/characters/protagonist_04.png',
        'assets/images/characters/protagonist_05.png',
        'assets/images/characters/protagonist_06.png',
        'assets/images/characters/protagonist_07.png',
        'assets/images/characters/protagonist_08.png',
        'assets/images/characters/protagonist_09.png',
        'assets/images/characters/protagonist_10.png',
      ],
      type: CharacterType.protagonist,
    );

    _characters['ghost_bride'] = const Character(
      id: 'ghost_bride',
      name: '红衣新娘',
      description: '身着染血红嫁衣的女鬼，手持红纸伞。',
      sprites: [
        'assets/images/characters/ghost_bride_01.png',
        'assets/images/characters/ghost_bride_02.png',
        'assets/images/characters/ghost_bride_03.png',
        'assets/images/characters/ghost_bride_04.png',
        'assets/images/characters/ghost_bride_05.png',
        'assets/images/characters/ghost_bride_06.png',
        'assets/images/characters/ghost_bride_07.png',
        'assets/images/characters/ghost_bride_08.png',
        'assets/images/characters/ghost_bride_09.png',
        'assets/images/characters/ghost_bride_10.png',
      ],
      type: CharacterType.ghost,
      isHostile: true,
      damageOnContact: 30,
      sanityDamageOnSight: 25,
      jumpscareSounds: [
        'assets/audio/jumpscares/bride_scream_01.mp3',
        'assets/audio/jumpscares/bride_scream_02.mp3',
        'assets/audio/jumpscares/bride_scream_03.mp3',
      ],
      jumpscareImages: [
        'assets/images/jumpscares/bride_jump_01.png',
        'assets/images/jumpscares/bride_jump_02.png',
        'assets/images/jumpscares/bride_jump_03.png',
        'assets/images/jumpscares/bride_jump_04.png',
        'assets/images/jumpscares/bride_jump_05.png',
      ],
    );

    _characters['old_priest'] = const Character(
      id: 'old_priest',
      name: '老道',
      description: '镇上唯一的道士，知晓古镇的秘密。',
      sprites: [
        'assets/images/characters/old_priest_01.png',
        'assets/images/characters/old_priest_02.png',
        'assets/images/characters/old_priest_03.png',
        'assets/images/characters/old_priest_04.png',
        'assets/images/characters/old_priest_05.png',
        'assets/images/characters/old_priest_06.png',
        'assets/images/characters/old_priest_07.png',
        'assets/images/characters/old_priest_08.png',
        'assets/images/characters/old_priest_09.png',
        'assets/images/characters/old_priest_10.png',
      ],
      type: CharacterType.npc,
      dialogues: [
        '这古镇...不能待啊...',
        '红纸伞...是她回来了...',
        '你姐姐...可能已经不是活人了...',
      ],
    );

    _characters['paper_doll'] = const Character(
      id: 'paper_doll',
      name: '纸人童',
      description: '飘荡在古宅中的纸扎人，会突然活动。',
      sprites: [
        'assets/images/characters/paper_doll_01.png',
        'assets/images/characters/paper_doll_02.png',
        'assets/images/characters/paper_doll_03.png',
        'assets/images/characters/paper_doll_04.png',
        'assets/images/characters/paper_doll_05.png',
        'assets/images/characters/paper_doll_06.png',
        'assets/images/characters/paper_doll_07.png',
        'assets/images/characters/paper_doll_08.png',
        'assets/images/characters/paper_doll_09.png',
        'assets/images/characters/paper_doll_10.png',
      ],
      type: CharacterType.enemy,
      isHostile: true,
      damageOnContact: 15,
      sanityDamageOnSight: 15,
      jumpscareSounds: [
        'assets/audio/jumpscares/paper_rustle.mp3',
        'assets/audio/jumpscares/paper_doll_laugh.mp3',
      ],
      jumpscareImages: [
        'assets/images/jumpscares/paper_doll_jump_01.png',
        'assets/images/jumpscares/paper_doll_jump_02.png',
        'assets/images/jumpscares/paper_doll_jump_03.png',
      ],
    );

    _characters['water_ghost'] = const Character(
      id: 'water_ghost',
      name: '水鬼',
      description: '溺死在古井中的女鬼，湿漉漉的长发遮面。',
      sprites: [
        'assets/images/characters/water_ghost_01.png',
        'assets/images/characters/water_ghost_02.png',
        'assets/images/characters/water_ghost_03.png',
        'assets/images/characters/water_ghost_04.png',
        'assets/images/characters/water_ghost_05.png',
        'assets/images/characters/water_ghost_06.png',
        'assets/images/characters/water_ghost_07.png',
        'assets/images/characters/water_ghost_08.png',
        'assets/images/characters/water_ghost_09.png',
        'assets/images/characters/water_ghost_10.png',
      ],
      type: CharacterType.ghost,
      isHostile: true,
      damageOnContact: 25,
      sanityDamageOnSight: 20,
      jumpscareSounds: [
        'assets/audio/jumpscares/water_gurgle.mp3',
        'assets/audio/jumpscares/water_splash.mp3',
      ],
      jumpscareImages: [
        'assets/images/jumpscares/water_ghost_jump_01.png',
        'assets/images/jumpscares/water_ghost_jump_02.png',
      ],
    );

    _characters['child_ghost'] = const Character(
      id: 'child_ghost',
      name: '小鬼童',
      description: '穿着红肚兜的孩童鬼魂，笑声令人毛骨悚然。',
      sprites: [
        'assets/images/characters/child_ghost_01.png',
        'assets/images/characters/child_ghost_02.png',
        'assets/images/characters/child_ghost_03.png',
        'assets/images/characters/child_ghost_04.png',
        'assets/images/characters/child_ghost_05.png',
        'assets/images/characters/child_ghost_06.png',
        'assets/images/characters/child_ghost_07.png',
        'assets/images/characters/child_ghost_08.png',
        'assets/images/characters/child_ghost_09.png',
        'assets/images/characters/child_ghost_10.png',
      ],
      type: CharacterType.ghost,
      isHostile: true,
      damageOnContact: 10,
      sanityDamageOnSight: 18,
      jumpscareSounds: [
        'assets/audio/jumpscares/child_laugh_01.mp3',
        'assets/audio/jumpscares/child_laugh_02.mp3',
        'assets/audio/jumpscares/child_cry.mp3',
      ],
      jumpscareImages: [
        'assets/images/jumpscares/child_jump_01.png',
        'assets/images/jumpscares/child_jump_02.png',
        'assets/images/jumpscares/child_jump_03.png',
        'assets/images/jumpscares/child_jump_04.png',
      ],
    );

    _characters['sister'] = const Character(
      id: 'sister',
      name: '林晚晴',
      description: '主角的姐姐，在古镇失踪，似乎与红纸伞有着联系。',
      sprites: [
        'assets/images/characters/sister_01.png',
        'assets/images/characters/sister_02.png',
        'assets/images/characters/sister_03.png',
        'assets/images/characters/sister_04.png',
        'assets/images/characters/sister_05.png',
        'assets/images/characters/sister_06.png',
        'assets/images/characters/sister_07.png',
        'assets/images/characters/sister_08.png',
        'assets/images/characters/sister_09.png',
        'assets/images/characters/sister_10.png',
      ],
      type: CharacterType.ally,
      dialogues: [
        '晚卿...快逃...',
        '不要相信任何人...',
        '红纸伞...在祠堂...',
      ],
    );

    _characters['shadow_figure'] = const Character(
      id: 'shadow_figure',
      name: '黑影',
      description: '在角落中若隐若现的神秘黑影，身份不明。',
      sprites: [
        'assets/images/characters/shadow_01.png',
        'assets/images/characters/shadow_02.png',
        'assets/images/characters/shadow_03.png',
        'assets/images/characters/shadow_04.png',
        'assets/images/characters/shadow_05.png',
        'assets/images/characters/shadow_06.png',
        'assets/images/characters/shadow_07.png',
        'assets/images/characters/shadow_08.png',
        'assets/images/characters/shadow_09.png',
        'assets/images/characters/shadow_10.png',
      ],
      type: CharacterType.ghost,
      isHostile: false,
      sanityDamageOnSight: 10,
    );
  }

  static Character? getCharacter(String id) => _characters[id];
  static List<Character> getAllCharacters() => _characters.values.toList();
}
