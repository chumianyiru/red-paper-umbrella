import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/hotspot.dart';
import '../services/audio_service.dart';

class DialogBox extends StatefulWidget {
  final List<DialogueLine> dialogs;
  final VoidCallback onComplete;
  final String? speakerImage;

  const DialogBox({
    super.key,
    required this.dialogs,
    required this.onComplete,
    this.speakerImage,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  int _currentIndex = 0;
  final AudioService _audioService = AudioService();
  bool _isTyping = false;
  String _displayedText = '';
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    if (_currentIndex >= widget.dialogs.length) {
      widget.onComplete();
      return;
    }

    final dialog = widget.dialogs[_currentIndex];
    if (dialog.voicePath != null) {
      _audioService.playVoice(dialog.voicePath!);
    }

    setState(() {
      _isTyping = true;
      _displayedText = '';
      _charIndex = 0;
    });

    _typeNextChar(dialog.text);
  }

  void _typeNextChar(String text) {
    if (_charIndex < text.length) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _charIndex++;
            _displayedText = text.substring(0, _charIndex);
          });
          _typeNextChar(text);
        }
      });
    } else {
      setState(() {
        _isTyping = false;
      });
    }
  }

  void _onTap() {
    _audioService.playSfx('dialogue_open');
    
    if (_isTyping) {
      setState(() {
        _isTyping = false;
        _displayedText = widget.dialogs[_currentIndex].text;
      });
    } else {
      _currentIndex++;
      if (_currentIndex >= widget.dialogs.length) {
        widget.onComplete();
      } else {
        _startTyping();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.dialogs.length) {
      return const SizedBox.shrink();
    }

    final dialog = widget.dialogs[_currentIndex];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HorrorTheme.inkBlack.withOpacity(0.95),
            border: Border.all(color: HorrorTheme.bloodRed, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: HorrorTheme.bloodRed.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSpeakerBar(dialog),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.speakerImage != null || dialog.speakerSprite != null)
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            dialog.speakerSprite ?? widget.speakerImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: HorrorTheme.shadowGray,
                                child: Icon(
                                  Icons.person,
                                  color: HorrorTheme.ghostWhite.withOpacity(0.5),
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayedText,
                            style: const TextStyle(
                              color: HorrorTheme.ghostWhite,
                              fontSize: 18,
                              height: 1.8,
                            ),
                          ),
                          if (!_isTyping)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: HorrorTheme.paperYellow.withOpacity(0.7),
                                  size: 24,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeakerBar(DialogueLine dialog) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: HorrorTheme.darkRed,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        border: Border(
          bottom: BorderSide(color: HorrorTheme.bloodRed.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getSpeakerIcon(dialog.speaker),
            color: HorrorTheme.candleOrange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            dialog.speaker,
            style: const TextStyle(
              color: HorrorTheme.ghostWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'ChineseBrush',
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSpeakerIcon(String speaker) {
    if (speaker == '旁白') return Icons.menu_book;
    if (speaker == '???' || speaker.contains('鬼') || speaker.contains('灵')) {
      return Icons.ghost;
    }
    if (speaker == '林晚卿') return Icons.person;
    return Icons.record_voice_over;
  }
}

class ExamineMessageBox extends StatelessWidget {
  final String text;
  final VoidCallback onClose;

  const ExamineMessageBox({
    super.key,
    required this.text,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HorrorTheme.inkBlack.withOpacity(0.9),
            border: Border.all(color: HorrorTheme.paperYellow.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.visibility, color: HorrorTheme.paperYellow, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: HorrorTheme.ghostWhite.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              Icon(
                Icons.close,
                color: HorrorTheme.ghostWhite.withOpacity(0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemPickupNotification extends StatefulWidget {
  final String itemName;
  final String itemImage;
  final VoidCallback onComplete;

  const ItemPickupNotification({
    super.key,
    required this.itemName,
    required this.itemImage,
    required this.onComplete,
  });

  @override
  State<ItemPickupNotification> createState() => _ItemPickupNotificationState();
}

class _ItemPickupNotificationState extends State<ItemPickupNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      _controller.reverse().then((_) {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: HorrorTheme.inkBlack.withOpacity(0.95),
              border: Border.all(color: HorrorTheme.candleOrange, width: 2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: HorrorTheme.candleOrange.withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HorrorTheme.shadowGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.asset(
                    widget.itemImage,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.inventory_2,
                        color: HorrorTheme.candleOrange,
                        size: 30,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '获得物品',
                      style: TextStyle(
                        color: HorrorTheme.paperYellow.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.itemName,
                      style: const TextStyle(
                        color: HorrorTheme.ghostWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ChineseBrush',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
