import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/horror_theme.dart';
import '../widgets/horror_painter.dart';
import '../models/game_state.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'disclaimer_page.dart';
import 'game_page.dart';
import 'settings_page.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleFade;
  late Animation<double> _buttonSlide;
  final _audioService = AudioService();
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _buttonSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _playMenuBgm();
  }

  Future<void> _playMenuBgm() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      _audioService.playBgm('main_menu.mp3');
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startNewGame() {
    final gameState = context.read<GameState>();

    if (_storageService.isFirstPlay || !_storageService.isDisclaimerAccepted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const DisclaimerPage()),
      );
    } else {
      gameState.startNewGame();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GamePage()),
      );
    }
  }

  void _continueGame() {
    final saveData = _storageService.loadGame();
    if (saveData != null) {
      final gameState = context.read<GameState>();
      gameState.startNewGame();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GamePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('没有找到存档'),
          backgroundColor: HorrorTheme.darkRed,
        ),
      );
    }
  }

  void _showSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _showCredits() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HorrorTheme.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: HorrorTheme.bloodRed, width: 2),
        ),
        title: const Text('关于游戏', style: TextStyle(color: HorrorTheme.bloodRed)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('《红纸伞》', style: TextStyle(color: HorrorTheme.ghostWhite, fontSize: 18)),
            SizedBox(height: 12),
            Text('纸嫁衣风格2D恐怖解谜游戏', style: TextStyle(color: HorrorTheme.paleSkin)),
            SizedBox(height: 8),
            Text('⚠️ 警告：本游戏包含恐怖内容、突脸惊吓，心脏病、高血压患者及未成年人请勿游玩。',
                style: TextStyle(color: HorrorTheme.bloodRed, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定', style: TextStyle(color: HorrorTheme.bloodRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HorrorBackground(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Opacity(
                    opacity: _titleFade.value,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [HorrorTheme.bloodRed, HorrorTheme.darkRed, HorrorTheme.bloodRed],
                            stops: [0, 0.5, 1],
                          ).createShader(bounds),
                          child: const Text(
                            '红纸伞',
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 20,
                              fontFamily: 'MaShanZheng',
                              shadows: [
                                Shadow(
                                  color: HorrorTheme.bloodRed,
                                  blurRadius: 30,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'RED PAPER UMBRELLA',
                          style: TextStyle(
                            color: HorrorTheme.ghostWhite.withOpacity(0.6),
                            fontSize: 14,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 100,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, HorrorTheme.bloodRed, Colors.transparent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: HorrorTheme.bloodRed.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  Transform.translate(
                    offset: Offset(0, _buttonSlide.value),
                    child: Opacity(
                      opacity: _titleFade.value,
                      child: Column(
                        children: [
                          _HorrorButton(
                            text: '开始游戏',
                            onPressed: _startNewGame,
                            isPrimary: true,
                          ),
                          const SizedBox(height: 16),
                          _HorrorButton(
                            text: '继续游戏',
                            onPressed: _continueGame,
                          ),
                          const SizedBox(height: 16),
                          _HorrorButton(
                            text: '游戏设置',
                            onPressed: _showSettings,
                          ),
                          const SizedBox(height: 16),
                          _HorrorButton(
                            text: '关于游戏',
                            onPressed: _showCredits,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  Opacity(
                    opacity: _titleFade.value * 0.5,
                    child: const Text(
                      '⚠️ 游戏包含恐怖内容，请谨慎游玩',
                      style: TextStyle(
                        color: HorrorTheme.bloodRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HorrorButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _HorrorButton({
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_HorrorButton> createState() => _HorrorButtonState();
}

class _HorrorButtonState extends State<_HorrorButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hovered = true),
        onTapUp: (_) {
          setState(() => _hovered = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 220,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _hovered
                ? (widget.isPrimary ? HorrorTheme.bloodRed : HorrorTheme.darkRed)
                : Colors.transparent,
            border: Border.all(
              color: widget.isPrimary ? HorrorTheme.bloodRed : HorrorTheme.bloodRed.withOpacity(0.5),
              width: widget.isPrimary ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: HorrorTheme.bloodRed.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: _hovered ? HorrorTheme.ghostWhite : HorrorTheme.bloodRed,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
