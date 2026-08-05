import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/player.dart';
import '../models/item.dart';
import '../game/item_database.dart';
import 'dart:math' as math;

class HudWidget extends StatelessWidget {
  final VoidCallback onInventoryTap;
  final VoidCallback onBackTap;
  final String? selectedItemId;

  const HudWidget({
    super.key,
    required this.onInventoryTap,
    required this.onBackTap,
    this.selectedItemId,
  });

  Item? get _selectedItem => selectedItemId != null ? ItemDatabase.getItem(selectedItemId!) : null;

  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
      builder: (context, player, child) {
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(player),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(context, player),
            ),
            if (_selectedItem != null)
              Positioned(
                top: 100,
                left: 20,
                child: _buildSelectedItemIndicator(context),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedItemIndicator(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final player = Provider.of<Player>(context, listen: false);
        player.notifyListeners();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: HorrorTheme.bloodRed.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HorrorTheme.paperYellow, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, color: HorrorTheme.ghostWhite, size: 18),
            const SizedBox(width: 8),
            Text(
              '使用 ${_selectedItem!.name}',
              style: const TextStyle(
                color: HorrorTheme.ghostWhite,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.close, color: HorrorTheme.ghostWhite.withOpacity(0.7), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Player player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                _buildStatusBar(
                  icon: Icons.favorite,
                  iconColor: HorrorTheme.bloodRed,
                  value: player.health,
                  maxValue: player.maxHealth,
                  label: '生命',
                  barColor: _getHealthColor(player.health),
                ),
                const SizedBox(width: 16),
                _buildStatusBar(
                  icon: Icons.psychology,
                  iconColor: HorrorTheme.eerieGreen,
                  value: player.sanity,
                  maxValue: player.maxSanity,
                  label: '理智',
                  barColor: _getSanityColor(player.sanity),
                ),
                const Spacer(),
                _buildBackButton(),
                const SizedBox(width: 8),
                _buildSceneInfo(player),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: onBackTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: HorrorTheme.inkBlack.withOpacity(0.7),
          border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.arrow_back,
          color: HorrorTheme.paperYellow,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatusBar({
    required IconData icon,
    required Color iconColor,
    required int value,
    required int maxValue,
    required String label,
    required Color barColor,
  }) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: HorrorTheme.ghostWhite.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                '$value',
                style: TextStyle(
                  color: HorrorTheme.ghostWhite,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: HorrorTheme.shadowGray,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: iconColor.withOpacity(0.5), width: 1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / maxValue,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneInfo(Player player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: HorrorTheme.inkBlack.withOpacity(0.7),
        border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '第${player.currentChapter}章',
            style: TextStyle(
              color: HorrorTheme.bloodRed,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Player player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.inventory_2,
              label: '物品栏',
              badge: player.inventory.length.toString(),
              onTap: onInventoryTap,
            ),
            _buildActionButton(
              icon: Icons.map,
              label: '地图',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('地图功能开发中...'), backgroundColor: Color(0xFF8B0000)),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.lightbulb_outline,
              label: '提示',
              badge: player.hintCount.toString(),
              badgeColor: player.hintCount > 0 ? HorrorTheme.candleOrange : Colors.grey,
              onTap: () {
                _showHintDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHintDialog(BuildContext context) {
    final player = Provider.of<Player>(context, listen: false);
    if (player.hintCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('提示次数用完了，看广告可以获得提示！'), backgroundColor: Color(0xFF8B0000)),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a0a),
        title: const Text('获取提示', style: TextStyle(color: Color(0xFF8B0000))),
        content: const Text('使用1次提示机会，或观看30秒广告获得提示。', style: TextStyle(color: Color(0xFFD3D3D3))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              player.useHint();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('提示：仔细检查场景中的每一个物品，有些物品是可以拾取的...'), backgroundColor: Color(0xFF8B0000)),
              );
            },
            child: const Text('使用提示', style: TextStyle(color: Color(0xFF8B0000))),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
    Color? badgeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: HorrorTheme.inkBlack.withOpacity(0.8),
          border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: HorrorTheme.paperYellow, size: 26),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: HorrorTheme.ghostWhite,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? HorrorTheme.bloodRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(int health) {
    if (health > 60) return Colors.redAccent;
    if (health > 30) return Colors.orange;
    return Colors.red[900]!;
  }

  Color _getSanityColor(int sanity) {
    if (sanity > 75) return HorrorTheme.eerieGreen;
    if (sanity > 50) return Colors.yellow;
    if (sanity > 25) return Colors.orange;
    return HorrorTheme.bloodRed;
  }
}
