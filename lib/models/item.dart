enum ItemType {
  key,
  note,
  weapon,
  tool,
  clue,
  consumable,
  special,
}

class Item {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final ItemType type;
  final bool isUsable;
  final bool isImportant;
  final String? useDescription;
  final String? combineWith;
  final String? combineResult;
  final int? healAmount;
  final Map<String, dynamic>? properties;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    this.type = ItemType.clue,
    this.isUsable = false,
    this.isImportant = false,
    this.useDescription,
    this.combineWith,
    this.combineResult,
    this.healAmount,
    this.properties,
  });

  static List<Item> get allItems => [
        Item(
          id: 'red_umbrella',
          name: '红纸伞',
          description: '一把破旧的红色油纸伞，伞面沾染着暗褐色的污渍...',
          imagePath: 'assets/images/items/red_umbrella.png',
          type: ItemType.special,
          isUsable: true,
          isImportant: true,
          useDescription: '你撑起红纸伞，伞下似乎有什么东西在看着你...',
        ),
        Item(
          id: 'bronze_key',
          name: '铜钥匙',
          description: '一把锈迹斑斑的铜钥匙，上面刻着奇怪的符文...',
          imagePath: 'assets/images/items/bronze_key.png',
          type: ItemType.key,
          isUsable: true,
          isImportant: true,
          useDescription: '钥匙可以打开某扇锁着的门...',
        ),
        Item(
          id: 'old_note',
          name: '泛黄的日记',
          description: '一本破旧的日记，内页写满了扭曲的文字...',
          imagePath: 'assets/images/items/old_note.png',
          type: ItemType.clue,
          isUsable: true,
          isImportant: true,
          useDescription: '"...她穿着红色嫁衣，在等我回来...民国二十七年..."',
        ),
        Item(
          id: 'candle',
          name: '白蜡烛',
          description: '半截白蜡烛，还能燃烧一段时间...',
          imagePath: 'assets/images/items/candle.png',
          type: ItemType.tool,
          isUsable: true,
          properties: {'lightRadius': 3.0},
        ),
        Item(
          id: 'matches',
          name: '火柴',
          description: '一盒老旧的火柴，还剩几根...',
          imagePath: 'assets/images/items/matches.png',
          type: ItemType.tool,
          isUsable: true,
          combineWith: 'candle',
          combineResult: 'lit_candle',
        ),
        Item(
          id: 'lit_candle',
          name: '点燃的蜡烛',
          description: '燃烧的蜡烛，发出微弱的光芒...',
          imagePath: 'assets/images/items/lit_candle.png',
          type: ItemType.tool,
          isUsable: true,
          properties: {'lightRadius': 5.0, 'duration': 300},
        ),
        Item(
          id: 'jade_pendant',
          name: '玉佩',
          description: '一块温润的玉佩，上面雕刻着鸳鸯图案...',
          imagePath: 'assets/images/items/jade_pendant.png',
          type: ItemType.special,
          isUsable: true,
          isImportant: true,
          useDescription: '玉佩散发着淡淡的暖意，让你感觉稍微安心...',
          healAmount: 20,
        ),
        Item(
          id: 'paper_money',
          name: '纸钱',
          description: '一叠泛黄的纸钱，是给死人用的...',
          imagePath: 'assets/images/items/paper_money.png',
          type: ItemType.consumable,
          isUsable: true,
          useDescription: '你点燃纸钱，火焰呈现诡异的绿色...',
        ),
        Item(
          id: 'photograph',
          name: '老照片',
          description: '一张黑白老照片，照片里的人...没有脸？',
          imagePath: 'assets/images/items/photograph.png',
          type: ItemType.clue,
          isUsable: true,
          isImportant: true,
          useDescription: '照片背面写着："民国二十六年，新婚留影"',
        ),
        Item(
          id: 'herb_medicine',
          name: '草药',
          description: '不知名的草药，散发着奇怪的气味...',
          imagePath: 'assets/images/items/herb.png',
          type: ItemType.consumable,
          isUsable: true,
          healAmount: 30,
          useDescription: '你吃下草药，感觉精神恢复了一些...',
        ),
        Item(
          id: 'wooden_doll',
          name: '木偶',
          description: '一个简陋的木偶，脸上画着恐怖的笑容...',
          imagePath: 'assets/images/items/doll.png',
          type: ItemType.special,
          isUsable: true,
          useDescription: '木偶的眼睛似乎动了一下...',
        ),
        Item(
          id: 'spirit_tablet',
          name: '牌位',
          description: '一块写着名字的木牌，名字被血迹遮盖了...',
          imagePath: 'assets/images/items/tablet.png',
          type: ItemType.clue,
          isImportant: true,
        ),
        Item(
          id: 'red_string',
          name: '红绳',
          description: '一截鲜艳的红绳，像是新娘嫁衣上的...',
          imagePath: 'assets/images/items/red_string.png',
          type: ItemType.tool,
          isUsable: true,
          isImportant: true,
        ),
        Item(
          id: 'mirror_shard',
          name: '镜子碎片',
          description: '一块破碎的镜子，映出的影像有些扭曲...',
          imagePath: 'assets/images/items/mirror.png',
          type: ItemType.tool,
          isUsable: true,
          useDescription: '你看向碎片，镜中的你...在笑？',
        ),
        Item(
          id: 'incense',
          name: '香',
          description: '三根香，还未点燃...',
          imagePath: 'assets/images/items/incense.png',
          type: ItemType.tool,
          isUsable: true,
          useDescription: '点燃香后，烟雾形成奇怪的形状...',
        ),
      ];

  static Item? getById(String id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
