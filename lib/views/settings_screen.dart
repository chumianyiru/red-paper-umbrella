import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/player.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _bgmVolume = 0.7;
  double _sfxVolume = 0.8;
  double _voiceVolume = 0.9;
  bool _vibrationEnabled = true;
  bool _gyroEnabled = true;
  bool _autoSave = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioService = Provider.of<AudioService>(context, listen: false);
      setState(() {
        _bgmVolume = audioService.bgmVolume;
        _sfxVolume = audioService.sfxVolume;
        _voiceVolume = audioService.voiceVolume;
      });
    });
  }

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
          '游戏设置',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('音频设置'),
          const SizedBox(height: 16),
          _buildVolumeSlider(
            icon: Icons.music_note,
            title: '背景音乐',
            value: _bgmVolume,
            onChanged: (value) {
              final audioService = Provider.of<AudioService>(context, listen: false);
              setState(() {
                _bgmVolume = value;
                audioService.setBgmVolume(value);
              });
            },
          ),
          const SizedBox(height: 12),
          _buildVolumeSlider(
            icon: Icons.spatial_audio_off,
            title: '音效',
            value: _sfxVolume,
            onChanged: (value) {
              final audioService = Provider.of<AudioService>(context, listen: false);
              setState(() {
                _sfxVolume = value;
                audioService.setSfxVolume(value);
              });
            },
          ),
          const SizedBox(height: 12),
          _buildVolumeSlider(
            icon: Icons.record_voice_over,
            title: '语音',
            value: _voiceVolume,
            onChanged: (value) {
              final audioService = Provider.of<AudioService>(context, listen: false);
              setState(() {
                _voiceVolume = value;
                audioService.setVoiceVolume(value);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('游戏设置'),
          const SizedBox(height: 16),
          _buildSwitchTile(
            icon: Icons.vibration,
            title: '震动反馈',
            subtitle: '突脸时触发手机震动',
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            icon: Icons.screen_rotation,
            title: '陀螺仪',
            subtitle: '启用体感解谜（需要陀螺仪支持）',
            value: _gyroEnabled,
            onChanged: (value) {
              setState(() {
                _gyroEnabled = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            icon: Icons.save,
            title: '自动存档',
            subtitle: '切换场景时自动保存进度',
            value: _autoSave,
            onChanged: (value) {
              setState(() {
                _autoSave = value;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('其他'),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.info_outline,
            title: '关于游戏',
            onTap: _showAboutDialog,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.warning_amber,
            title: '免责声明',
            onTap: _showDisclaimer,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.delete_outline,
            title: '重置游戏进度',
            titleColor: HorrorTheme.bloodRed,
            onTap: _showResetConfirm,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: HorrorTheme.bloodRed,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'ChineseBrush',
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildVolumeSlider({
    required IconData icon,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HorrorTheme.shadowGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: HorrorTheme.paperYellow, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: HorrorTheme.ghostWhite,
                    fontSize: 16,
                  ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: HorrorTheme.bloodRed,
                    inactiveTrackColor: HorrorTheme.shadowGray,
                    thumbColor: HorrorTheme.bloodRed,
                    overlayColor: HorrorTheme.bloodRed.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: value,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              color: HorrorTheme.paperYellow.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HorrorTheme.shadowGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: HorrorTheme.paperYellow, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: HorrorTheme.ghostWhite,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: HorrorTheme.ghostWhite.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: HorrorTheme.bloodRed,
            activeTrackColor: HorrorTheme.bloodRed.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HorrorTheme.shadowGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: (titleColor ?? HorrorTheme.bloodRed).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? HorrorTheme.paperYellow, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: titleColor ?? HorrorTheme.ghostWhite,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: HorrorTheme.ghostWhite.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HorrorTheme.inkBlack,
        title: const Text('红纸伞', style: TextStyle(color: HorrorTheme.bloodRed)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '版本 1.0.0',
              style: TextStyle(color: HorrorTheme.ghostWhite.withOpacity(0.7)),
            ),
            const SizedBox(height: 12),
            const Text(
              '一款中式恐怖解谜游戏，灵感来源于《纸嫁衣》系列。',
              style: TextStyle(color: HorrorTheme.ghostWhite),
            ),
            const SizedBox(height: 8),
            Text(
              '为了寻找失踪的姐姐，你来到了这个神秘的古镇...',
              style: TextStyle(color: HorrorTheme.ghostWhite.withOpacity(0.8)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定', style: TextStyle(color: HorrorTheme.bloodRed)),
          ),
        ],
      ),
    );
  }

  void _showDisclaimer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HorrorTheme.inkBlack,
        title: const Text('免责声明', style: TextStyle(color: HorrorTheme.bloodRed)),
        content: const SingleChildScrollView(
          child: Text(
            '本游戏包含恐怖、惊悚元素，可能会引起不适。\n\n'
            '1. 孕妇、心脏病患者、高血压患者及心理承受能力较弱者请勿游玩。\n\n'
            '2. 建议在明亮环境下游玩，15岁以下未成年人请在监护人陪同下游玩。\n\n'
            '3. 游戏中出现的所有场景、人物、事件均为虚构，如有雷同纯属巧合。\n\n'
            '4. 请适度游戏，注意休息。',
            style: TextStyle(color: HorrorTheme.ghostWhite, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我已阅读', style: TextStyle(color: HorrorTheme.bloodRed)),
          ),
        ],
      ),
    );
  }

  void _showResetConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HorrorTheme.inkBlack,
        title: const Text('重置进度', style: TextStyle(color: HorrorTheme.bloodRed)),
        content: const Text(
          '确定要重置所有游戏进度吗？这将清除所有存档数据，此操作不可撤销。',
          style: TextStyle(color: HorrorTheme.ghostWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: HorrorTheme.paperYellow)),
          ),
          TextButton(
            onPressed: () {
              final player = Provider.of<Player>(context, listen: false);
              player.reset();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('游戏进度已重置'),
                  backgroundColor: HorrorTheme.darkRed,
                ),
              );
            },
            child: const Text('确定重置', style: TextStyle(color: HorrorTheme.bloodRed)),
          ),
        ],
      ),
    );
  }
}
