import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../utils/theme.dart';
import '../services/audio_service.dart';
import '../models/character.dart';

class JumpscareWidget extends StatefulWidget {
  final String jumpscareId;
  final List<String> images;
  final List<String> sounds;
  final int sanityDamage;
  final int healthDamage;
  final VoidCallback onComplete;

  const JumpscareWidget({
    super.key,
    required this.jumpscareId,
    required this.images,
    required this.sounds,
    this.sanityDamage = 0,
    this.healthDamage = 0,
    required this.onComplete,
  });

  @override
  State<JumpscareWidget> createState() => _JumpscareWidgetState();
}

class _JumpscareWidgetState extends State<JumpscareWidget> with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _shakeController;
  late AnimationController _scaleController;
  final AudioService _audioService = AudioService();
  final Random _random = Random();
  Timer? _timer;
  bool _showImage = false;
  bool _flashOn = false;
  String? _currentImage;
  int _shakeCount = 0;

  @override
  void initState() {
    super.initState();
    
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _triggerJumpscare();
  }

  void _triggerJumpscare() async {
    _currentImage = widget.images.isNotEmpty 
        ? widget.images[_random.nextInt(widget.images.length)]
        : null;

    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      setState(() {
        _flashOn = true;
        _showImage = true;
      });
    }

    _audioService.playJumpscare(widget.sounds);

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }

    _flashController.forward().then((_) {
      _flashController.reverse();
    });

    _scaleController.forward();

    _startShaking();

    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showImage = false;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          widget.onComplete();
        });
      }
    });
  }

  void _startShaking() {
    const shakeDuration = Duration(milliseconds: 50);
    Timer.periodic(shakeDuration, (timer) {
      if (!mounted || _shakeCount > 20) {
        timer.cancel();
        return;
      }
      setState(() {
        _shakeCount++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flashController.dispose();
    _shakeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showImage) return const SizedBox.shrink();

    final dx = _random.nextDouble() * 20 - 10;
    final dy = _random.nextDouble() * 20 - 10;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          if (_flashOn)
            AnimatedBuilder(
              animation: _flashController,
              builder: (context, child) {
                return Container(
                  color: Colors.white.withOpacity(1 - _flashController.value),
                );
              },
            ),
          Center(
            child: AnimatedBuilder(
              animation: _scaleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.5 + _scaleController.value * 0.8,
                  child: Transform.translate(
                    offset: Offset(dx * (_shakeCount % 2 == 0 ? 1 : -1), dy),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: _currentImage != null
                    ? Image.asset(
                        _currentImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackJumpscare();
                        },
                      )
                    : _buildFallbackJumpscare(),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _flashController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: HorrorTheme.bloodRed.withOpacity(_flashController.value),
                        blurRadius: 100,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackJumpscare() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_very_dissatisfied,
              size: 200,
              color: HorrorTheme.bloodRed,
            ),
            const SizedBox(height: 20),
            const Text(
              '啊！！！',
              style: TextStyle(
                fontSize: 60,
                color: HorrorTheme.bloodRed,
                fontWeight: FontWeight.bold,
                fontFamily: 'ChineseBrush',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JumpscareManager {
  static final Map<String, JumpscareData> _jumpscares = {};

  static void initialize() {
    _jumpscares['shadow_glimpse'] = JumpscareData(
      id: 'shadow_glimpse',
      images: [
        'assets/images/jumpscares/shadow_01.png',
        'assets/images/jumpscares/shadow_02.png',
      ],
      sounds: [
        'assets/audio/jumpscares/shadow_whoosh.mp3',
      ],
      sanityDamage: 10,
    );

    _jumpscares['child_laugh'] = JumpscareData(
      id: 'child_laugh',
      images: CharacterManager.getCharacter('child_ghost')?.jumpscareImages ?? [],
      sounds: CharacterManager.getCharacter('child_ghost')?.jumpscareSounds ?? [],
      sanityDamage: 15,
    );

    _jumpscares['water_ghost'] = JumpscareData(
      id: 'water_ghost',
      images: CharacterManager.getCharacter('water_ghost')?.jumpscareImages ?? [],
      sounds: CharacterManager.getCharacter('water_ghost')?.jumpscareSounds ?? [],
      sanityDamage: 20,
      healthDamage: 15,
    );

    _jumpscares['bride_appear'] = JumpscareData(
      id: 'bride_appear',
      images: CharacterManager.getCharacter('ghost_bride')?.jumpscareImages ?? [],
      sounds: CharacterManager.getCharacter('ghost_bride')?.jumpscareSounds ?? [],
      sanityDamage: 25,
      healthDamage: 20,
    );

    _jumpscares['paper_doll'] = JumpscareData(
      id: 'paper_doll',
      images: CharacterManager.getCharacter('paper_doll')?.jumpscareImages ?? [],
      sounds: CharacterManager.getCharacter('paper_doll')?.jumpscareSounds ?? [],
      sanityDamage: 15,
      healthDamage: 10,
    );
  }

  static JumpscareData? getJumpscare(String id) => _jumpscares[id];
}

class JumpscareData {
  final String id;
  final List<String> images;
  final List<String> sounds;
  final int sanityDamage;
  final int healthDamage;

  const JumpscareData({
    required this.id,
    required this.images,
    required this.sounds,
    this.sanityDamage = 0,
    this.healthDamage = 0,
  });
}
