import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/item.dart';
import '../models/player.dart';
import '../game/item_database.dart';

class ItemDetailDialog extends StatefulWidget {
  final String itemId;
  final VoidCallback? onUse;

  const ItemDetailDialog({
    super.key,
    required this.itemId,
    this.onUse,
  });

  @override
  State<ItemDetailDialog> createState() => _ItemDetailDialogState();
}

class _ItemDetailDialogState extends State<ItemDetailDialog> {
  bool _isExamined = false;
  Item? item;

  @override
  void initState() {
    super.initState();
    item = ItemDatabase.getItem(widget.itemId);
  }

  void _useItem() {
    if (item == null) return;
    
    if (item!.healAmount != null) {
      final player = Provider.of<Player>(context, listen: false);
      player.heal(item!.healAmount!);
      player.removeItem(item!.id);
      _showMessageAndClose('使用了${item!.name}');
    } else if (item!.sanityRestore != null) {
      final player = Provider.of<Player>(context, listen: false);
      player.restoreSanity(item!.sanityRestore!);
      player.removeItem(item!.id);
      _showMessageAndClose('你感觉心安了一些');
    } else if (widget.onUse != null) {
      widget.onUse!();
    } else {
      _showMessage('这个物品现在不能直接使用，在场景中选中后点击目标试试');
    }
  }

  void _readDocument() {
    if (item?.documentContent != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1a0a0a),
          title: Text(item!.name, style: const TextStyle(color: Color(0xFF8B0000))),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: item!.documentContent!.map((line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  line,
                  style: const TextStyle(color: Color(0xFFD3D3D3), height: 1.5),
                ),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('合上', style: TextStyle(color: Color(0xFF8B0000))),
            ),
          ],
        ),
      );
    }
  }

  void _openContainer() {
    if (item?.canOpen == true && item?.containedItemId != null) {
      final player = Provider.of<Player>(context, listen: false);
      final containedItem = ItemDatabase.getItem(item!.containedItemId!);
      if (containedItem != null) {
        player.addItem(containedItem);
        _showMessage('你打开了${item!.name}，里面有${containedItem.name}！');
      }
    }
  }

  void _examineItem() {
    setState(() {
      _isExamined = !_isExamined;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: HorrorTheme.darkRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMessageAndClose(String message) {
    Navigator.of(context).pop();
    _showMessage(message);
  }

  IconData _getItemIcon() {
    if (item == null) return Icons.help_outline;
    
    switch (item!.type) {
      case ItemType.key:
        return Icons.vpn_key;
      case ItemType.tool:
        return Icons.build;
      case ItemType.document:
        return Icons.description;
      case ItemType.consumable:
        return Icons.medication;
      case ItemType.talisman:
        return Icons.auto_awesome;
      case ItemType.relic:
        return Icons.diamond;
      case ItemType.container:
        return Icons.inbox;
      case ItemType.clue:
        return Icons.search;
      case ItemType.quest:
      default:
        return Icons.help_outline;
    }
  }

  Color _getItemColor() {
    if (item == null) return Colors.grey;
    
    switch (item!.type) {
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

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return Dialog(
        backgroundColor: HorrorTheme.inkBlack,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('物品不存在', style: TextStyle(color: HorrorTheme.ghostWhite)),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: HorrorTheme.inkBlack,
          border: Border.all(color: HorrorTheme.bloodRed, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HorrorTheme.darkRed,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item!.name,
                      style: const TextStyle(
                        fontSize: 22,
                        color: HorrorTheme.ghostWhite,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: HorrorTheme.ghostWhite),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: HorrorTheme.shadowGray,
                      border: Border.all(color: _getItemColor(), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getItemIcon(),
                      size: 60,
                      color: _getItemColor(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: HorrorTheme.shadowGray.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: HorrorTheme.bloodRed.withOpacity(0.3)),
                    ),
                    child: Text(
                      _isExamined 
                          ? (item!.examineDetail ?? item!.description)
                          : item!.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: HorrorTheme.ghostWhite.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _examineItem,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: Text(_isExamined ? '返回' : '仔细查看'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HorrorTheme.shadowGray,
                          foregroundColor: HorrorTheme.paperYellow,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      if (item!.canRead && item!.documentContent != null)
                        ElevatedButton.icon(
                          onPressed: _readDocument,
                          icon: const Icon(Icons.menu_book, size: 16),
                          label: const Text('阅读'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HorrorTheme.paperYellow,
                            foregroundColor: HorrorTheme.inkBlack,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      if (item!.canOpen && item!.containedItemId != null)
                        ElevatedButton.icon(
                          onPressed: _openContainer,
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('打开'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: _useItem,
                        icon: const Icon(Icons.back_hand, size: 16),
                        label: const Text('选中使用'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HorrorTheme.bloodRed,
                          foregroundColor: HorrorTheme.ghostWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}
