import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/player.dart';
import '../models/item.dart';
import '../game/item_database.dart';

class InventoryWidget extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final Function(String?) onItemSelected;
  final Function(String) onItemTap;
  final String? selectedItemId;

  const InventoryWidget({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onItemSelected,
    required this.onItemTap,
    this.selectedItemId,
  });

  @override
  State<InventoryWidget> createState() => _InventoryWidgetState();
}

class _InventoryWidgetState extends State<InventoryWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(InventoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTap(Item item) {
    widget.onItemTap(item.id);
  }

  void _onItemLongPress(Item item) {
    if (widget.selectedItemId == item.id) {
      widget.onItemSelected(null);
    } else {
      widget.onItemSelected(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black54,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: HorrorTheme.inkBlack,
                  border: const Border(
                    top: BorderSide(
                      color: HorrorTheme.bloodRed,
                      width: 3,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: HorrorTheme.bloodRed.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildHint(),
                    Expanded(child: _buildInventoryGrid()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: HorrorTheme.darkRed,
        border: Border(
          bottom: BorderSide(
            color: HorrorTheme.bloodRed.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2,
            color: HorrorTheme.paperYellow,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            '物品栏',
            style: TextStyle(
              fontSize: 20,
              color: HorrorTheme.ghostWhite,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '(点击查看详情，长按选择使用)',
            style: TextStyle(
              fontSize: 12,
              color: HorrorTheme.ghostWhite,
            ),
          ),
          const Spacer(),
          Consumer<Player>(
            builder: (context, player, child) {
              return Text(
                '${player.inventory.length}/20',
                style: TextStyle(
                  color: HorrorTheme.paperYellow.withOpacity(0.7),
                  fontSize: 14,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.close, color: HorrorTheme.ghostWhite),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: HorrorTheme.bloodRed.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.touch_app, color: HorrorTheme.paperYellow.withOpacity(0.7), size: 18),
          const SizedBox(width: 8),
          const Text(
            '探索场景中的物品可以拾取，选中物品后点击场景中的目标使用',
            style: TextStyle(
              color: HorrorTheme.paperYellow,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid() {
    return Consumer<Player>(
      builder: (context, player, child) {
        if (player.inventory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 60,
                  color: HorrorTheme.ghostWhite.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '物品栏是空的',
                  style: TextStyle(
                    color: HorrorTheme.ghostWhite.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击场景中的物品拾取',
                  style: TextStyle(
                    color: HorrorTheme.ghostWhite.withOpacity(0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: player.inventory.length,
          itemBuilder: (context, index) {
            final item = player.inventory[index];
            final isSelected = widget.selectedItemId == item.id;
            return _buildItemSlot(item, isSelected);
          },
        );
      },
    );
  }

  Widget _buildItemSlot(Item item, bool isSelected) {
    return GestureDetector(
      onTap: () => _onItemTap(item),
      onLongPress: () => _onItemLongPress(item),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? HorrorTheme.bloodRed.withOpacity(0.4) : HorrorTheme.shadowGray,
          border: Border.all(
            color: isSelected ? HorrorTheme.paperYellow : _getItemBorderColor(item.type),
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: HorrorTheme.paperYellow.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildItemIcon(item),
              ),
            ),
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : HorrorTheme.paperYellow,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemIcon(Item item) {
    return _buildPlaceholderItem(item);
  }

  Widget _buildPlaceholderItem(Item item) {
    IconData iconData;
    Color iconColor = _getItemBorderColor(item.type);
    
    switch (item.type) {
      case ItemType.key:
        iconData = Icons.vpn_key;
        break;
      case ItemType.tool:
        iconData = Icons.build;
        break;
      case ItemType.document:
        iconData = Icons.description;
        break;
      case ItemType.consumable:
        iconData = Icons.medication;
        break;
      case ItemType.talisman:
        iconData = Icons.auto_awesome;
        break;
      case ItemType.relic:
        iconData = Icons.diamond;
        break;
      case ItemType.container:
        iconData = Icons.inbox;
        break;
      case ItemType.clue:
        iconData = Icons.search;
        break;
      case ItemType.quest:
      default:
        iconData = Icons.help_outline;
    }
    
    switch (item.id) {
      case 'red_umbrella':
        iconData = Icons.beach_access;
        break;
      case 'red_shoe_single':
        iconData = Icons.church;
        break;
      case 'wooden_box':
        iconData = Icons.inbox;
        break;
      case 'jade_pendant':
        iconData = Icons.circle;
        break;
      case 'wooden_comb':
        iconData = Icons.content_cut;
        break;
      case 'bronze_key':
        iconData = Icons.vpn_key;
        break;
      case 'diary_1923':
        iconData = Icons.menu_book;
        break;
      case 'ming_watch':
        iconData = Icons.watch;
        break;
      case 'red_veil':
        iconData = Icons.church;
        break;
      case 'groom_tablet':
        iconData = Icons.account_circle;
        break;
    }
    
    return Icon(iconData, color: iconColor, size: 32);
  }

  Color _getItemBorderColor(ItemType type) {
    switch (type) {
      case ItemType.key:
        return const Color(0xFFFFD700);
      case ItemType.tool:
        return Colors.grey;
      case ItemType.document:
        return HorrorTheme.paperYellow;
      case ItemType.consumable:
        return Colors.green;
      case ItemType.talisman:
        return HorrorTheme.candleOrange;
      case ItemType.relic:
        return Colors.purple;
      case ItemType.container:
        return Colors.brown;
      case ItemType.clue:
        return HorrorTheme.eerieGreen;
      case ItemType.quest:
        return HorrorTheme.bloodRed;
    }
  }
}
