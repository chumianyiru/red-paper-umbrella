# 红纸伞 - 游戏资源目录

本目录包含《红纸伞》恐怖游戏的所有游戏资源。

## 目录结构

```
assets/
├── images/
│   ├── characters/    # 角色贴图（8个角色，每个角色10张贴图）
│   ├── scenes/        # 场景背景图
│   ├── items/         # 物品图标
│   ├── ui/            # UI界面素材
│   └── jumpscares/    # 突脸惊吓图片/GIF
├── audio/
│   ├── bgm/           # 背景音乐
│   ├── sfx/           # 音效（脚步声、开门声、拾取物品等）
│   └── jumpscares/    # 突脸惊吓音效
├── video/             # 过场动画视频
└── raw/               # 其他原始资源
```

## 角色贴图命名规范

每个角色包含10张贴图，命名格式：
- `{character_id}_01.png` ~ `{character_id}_10.png`

角色ID列表：
- `red_bride` - 红衣新娘
- `white_ghost` - 白衣女鬼
- `child_ghost` - 童魂
- `paper_grandma` - 纸人婆婆
- `paper_figure` - 纸扎人
- `jiangshi` - 僵尸
- `groom` - 已故新郎
- `shadow` - 不明黑影

NPC贴图可无限添加，使用NPC名称作为前缀即可。

## 场景背景命名规范

- `main_gate.jpg` - 老宅大门
- `courtyard.jpg` - 天井
- `main_hall.jpg` - 正厅
- `bridal_room.jpg` - 新娘房
- `study.jpg` - 书房
- `secret_room.jpg` - 密室

## 音效文件命名规范

### BGM (背景音乐)
- `main_menu.mp3` - 主菜单BGM
- `main_gate_bgm.mp3` - 老宅大门BGM
- `courtyard_bgm.mp3` - 天井BGM
- 等等...

### SFX (音效)
- `door_open.mp3` - 开门声
- `footstep.mp3` - 脚步声
- `item_get.mp3` - 拾取物品声
- `whisper.mp3` - 低语声
- `heartbeat.mp3` - 心跳声
- 等等...

### Jumpscare (突脸音效)
- `jumpscare_01.mp3` ~ `jumpscare_10.mp3` - 突脸惊吓音效
- `scream_bride.mp3` - 新娘尖叫
- `scream_ghost.mp3` - 女鬼尖叫
- 等等...

## 物品图标命名规范

- `red_umbrella.png` - 红纸伞
- `bronze_key.png` - 铜钥匙
- `diary.png` - 泛黄的日记
- `white_candle.png` - 白蜡烛
- `matches.png` - 火柴
- `lit_candle.png` - 点燃的蜡烛
- `jade_pendant.png` - 玉佩
- `paper_money.png` - 纸钱
- `old_photo.png` - 老照片
- `herbs.png` - 草药
- `puppet.png` - 木偶
- `tablet.png` - 牌位
- `red_rope.png` - 红绳
- `mirror_shard.png` - 镜子碎片
- `incense.png` - 香

## 技术说明

- 图片格式：PNG（支持透明）、JPG、WEBP、GIF（动态图片）
- 音频格式：MP3、OGG、WAV
- 视频格式：MP4
- 建议分辨率：
  - 场景背景：1080x1920（竖屏）
  - 角色贴图：512x512 或 1024x1024
  - 物品图标：128x128 或 256x256
- 资源总数：设计支持1000-10000张图片资源

## 程序化生成

当前版本已集成程序化场景渲染和角色绘制功能（使用Flutter CustomPaint），即使没有真实图片资源，游戏也可以正常运行并展示恐怖氛围效果。添加真实资源后，游戏会优先加载真实素材。
