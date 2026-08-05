import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/player.dart';
import '../models/scene.dart';
import 'game_screen.dart';

class ChapterSelectScreen extends StatefulWidget {
  const ChapterSelectScreen({super.key});

  @override
  State<ChapterSelectScreen> createState() => _ChapterSelectScreenState();
}

class _ChapterSelectScreenState extends State<ChapterSelectScreen> {
  final List<ChapterInfo> _chapters = [
    ChapterInfo(
      number: 1,
      title: '红纸伞',
      subtitle: '古镇入口',
      description: '为寻找失踪的姐姐，你来到了这个诡异的古镇...',
      isUnlocked: true,
      startScene: 'ch1_town_entrance',
      icon: Icons.umbrella,
    ),
    ChapterInfo(
      number: 2,
      title: '冥婚',
      subtitle: '林家祠堂',
      description: '祠堂里的红纸伞，究竟隐藏着什么秘密？',
      isUnlocked: false,
      startScene: 'ch2_entrance',
      icon: Icons.favorite,
    ),
    ChapterInfo(
      number: 3,
      title: '古井',
      subtitle: '井底深渊',
      description: '井底传来的声音，是姐姐在呼唤吗？',
      isUnlocked: false,
      startScene: 'ch3_well',
      icon: Icons.water,
    ),
    ChapterInfo(
      number: 4,
      title: '纸人',
      subtitle: '阴阳纸扎铺',
      description: '纸扎铺里的纸人，似乎在看着你...',
      isUnlocked: false,
      startScene: 'ch4_paper_shop',
      icon: Icons.person,
    ),
    ChapterInfo(
      number: 5,
      title: '戏台',
      subtitle: '夜半歌声',
      description: '空无一人的戏台上，是谁在唱戏？',
      isUnlocked: false,
      startScene: 'ch5_stage',
      icon: Icons.theater_comedy,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HorrorTheme.corpseBlack,
      appBar: AppBar(
        backgroundColor: HorrorTheme.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HorrorTheme.ghostWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '章节选择',
          style: TextStyle(
            color: HorrorTheme.ghostWhite,
            fontFamily: 'ChineseBrush',
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: HorrorTheme.bloodRed.withOpacity(0.5),
            height: 1,
          ),
        ),
      ),
      body: Consumer<Player>(
        builder: (context, player, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _chapters.length,
            itemBuilder: (context, index) {
              final chapter = _chapters[index];
              final isUnlocked = chapter.isUnlocked || player.currentChapter > chapter.number;
              return _buildChapterCard(chapter, isUnlocked, player);
            },
          );
        },
      ),
    );
  }

  Widget _buildChapterCard(ChapterInfo chapter, bool isUnlocked, Player player) {
    return GestureDetector(
      onTap: isUnlocked
          ? () => _startChapter(chapter)
          : () => _showLockedMessage(chapter),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isUnlocked ? HorrorTheme.shadowGray : HorrorTheme.inkBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isUnlocked ? HorrorTheme.bloodRed.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: HorrorTheme.bloodRed.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isUnlocked ? HorrorTheme.darkRed : Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUnlocked ? HorrorTheme.bloodRed : Colors.grey,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          chapter.icon,
                          color: isUnlocked ? HorrorTheme.paperYellow : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '第${chapter.number}章',
                          style: TextStyle(
                            color: isUnlocked ? HorrorTheme.ghostWhite : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: TextStyle(
                            color: isUnlocked ? HorrorTheme.ghostWhite : Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ChineseBrush',
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chapter.subtitle,
                          style: TextStyle(
                            color: isUnlocked ? HorrorTheme.paperYellow.withOpacity(0.8) : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chapter.description,
                          style: TextStyle(
                            color: isUnlocked ? HorrorTheme.ghostWhite.withOpacity(0.7) : Colors.grey[700],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isUnlocked ? Icons.play_circle_filled : Icons.lock,
                    color: isUnlocked ? HorrorTheme.bloodRed : Colors.grey,
                    size: 32,
                  ),
                ],
              ),
            ),
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startChapter(ChapterInfo chapter) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          startSceneId: chapter.startScene,
          startChapter: chapter.number,
        ),
      ),
    );
  }

  void _showLockedMessage(ChapterInfo chapter) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('请先完成第${chapter.number - 1}章解锁本章'),
        backgroundColor: HorrorTheme.darkRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ChapterInfo {
  final int number;
  final String title;
  final String subtitle;
  final String description;
  final bool isUnlocked;
  final String startScene;
  final IconData icon;

  const ChapterInfo({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isUnlocked,
    required this.startScene,
    required this.icon,
  });
}
