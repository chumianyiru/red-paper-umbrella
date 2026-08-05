import 'package:flutter/material.dart';
import '../models/scene.dart';
import '../models/hotspot.dart';

class Chapter1Scenes {
  static List<Scene> getScenes() {
    return [
      _villageEntrance(),
      _ancientWell(),
      _abandonedHouse(),
      _weddingHall(),
      _secretRoom(),
    ];
  }

  static Scene _villageEntrance() {
    return Scene(
      id: 'ch1_entrance',
      chapterId: 1,
      backgroundPath: 'assets/images/chapter1/village_entrance.png',
      description: '古老的村庄入口，雾气弥漫。红纸伞静静地靠在石牌坊旁，仿佛在等待着什么...',
      ambientSound: 'wind_howling',
      hotspots: [
        Hotspot(
          id: 'red_umbrella',
          name: '红纸伞',
          description: '一把破旧的红纸伞，伞面上画着诡异的新娘图案。',
          position: const RelativeRect.fromLTRB(0.35, 0.2, 0.55, 0.6),
          itemId: 'red_umbrella',
          type: HotspotType.item,
          onPickupMessage: '你拾起了红纸伞。伞骨冰凉，仿佛握着一只死人的手...',
          pickupJumpscare: false,
        ),
        Hotspot(
          id: 'stone_tablet',
          name: '石碑',
          description: '石碑上刻着模糊的文字："民国二十三年，全村嫁娶之日，天降红雨..."',
          position: const RelativeRect.fromLTRB(0.05, 0.3, 0.25, 0.7),
          type: HotspotType.examine,
          examineMessage: '石碑上的文字让你不寒而栗。你感到有什么东西在注视着你...',
        ),
        Hotspot(
          id: 'old_well_path',
          name: '古井方向',
          description: '通往古井的小路，传来诡异的滴水声。',
          position: const RelativeRect.fromLTRB(0.6, 0.4, 0.95, 0.9),
          type: HotspotType.navigation,
          targetSceneId: 'ch1_well',
        ),
        Hotspot(
          id: 'burnt_paper',
          name: '烧过的纸',
          description: '地上有一堆烧过的纸钱，还留着余温。',
          position: const RelativeRect.fromLTRB(0.2, 0.75, 0.35, 0.9),
          itemId: 'burnt_incense_paper',
          type: HotspotType.item,
          onPickupMessage: '你捡起了一张未烧尽的黄纸，上面写着"新娘"二字...',
        ),
      ],
      onEnter: () {
        // 开场旁白
      },
      onEnterDialogue: [
        DialogueLine(
          speaker: '林小雨（女主）',
          text: '阿明...你说过会回来找我的...为什么你会消失在这个村子里...',
          emotion: 'sad',
        ),
        DialogueLine(
          speaker: '???',
          text: '回来...回来...',
          emotion: 'whisper',
        ),
      ],
    );
  }

  static Scene _ancientWell() {
    return Scene(
      id: 'ch1_well',
      chapterId: 1,
      backgroundPath: 'assets/images/chapter1/ancient_well.png',
      description: '一口幽深的古井，井水泛着诡异的红光。井边放着一只红绣鞋。',
      ambientSound: 'water_drip',
      hotspots: [
        Hotspot(
          id: 'red_shoe',
          name: '红绣鞋',
          description: '一只精致的红绣鞋，鞋面上绣着鸳鸯，但其中一只鸳鸯的眼睛被挖掉了。',
          position: const RelativeRect.fromLTRB(0.4, 0.6, 0.55, 0.75),
          itemId: 'red_shoe_single',
          type: HotspotType.item,
          onPickupMessage: '你拿起红绣鞋，井里突然传来水花声，仿佛有什么东西在井底游动...',
          pickupJumpscare: true,
          jumpscareIntensity: 0.6,
        ),
        Hotspot(
          id: 'well_rope',
          name: '井绳',
          description: '井绳看起来很结实，但绳子上沾着暗红色的污渍。',
          position: const RelativeRect.fromLTRB(0.55, 0.2, 0.7, 0.6),
          type: HotspotType.examine,
          examineMessage: '绳子上的污渍看起来像是干涸的血迹...你不敢往下看。',
          requiredItem: 'red_umbrella',
          useItemMessage: '你用红纸伞勾住井绳，慢慢往上拉...拉上来一个湿漉漉的木盒！',
          grantsItem: 'wooden_box',
        ),
        Hotspot(
          id: 'return_entrance',
          name: '返回村口',
          description: '返回村庄入口。',
          position: const RelativeRect.fromLTRB(0.0, 0.7, 0.15, 0.95),
          type: HotspotType.navigation,
          targetSceneId: 'ch1_entrance',
        ),
        Hotspot(
          id: 'go_house',
          name: '废弃房屋',
          description: '井边有一座废弃的老宅，门虚掩着。',
          position: const RelativeRect.fromLTRB(0.15, 0.25, 0.4, 0.6),
          type: HotspotType.navigation,
          targetSceneId: 'ch1_house',
        ),
      ],
      onEnterDialogue: [
        DialogueLine(
          speaker: '林小雨',
          text: '这口井...为什么水是红色的？',
          emotion: 'nervous',
        ),
        DialogueLine(
          speaker: '井底',
          text: '滴答...滴答...咚...',
          emotion: 'sfx',
        ),
      ],
    );
  }

