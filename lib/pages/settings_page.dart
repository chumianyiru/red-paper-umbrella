import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../theme/horror_theme.dart';
import '../widgets/horror_painter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return HorrorBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: HorrorTheme.bloodRed),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '游戏设置',
            style: TextStyle(
              color: HorrorTheme.bloodRed,
              fontFamily: 'KaiTi',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer2<GameState, StorageService>(
          builder: (context, gameState, storageService, child) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle('音频设置'),
                const SizedBox(height: 12),
                _buildVolumeSlider(gameState),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  '背景音乐',
                  gameState.bgmEnabled,
                  (value) {
                    gameState.setBgmEnabled(value);
                    storageService.setBgmEnabled(value);
                    final audioService = context.read<AudioService>();
                    audioService.setGameState(gameState);
                    audioService.updateVolume();
                  },
                  Icons.music_note,
                ),
                _buildSwitchTile(
                  '音效',
                  gameState.sfxEnabled,
                  (value) {
                    gameState.setSfxEnabled(value);
                    storageService.setSfxEnabled(value);
                    final audioService = context.read<AudioService>();
                    audioService.setGameState(gameState);
                    audioService.updateVolume();
                  },
                  Icons.volume_up,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('游戏设置'),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  '震动反馈',
                  gameState.vibrationEnabled,
                  (value) {
                    gameState.setVibrationEnabled(value);
                    storageService.setVibrationEnabled(value);
                  },
                  Icons.vibration,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('体感设置'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HorrorTheme.darkGray.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            gameState.gyroAvailable ? Icons.screen_rotation : Icons.screen_lock_rotation,
                            color: gameState.gyroAvailable ? HorrorTheme.bloodRed : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            gameState.gyroAvailable ? '陀螺仪可用' : '陀螺仪不可用',
                            style: TextStyle(
                              color: gameState.gyroAvailable ? HorrorTheme.bloodRed : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gameState.gyroAvailable
                            ? '您可以通过摇晃手机进行体感解谜'
                            : '您的设备不支持陀螺仪，将使用手动操作模式',
                        style: TextStyle(
                          color: HorrorTheme.ghostWhite.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildActionButton(
                  '清除存档',
                  Icons.delete_forever,
                  () => _showClearDataDialog(context, gameState, storageService),
                  isDanger: true,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  '关于游戏',
                  Icons.info_outline,
                  () => _showAboutDialog(context),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    '红纸伞 v1.0.0',
                    style: TextStyle(
                      color: HorrorTheme.ghostWhite.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: HorrorTheme.bloodRed,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'KaiTi',
      ),
    );
  }

  Widget _buildVolumeSlider(GameState gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: HorrorTheme.darkGray.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_down, color: HorrorTheme.bloodRed),
          Expanded(
            child: Slider(
              value: gameState.volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: HorrorTheme.bloodRed,
              inactiveColor: HorrorTheme.darkGrey,
              onChanged: (value) {
                gameState.setVolume(value);
                final audioService = context.read<AudioService>();
                audioService.setGameState(gameState);
                audioService.updateVolume();
              },
              onChangeEnd: (value) {
                context.read<StorageService>().setVolume(value);
              },
            ),
          ),
          const Icon(Icons.volume_up, color: HorrorTheme.bloodRed),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: HorrorTheme.darkGray.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.3)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(icon, color: HorrorTheme.bloodRed),
        title: Text(
          title,
          style: const TextStyle(color: HorrorTheme.ghostWhite, fontSize: 16),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: HorrorTheme.bloodRed,
        activeTrackColor: HorrorTheme.bloodRed.withOpacity(0.5),
        inactiveThumbColor: HorrorTheme.ghostWhite,
        inactiveTrackColor: HorrorTheme.darkGray,
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed, {bool isDanger = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDanger ? HorrorTheme.bloodRed : HorrorTheme.darkGray,
          foregroundColor: isDanger ? Colors.white : HorrorTheme.ghostWhite,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDanger ? HorrorTheme.bloodRed : HorrorTheme.bloodRed.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, GameState gameState, StorageService storageService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HorrorTheme.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: HorrorTheme.bloodRed),
        ),
        title: const Text(
          '清除存档',
          style: TextStyle(color: HorrorTheme.bloodRed, fontFamily: 'KaiTi'),
        ),
        content: const Text(
          '确定要清除所有游戏进度吗？此操作不可恢复。',
          style: TextStyle(color: HorrorTheme.paleGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: HorrorTheme.paleGrey)),
          ),
          TextButton(
            onPressed: () {
              storageService.clearGameData();
              gameState.startNewGame();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('存档已清除'),
                  backgroundColor: HorrorTheme.bloodRed,
                ),
              );
            },
            child: const Text('确定', style: TextStyle(color: HorrorTheme.bloodRed)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HorrorTheme.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: HorrorTheme.bloodRed),
        ),
        title: const Text(
          '关于红纸伞',
          style: TextStyle(color: HorrorTheme.bloodRed, fontFamily: 'KaiTi'),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '《红纸伞》是一款纸嫁衣风格的2D恐怖解谜游戏。\n\n'
            '故事发生在一座荒废的老宅中，你需要探索阴森的房间，'
            '解开尘封多年的谜题，揭开红纸伞背后的恐怖秘密...\n\n'
            '⚠️ 游戏包含恐怖画面和突脸惊吓，\n'
            '请确保您已年满18岁，且无心脏疾病。\n\n'
            '建议佩戴耳机游玩，以获得最佳恐怖体验。',
            style: TextStyle(color: HorrorTheme.paleGrey, height: 1.6),
          ),
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
}
