import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AdScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AdScreen({super.key, required this.onComplete});

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  int _countdown = 30;
  bool _canSkip = false;
  Timer? _timer;
  final Random _random = Random();
  
  final List<AdContent> _adContents = [
    AdContent(
      title: '深夜殡仪馆',
      description: '体验极致恐怖，更多惊悚剧情等你来解锁',
      color: HorrorTheme.darkRed,
      icon: Icons.dark_mode,
    ),
    AdContent(
      title: '灵异公寓',
      description: '你住的公寓里，真的只有你一个人吗？',
      color: const Color(0xFF1A237E),
      icon: Icons.apartment,
    ),
    AdContent(
      title: '古宅冤魂',
      description: '百年古宅，尘封的秘密即将揭晓',
      color: const Color(0xFF4A148C),
      icon: Icons.house,
    ),
    AdContent(
      title: '恐怖医院',
      description: '废弃医院的深夜，传来了手术台的声音...',
      color: const Color(0xFF004D40),
      icon: Icons.local_hospital,
    ),
    AdContent(
      title: '冥婚',
      description: '传统民俗恐怖，红嫁衣下的悲剧',
      color: HorrorTheme.bloodRed,
      icon: Icons.favorite,
    ),
  ];
  
  late AdContent _currentAd;

  @override
  void initState() {
    super.initState();
    _currentAd = _adContents[_random.nextInt(_adContents.length)];
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _countdown = 0;
          _canSkip = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _skipAd() {
    if (_canSkip) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: _buildAdContent(),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: _buildSkipButton(),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _buildAdLabel(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _currentAd.color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
              border: Border.all(color: HorrorTheme.paperYellow, width: 2),
            ),
            child: Icon(
              _currentAd.icon,
              size: 60,
              color: HorrorTheme.paperYellow,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            _currentAd.title,
            style: const TextStyle(
              color: HorrorTheme.ghostWhite,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'ChineseBrush',
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _currentAd.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: HorrorTheme.ghostWhite.withOpacity(0.9),
                fontSize: 20,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              color: HorrorTheme.candleOrange,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: HorrorTheme.candleOrange.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Text(
              '立即下载',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: _skipAd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _canSkip ? HorrorTheme.bloodRed : Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _canSkip ? HorrorTheme.bloodRed : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _canSkip ? '跳过' : '跳过 ${_countdown}s',
              style: TextStyle(
                color: _canSkip ? Colors.white : Colors.white54,
                fontSize: 14,
              ),
            ),
            if (_canSkip) ...[
              const SizedBox(width: 4),
              const Icon(Icons.skip_next, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdLabel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          '广告',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class AdContent {
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  const AdContent({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });
}
