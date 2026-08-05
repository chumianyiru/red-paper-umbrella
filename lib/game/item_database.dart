import '../models/item.dart';

class ItemDatabase {
  static final Map<String, Item> _items = {};
  static final Map<String, String> _combinations = {};

  static void initialize() {
    _addChapter1Items();
    _addCombinations();
  }

  static void _addChapter1Items() {
    _items['red_umbrella'] = const Item(
      id: 'red_umbrella',
      name: '红纸伞',
      description: '一把破旧的红纸伞，伞面上画着诡异的新娘图案。伞骨冰凉，仿佛握着死人的手。',
      iconPath: 'assets/images/items/red_umbrella.png',
      type: ItemType.key,
      canCombine: true,
      examineDetail: '伞面已经褪色，但红色依然鲜艳得像血。伞柄上刻着一个"婉"字。',
    );

    _items['burnt_incense_paper'] = const Item(
      id: 'burnt_incense_paper',
      name: '未烧尽的黄纸',
      description: '一张未烧尽的黄纸，上面隐约能看到"新娘"二字。',
      iconPath: 'assets/images/items/burnt_paper.png',
      type: ItemType.clue,
      canCombine: false,
      examineDetail: '纸张边缘发黑，但中间的字迹还能辨认。这是冥婚用的黄纸...',
    );

    _items['red_shoe_single'] = const Item(
      id: 'red_shoe_single',
      name: '红绣鞋（单只）',
      description: '一只精致的红绣鞋，鞋面上绣着鸳鸯，但其中一只鸳鸯的眼睛被挖掉了。',
      iconPath: 'assets/images/items/red_shoe.png',
      type: ItemType.clue,
      canCombine: true,
      examineDetail: '鞋是三寸金莲的大小，鞋内有暗红色的污渍...是血吗？',
    );

    _items['wooden_box'] = const Item(
      id: 'wooden_box',
      name: '湿木盒',
      description: '从井里捞上来的木盒，浑身湿透，上面刻着龙凤图案。',
      iconPath: 'assets/images/items/wooden_box.png',
      type: ItemType.container,
      canCombine: false,
      canOpen: true,
      examineDetail: '木盒被一把小铜锁锁着，锁上刻着"百年好合"。',
      containedItemId: 'jade_pendant',
    );

    _items['jade_pendant'] = const Item(
      id: 'jade_pendant',
      name: '鸳鸯玉佩',
      description: '木盒里的鸳鸯玉佩，晶莹剔透，但其中一半已经裂开了。',
      iconPath: 'assets/images/items/jade_pendant.png',
      type: ItemType.key,
      canCombine: true,
      examineDetail: '玉佩上刻着"陈明"和"陈婉君"两个名字...这是当年的定情信物？',
    );

    _items['wooden_comb'] = const Item(
      id: 'wooden_comb',
      name: '红木梳',
      description: '梳妆台上的红木梳，梳齿间缠着几根乌黑的长发。',
      iconPath: 'assets/images/items/wooden_comb.png',
      type: ItemType.clue,
      canCombine: true,
      examineDetail: '头发还带着湿气...这梳子不久前还有人用过？',
    );

    _items['bronze_key'] = const Item(
      id: 'bronze_key',
      name: '青铜钥匙',
      description: '一把古老的青铜钥匙，上面刻着喜字。',
      iconPath: 'assets/images/items/bronze_key.png',
      type: ItemType.key,
      canCombine: false,
      examineDetail: '钥匙已经生锈，但纹路依然清晰。这是开喜堂门的钥匙。',
    );

    _items['groom_tablet'] = const Item(
      id: 'groom_tablet',
      name: '新郎牌位',
      description: '供桌上的牌位，写着"先夫陈明之位"。阿明怎么会...',
      iconPath: 'assets/images/items/groom_tablet.png',
      type: ItemType.clue,
      canCombine: false,
      examineDetail: '牌位前还放着新鲜的供品...是谁在祭拜？',
    );

    _items['red_veil'] = const Item(
      id: 'red_veil',
      name: '红盖头',
      description: '椅背上搭着的红盖头，散发着腐臭的味道。',
      iconPath: 'assets/images/items/red_veil.png',
      type: ItemType.clue,
      canCombine: true,
      examineDetail: '盖头上绣着金色的龙凤，但部分已经发黑，像是沾上了什么东西...',
    );

    _items['ming_watch'] = const Item(
      id: 'ming_watch',
      name: '阿明的手表',
      description: '你送给阿明的定情信物！他一定来过这里！',
      iconPath: 'assets/images/items/ming_watch.png',
      type: ItemType.clue,
      canCombine: false,
      examineDetail: '手表停在了凌晨3点...那个时间发生了什么？',
    );

    _items['diary_1923'] = const Item(
      id: 'diary_1923',
      name: '婉君日记',
      description: '一本泛黄的日记，封面上写着"陈婉君"。',
      iconPath: 'assets/images/items/diary.png',
      type: ItemType.document,
      canCombine: false,
      canRead: true,
      examineDetail: '日记里写着1923年发生的事...那个新娘的故事？',
      documentContent: [
        '民国十二年，三月十五',
        '今天阿明哥说要娶我，我好高兴...',
        '可是爹说我们八字不合，陈家村不能和外姓人通婚。',
        '',
        '民国十二年，七月初七',
        '他们把我锁起来了，说要把我嫁给村里的神...',
        '阿明哥，救我...',
        '',
        '民国十二年，七月十五',
        '今天是鬼节，他们让我穿上嫁衣...',
        '阿明哥，如果你看到这本日记，',
        '记住，不要找我，不要打开那口棺材...',
        '她会变成你的...',
        '',
        '（最后一页字迹潦草，像是用血写的）',
        '她来了...红纸伞...红纸伞挡不住她...',
      ],
    );

    _items['candle'] = const Item(
      id: 'candle',
      name: '白蜡烛',
      description: '一支未点燃的白蜡烛。',
      iconPath: 'assets/images/items/candle.png',
      type: ItemType.tool,
      canCombine: true,
    );

    _items['matches'] = const Item(
      id: 'matches',
      name: '火柴',
      description: '一盒老旧的火柴，还能划着。',
      iconPath: 'assets/images/items/matches.png',
      type: ItemType.tool,
      canCombine: true,
    );

    _items['lit_candle'] = const Item(
      id: 'lit_candle',
      name: '点燃的蜡烛',
      description: '燃烧的白蜡烛，可以照亮黑暗的地方。',
      iconPath: 'assets/images/items/lit_candle.png',
      type: ItemType.tool,
      canCombine: false,
    );

    _items['red_shoes_pair'] = const Item(
      id: 'red_shoes_pair',
      name: '红绣鞋（一双）',
      description: '一双完整的红绣鞋，两只鸳鸯的眼睛都被挖掉了。',
      iconPath: 'assets/images/items/red_shoes_pair.png',
      type: ItemType.key,
      canCombine: false,
    );
  }

  static void _addCombinations() {
    _combinations['candle+matches'] = 'lit_candle';
    _combinations['matches+candle'] = 'lit_candle';
  }

  static Item? getItem(String id) => _items[id];
  
  static String? getCombinationResult(String item1Id, String item2Id) {
    final key1 = '$item1Id+$item2Id';
    final key2 = '$item2Id+$item1Id';
    return _combinations[key1] ?? _combinations[key2];
  }

  static List<Item> getAllItems() => _items.values.toList();
  
  static List<Item> getChapterItems(int chapter) {
    return _items.values.where((item) {
      if (chapter == 1) {
        return [
          'red_umbrella', 'burnt_incense_paper', 'red_shoe_single',
          'wooden_box', 'jade_pendant', 'wooden_comb', 'bronze_key',
          'groom_tablet', 'red_veil', 'ming_watch', 'diary_1923',
          'candle', 'matches', 'lit_candle', 'red_shoes_pair',
        ].contains(item.id);
      }
      return false;
    }).toList();
  }
}
