import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
import '../services/audio_service.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'chapter_select_screen.dart';
import '../widgets/disclaimer_dialog.dart';
import '../models/player.dart';
import 'package:provider/provider.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _fogController;
  late Animation<double> _titleAnimation;
  late Animation<double> _fogAnimation;
  final AudioService _audioService = AudioService();
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _titleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fogController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );
    _fogAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fogController);

    _titleController.forward();
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showButtons = true;
        });
        _audioService.playBgm('assets/audio/bgm/main_menu.mp3');
        _checkFirstRun();
      }
    });
  }

  void _checkFirstRun() {
    final player = Provider.of<Player>(context, listen: false);
    if (!player.hasAcceptedDisclaimer) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const DisclaimerDialog(),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fogController.dispose();
    super.dispose();
  }

  void _startNewGame() {
    _audioService.playSfx('door_open');
    final player = Provider.of<Player>(context, listen: false);
    player.reset();
    player.setChapter(1);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(chapterId: 1),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _continueGame() {
    _audioService.playSfx('door_open');
    final player = Provider.of<Player>(context, listen: false);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GameScreen(chapterId: player.currentChapter),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _openChapterSelect() {
    _audioService.playSfx('paper_flip');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ChapterSelectScreen()),
    );
  }

  void _openSettings() {
    _audioService.playSfx('paper_flip');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: HorrorTheme.corpseBlack,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _fogAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _FogPainter(_fogAnimation.value),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/backgrounds/main_menu_bg.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              HorrorTheme.darkRed,
                              HorrorTheme.corpseBlack,
                              HorrorTheme.inkBlack,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.3),
                      radius: 1.5,
                      colors: [
                        Colors.transparent,
                        HorrorTheme.corpseBlack.withOpacity(0.7),
                        HorrorTheme.corpseBlack,
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        FadeTransition(
                          opacity: _titleAnimation,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    HorrorTheme.bloodRed,
                                    HorrorTheme.candleOrange,
                                    HorrorTheme.bloodRed,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  '红纸伞',
                                  style: TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 20,
                                    fontFamily: 'ChineseBrush',
                                    shadows: [
                                      Shadow(
                                        color: HorrorTheme.bloodRed,
                                        offset: Offset(0, 0),
                                        blurRadius: 30,
                                      ),
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(4, 4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'RED PAPER UMBRELLA',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: HorrorTheme.paperYellow.withOpacity(0.8),
                                  letterSpacing: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                        AnimatedOpacity(
                          opacity: _showButtons ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 1000),
                          child: Column(
                            children: [
                              _buildMenuButton(
                                '开始游戏',
                                onTap: _startNewGame,
                              ),
                              const SizedBox(height: 20),
                              _buildMenuButton(
                                '继续游戏',
                                onTap: _continueGame,
                              ),
                              const SizedBox(height: 20),
                              _buildMenuButton(
                                '章节选择',
                                onTap: _openChapterSelect,
                              ),
                              const SizedBox(height: 20),
                              _buildMenuButton(
                                '游戏设置',
                                onTap: _openSettings,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Text(
                            '佩戴耳机体验更佳\n胆小者与心脏病患者请勿游玩',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: HorrorTheme.ghostWhite.withOpacity(0.5),
                              fontSize: 12,
                              height: 1.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 30,
                  child: IconButton(
                    icon: Icon(
                      Icons.warning_amber_rounded,
                      color: HorrorTheme.bloodRed.withOpacity(0.7),
                      size: 28,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const DisclaimerDialog(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: HorrorTheme.bloodRed.withOpacity(0.6),
            width: 1,
          ),
          color: HorrorTheme.inkBlack.withOpacity(0.6),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 22,
              color: HorrorTheme.ghostWhite,
              letterSpacing: 8,
              fontFamily: 'ChineseBrush',
            ),
          ),
        ),
      ),
    );
  }
}

class _FogPainter extends CustomPainter {
  final double animation;

  _FogPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HorrorTheme.ghostWhite.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final offset = (animation + i * 0.2) % 1.0;
      final x = offset * size.width * 2 - size.width * 0.5;
      final y = size.height * (0.3 + i * 0.15);
      canvas.drawCircle(
        Offset(x, y),
        size.width * 0.4,
        paint..color = HorrorTheme.ghostWhite.withOpacity(0.02 + i * 0.005),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FogPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