  static Scene _abandonedHouse() {
    return Scene(
      id: 'ch1_house',
      chapterId: 1,
      backgroundPath: 'assets/images/chapter1/abandoned_house.png',
      description: '废弃的老宅内部，布满蛛网。堂上挂着一幅新娘画像，眼睛似乎在跟着你动。',
      ambientSound: 'creaking_door',
      hotspots: [
        Hotspot(
          id: 'bride_portrait',
          name: '新娘画像',
          description: '一幅古老的新娘画像，画中人穿着鲜红的嫁衣，但脸被模糊了。',
          position: const RelativeRect.fromLTRB(0.35, 0.1, 0.65, 0.45),
          type: HotspotType.examine,
          examineMessage: '画像的新娘突然对你笑了！你揉了揉眼睛，发现只是错觉...',
          jumpscareOnExamine: true,
          jumpscareIntensity: 0.4,
        ),
        Hotspot(
          id: 'wooden_comb',
          name: '木梳',
          description: '梳妆台上放着一把红木梳，梳齿间缠着几根长发。',
          position: const RelativeRect.fromLTRB(0.15, 0.5, 0.3, 0.65),
          itemId: 'wooden_comb',
          type: HotspotType.item,
          onPickupMessage: '你拿起木梳，头发...还带着湿气？',
        ),
        Hotspot(
          id: 'locked_door',
          name: '上锁的门',
          description: '一扇被锁链锁住的门，门缝里透出红光。',
          position: const RelativeRect.fromLTRB(0.7, 0.3, 0.95, 0.8),
          type: HotspotType.puzzle,
          requiredItem: 'bronze_key',
          useItemMessage: '钥匙插入锁孔，门缓缓打开，里面是喜堂！',
          targetSceneId: 'ch1_wedding',
        ),
        Hotspot(
          id: 'bronze_mirror',
          name: '铜镜',
          description: '一面古老的铜镜，镜面蒙着灰尘。',
          position: const RelativeRect.fromLTRB(0.7, 0.5, 0.9, 0.7),
          type: HotspotType.examine,
          examineMessage: '你擦去铜镜上的灰尘...镜中的你背后站着一个红衣女人！',
          jumpscareOnExamine: true,
          jumpscareIntensity: 0.7,
        ),
        Hotspot(
          id: 'drawer',
          name: '抽屉',
          description: '梳妆台的抽屉，似乎可以拉开。',
          position: const RelativeRect.fromLTRB(0.1, 0.65, 0.35, 0.8),
          itemId: 'bronze_key',
          type: HotspotType.item,
          onPickupMessage: '你在抽屉里找到了一把青铜钥匙！',
          isHidden: true,
        ),
        Hotspot(
          id: 'return_well',
          name: '返回井边',
          description: '回到古井旁。',
          position: const RelativeRect.fromLTRB(0.0, 0.8, 0.1, 0.95),
          type: HotspotType.navigation,
          targetSceneId: 'ch1_well',
        ),
      ],
      onEnterDialogue: [
        DialogueLine(
          speaker: '林小雨',
          text: '这里...有人住过吗？怎么全是新娘的东西？',
          emotion: 'scared',
        ),
        DialogueLine(
          speaker: '梁上',
          text: '吱呀...',
          emotion: 'sfx',
        ),
      ],
    );
  }

