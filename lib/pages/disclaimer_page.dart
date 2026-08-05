import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/horror_theme.dart';
import '../widgets/horror_painter.dart';
import '../models/game_state.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import 'game_page.dart';

class DisclaimerPage extends StatefulWidget {
  const DisclaimerPage({super.key});

  @override
  State<DisclaimerPage> createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends State<DisclaimerPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _storageService = StorageService();
  final _audioService = AudioService();
  bool _agreed = false;
  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _playWarningSound();
  }

  Future<void> _playWarningSound() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      _audioService.playSfx('warning.mp3');
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAgree() {
    if (!_agreed) {
      setState(() => _showWarning = true);
      try {
        _audioService.playSfx('error.mp3');
      } catch (_) {}
      return;
    }

    _storageService.setDisclaimerAccepted(true);
    _storageService.setFirstPlay(false);

    final gameState = context.read<GameState>();
    gameState.startNewGame();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GamePage()),
    );
  }

  void _onDisagree() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HorrorBackground(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        color: HorrorTheme.deepBlack.withOpacity(0.9),
                        border: Border.all(color: HorrorTheme.bloodRed, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: HorrorTheme.bloodRed.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: HorrorTheme.bloodRed,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  '⚠️ 健康与安全警告',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildWarningSection(
                                  '恐怖内容警告',
                                  '本游戏包含极度恐怖的画面、音效和突脸惊吓（Jumpscare）元素，可能会引起不适。',
                                ),
                                const SizedBox(height: 16),
                                _buildWarningSection(
                                  '健康风险警告',
                                  '如有以下情况，请勿游玩本游戏：\n• 心脏病、高血压患者\n• 孕妇\n• 癫痫病患者\n• 心理疾病患者\n• 16岁以下未成年人\n• 对恐怖内容敏感者',
                                ),
                                const SizedBox(height: 16),
                                _buildWarningSection(
                                  '游玩建议',
                                  '• 请勿在深夜独自游玩\n• 请保持适当亮度的环境光线\n• 如感不适请立即停止\n• 建议佩戴耳机以获得最佳体验\n• 请合理安排游戏时间',
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: HorrorTheme.bloodRed.withOpacity(0.1),
                                    border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _agreed,
                                        onChanged: (v) {
                                          setState(() => _agreed = v ?? false);
                                        },
                                        activeColor: HorrorTheme.bloodRed,
                                        checkColor: Colors.white,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(() => _agreed = !_agreed),
                                          child: const Text(
                                            '我已阅读并理解以上警告内容，确认自身健康状况适合游玩本游戏，自愿承担所有风险。',
                                            style: TextStyle(
                                              color: HorrorTheme.ghostWhite,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_showWarning) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: HorrorTheme.bloodRed.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.error_outline, color: HorrorTheme.bloodRed, size: 20),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '请先勾选确认框以继续',
                                            style: TextStyle(color: HorrorTheme.bloodRed, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _DisclaimerButton(
                                        text: '退出',
                                        onPressed: _onDisagree,
                                        isPrimary: false,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _DisclaimerButton(
                                        text: '开始游戏',
                                        onPressed: _onAgree,
                                        isPrimary: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWarningSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: HorrorTheme.bloodRed,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: HorrorTheme.paleSkin,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _DisclaimerButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _DisclaimerButton({
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_DisclaimerButton> createState() => _DisclaimerButtonState();
}

class _DisclaimerButtonState extends State<_DisclaimerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.isPrimary
              ? (_pressed ? HorrorTheme.darkRed : HorrorTheme.bloodRed)
              : Colors.transparent,
          border: Border.all(
            color: widget.isPrimary ? HorrorTheme.bloodRed : HorrorTheme.bloodRed.withOpacity(0.5),
            width: widget.isPrimary ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: widget.isPrimary && !_pressed
              ? [
                  BoxShadow(
                    color: HorrorTheme.bloodRed.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.isPrimary ? Colors.white : HorrorTheme.bloodRed,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
