import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/horror_theme.dart';
import '../widgets/horror_painter.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';

class AdPage extends StatefulWidget {
  const AdPage({super.key});

  @override
  State<AdPage> createState() => _AdPageState();
}

class _AdPageState extends State<AdPage> with TickerProviderStateMixin {
  final _adService = AdService();
  final _audioService = AudioService();
  final _random = Random();

  late AnimationController _adAnimController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  int _remainingSeconds = 30;
  bool _canSkip = false;
  bool _isAdPlaying = true;
  Timer? _timer;
  int _currentAdIndex = 0;
  final List<_AdContent> _ads = [];

  @override
  void initState() {
    super.initState();

    _adAnimController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _adAnimController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _adAnimController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _generateAds();
    _currentAdIndex = _random.nextInt(_ads.length);
    _adAnimController.forward();
    _startCountdown();
    _playAdSound();
  }

  void _generateAds() {
    _ads.addAll([
      _AdContent(
        title: '🎮 恐怖游戏推荐',
        subtitle: '《纸嫁衣》系列新作上线',
        description: '更多中式恐怖解谜等你来体验！\n立即下载，感受极致恐惧！',
        color: HorrorTheme.bloodRed,
        icon: Icons.castle,
      ),
      _AdContent(
        title: '🕯️ 午夜惊魂',
        subtitle: '深夜必玩恐怖游戏合集',
        description: '100款精选恐怖游戏\n胆子大的来挑战！',
        color: Colors.deepPurple,
        icon: Icons.nightlight_round,
      ),
      _AdContent(
        title: '👻 灵异事件簿',
        subtitle: '真实恐怖故事改编',
        description: '根据民间传说制作\n胆小勿入！',
        color: Colors.teal.shade700,
        icon: Icons.person_search,
      ),
      _AdContent(
        title: '🏚️ 废弃医院',
        subtitle: '第一人称恐怖冒险',
        description: 'VR级恐怖体验\n你能逃出升天吗？',
        color: Colors.indigo.shade700,
        icon: Icons.local_hospital,
      ),
    ]);
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _canSkip = true;
          timer.cancel();
        }
      });
    });
  }

  void _playAdSound() {
    try {
      _audioService.playBgm('ad_music.mp3');
    } catch (_) {}
  }

  void _skipAd() {
    if (!_canSkip) return;
    _timer?.cancel();
    try {
      _audioService.stopBgm();
    } catch (_) {}
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _adAnimController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ads[_currentAdIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: HorrorBackground(
        child: Stack(
          children: [
            _buildAdContent(ad),
            _buildTopBar(),
            if (_canSkip)
              _buildSkipButton(),
            _buildCountdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdContent(_AdContent ad) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ad.color.withOpacity(0.3),
                  HorrorTheme.deepBlack,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ad.color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: ad.color.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '广告',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ad.color,
                          boxShadow: [
                            BoxShadow(
                              color: ad.color.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          ad.icon,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  ad.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  ad.subtitle,
                  style: TextStyle(
                    color: ad.color,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  ad.description,
                  style: const TextStyle(
                    color: HorrorTheme.paleSkin,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  decoration: BoxDecoration(
                    color: ad.color,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: ad.color.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Text(
                    '立即下载',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '广告内容与游戏无关',
                  style: TextStyle(
                    color: HorrorTheme.paleSkin.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '广告播放中',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _canSkip ? Colors.green : HorrorTheme.bloodRed,
                  width: 2,
                ),
              ),
              child: _canSkip
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          '广告已结束',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            value: 1 - (_remainingSeconds / 30),
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(HorrorTheme.bloodRed),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_remainingSeconds}秒后可获取提示',
                          style: TextStyle(
                            color: _pulseAnimation.value > 1.05 ? HorrorTheme.bloodRed : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      bottom: 32,
      right: 32,
      child: GestureDetector(
        onTap: _skipAd,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.skip_next, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '获取提示',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdContent {
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final IconData icon;

  const _AdContent({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.icon,
  });
}