  static Scene _weddingHall() {
    return Scene(
      id: 'ch1_wedding',
      chapterId: 1,
      backgroundPath: 'assets/images/chapter1/wedding_hall.png',
      description: '阴森的喜堂，大红喜字高高挂着，但到处都是灰尘。一对龙凤烛还在燃烧...',
      ambientSound: 'wedding_music_box',
      hotspots: [
        Hotspot(
          id: 'wedding_candles',
          name: '龙凤烛',
          description: '一对燃烧的龙凤烛，烛火是诡异的绿色。',
          position: const RelativeRect.fromLTRB(0.4, 0.35, 0.6, 0.55),
          type: HotspotType.examine,
          examineMessage: '烛火突然变成了血红色！你感到一阵眩晕...',
          decreasesSanity: 10,
        ),
        Hotspot(
          id: 'groom_tablet',
          name: '新郎牌位',
          description: '供桌上放着一个牌位，写着"先夫陈明之位"。',
          position: const RelativeRect.fromLTRB(0.2, 0.5, 0.4, 0.7),
          itemId: 'groom_tablet',
          type: HotspotType.item,
          onPickupMessage: '陈明...阿明？他的牌位怎么会在这里？！',
          pickupJumpscare: true,
          jumpscareIntensity: 0.8,
        ),
        Hotspot(
          id: 'secret_switch',
          name: '机关',
          description: '供桌下似乎有什么机关...',
          position: const RelativeRect.fromLTRB(0.45, 0.75, 0.55, 0.9),
          type: HotspotType.examine,
          examineMessage: '你按下了机关，墙壁缓缓移动，露出了一间密室！',
          targetSceneId: 'ch1_secret',
          isHidden: true,
          requiredItem: 'wooden_box',
          useItemMessage: '你把木盒放在供桌上，触发了机关...墙壁后是密室！',
        ),
        Hotspot(
          id: 'red_veil',
          name: '红盖头',
          description: '椅背上搭着一块红盖头。',
          position: const RelativeRect.fromLTRB(0.6, 0.55, 0.75, 0.7),
          itemId: 'red_veil',
          type: HotspotType.item,
          onPickupMessage: '你拿起红盖头，闻到了一股腐臭的味道...',
        ),
        Hotspot(
          id: 'return_house',
          name: '返回外屋',
          description: '回到废弃房屋外间。',
          position: const RelativeRect.fromLTRB(0.0, 0.8, 0.1, 0.95),
          type: HotspotType.navigation,
          targetSceneId: 'ch1_house',
        ),
      ],
      onEnterDialogue: [
        DialogueLine(
          speaker: '林小雨',
          text: '喜堂？为什么这里会有喜堂...而且牌位上写着阿明的名字...',
          emotion: 'terrified',
        ),
        DialogueLine(
          speaker: 'Ghost',
          text: '拜堂了...我们该拜堂了...',
          emotion: 'ghostly',
        ),
      ],
    );
  }

  static Scene _secretRoom() {
    return Scene(
      id: 'ch1_secret',
      chapterId: 1,
      backgroundPath: 'assets/images/chapter1/secret_room.png',
      description: '密室里放着一口棺材，棺材旁散落着阿明的物品。墙上写满了"不要娶她"。',
      ambientSound: 'heartbeat',
      hotspots: [
        Hotspot(
          id: 'coffin',
          name: '棺材',
          description: '一口鲜红的棺材，棺盖没有钉死。',
          position: const RelativeRect.fromLTRB(0.25, 0.3, 0.75, 0.7),
          type: HotspotType.examine,
          examineMessage: '你鼓起勇气推开棺盖...里面躺着的是穿着嫁衣的你自己！',
          jumpscareOnExamine: true,
          jumpscareIntensity: 1.0,
          chapterEndTrigger: true,
        ),
        Hotspot(
          id: 'ming_watch',
          name: '阿明的手表',
          description: '这是阿明的手表，是你送给他的定情信物！',
          position: const RelativeRect.fromLTRB(0.1, 0.7, 0.25, 0.85),
          itemId: 'ming_watch',
          type: HotspotType.item,
          onPickupMessage: '你找到了阿明的手表...他一定来过这里！',
        ),
        Hotspot(
          id: 'diary',
          name: '日记本',
          description: '一本泛黄的日记，封面上写着"陈婉君"。',
          position: const RelativeRect.fromLTRB(0.75, 0.65, 0.9, 0.8),
          itemId: 'diary_1923',
          type: HotspotType.item,
          onPickupMessage: '这是1923年的日记...那个新娘的日记？',
        ),
        Hotspot(
          id: 'return_wedding',
          name: '返回喜堂',
          description: '回到喜堂。',
          position: const RelativeRect.fromLTRB(0.0, 0.8, 0.1, 0.95),
          type: HotspotType.navigation,
          targetSceneId: 'ch1_wedding',
        ),
      ],
      onEnterDialogue: [
        DialogueLine(
          speaker: '林小雨',
          text: '这口棺材...为什么是红色的？墙上的字...是谁写的？',
          emotion: 'horror',
        ),
      ],
    );
  }
}
