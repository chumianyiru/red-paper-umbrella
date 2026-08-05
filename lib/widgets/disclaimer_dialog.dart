import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/player.dart';
import '../services/audio_service.dart';

class DisclaimerDialog extends StatefulWidget {
  const DisclaimerDialog({super.key});

  @override
  State<DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<DisclaimerDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _agreed = false;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _accept() {
    _audioService.playSfx('paper_flip');
    final player = Provider.of<Player>(context, listen: false);
    player.acceptDisclaimer();
    Navigator.of(context).pop();
  }

  void _refuse() {
    _audioService.playSfx('door_close');
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: HorrorTheme.inkBlack,
            border: Border.all(color: HorrorTheme.bloodRed, width: 3),
            boxShadow: [
              BoxShadow(
                color: HorrorTheme.bloodRed.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HorrorTheme.darkRed,
                  border: Border(
                    bottom: BorderSide(color: HorrorTheme.bloodRed, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: HorrorTheme.candleOrange, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '免责声明',
                      style: TextStyle(
                        fontSize: 24,
                        color: HorrorTheme.ghostWhite,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ChineseBrush',
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWarningSection(
                        '健康警告',
                        '本游戏包含大量恐怖元素、惊悚画面、突脸惊吓(Jumpscare)、血腥画面、阴森音效、鬼魂形象等内容，可能对部分玩家造成心理不适。',
                      ),
                      const SizedBox(height: 16),
                      _buildWarningSection(
                        '禁忌人群',
                        '以下人群请勿游玩本游戏：\n\n1. 心脏病患者、高血压患者\n2. 孕妇及哺乳期妇女\n3. 有精神疾病史或心理障碍者\n4. 18岁以下未成年人\n5. 对恐怖、血腥内容敏感者\n6. 癫痫患者及有惊厥病史者',
                      ),
                      const SizedBox(height: 16),
                      _buildWarningSection(
                        '游玩建议',
                        '1. 建议佩戴耳机以获得最佳体验\n2. 请在光线充足的环境下游玩\n3. 游玩时间不宜过长，注意休息\n4. 如感到不适请立即停止游戏\n5. 请勿在深夜独自游玩',
                      ),
                      const SizedBox(height: 16),
                      _buildWarningSection(
                        '免责条款',
                        '玩家因游玩本游戏而产生的任何心理不适、身体不适、惊吓反应或其他不良后果，由玩家自行承担，游戏开发者不承担任何法律责任。\n\n继续游玩即表示您已阅读、理解并同意以上所有条款。',
                      ),
                      const SizedBox(height: 20),
                      if (!_hasScrolledToBottom)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: HorrorTheme.paperYellow.withOpacity(0.7),
                                size: 30,
                              ),
                              Text(
                                '请向下阅读完整内容',
                                style: TextStyle(
                                  color: HorrorTheme.paperYellow.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HorrorTheme.shadowGray,
                  border: Border(
                    top: BorderSide(color: HorrorTheme.bloodRed.withOpacity(0.5), width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _agreed,
                          onChanged: _hasScrolledToBottom
                              ? (value) {
                                  setState(() {
                                    _agreed = value ?? false;
                                  });
                                }
                              : null,
                          activeColor: HorrorTheme.bloodRed,
                          checkColor: HorrorTheme.ghostWhite,
                        ),
                        Expanded(
                          child: Text(
                            '我已阅读并同意以上免责声明',
                            style: TextStyle(
                              color: _hasScrolledToBottom
                                  ? HorrorTheme.ghostWhite
                                  : HorrorTheme.ghostWhite.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _refuse,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: HorrorTheme.paperYellow,
                              side: BorderSide(color: HorrorTheme.paperYellow.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('拒绝并退出'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _agreed ? _accept : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HorrorTheme.bloodRed,
                              disabledBackgroundColor: HorrorTheme.darkRed.withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('接受并进入游戏'),
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
    );
  }

  Widget _buildWarningSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '【$title】',
          style: TextStyle(
            fontSize: 16,
            color: HorrorTheme.candleOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: HorrorTheme.ghostWhite.withOpacity(0.9),
            height: 1.8,
          ),
        ),
      ],
    );
  }
}
