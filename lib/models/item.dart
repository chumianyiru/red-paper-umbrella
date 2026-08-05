enum ItemType { key, tool, document, consumable, quest, talisman, relic, clue, container }

class Item {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final String? imagePath;
  final ItemType type;
  final bool canCombine;
  final bool canOpen;
  final bool canRead;
  final String? containedItemId;
  final List<String>? documentContent;
  final String? examineDetail;
  final int? healAmount;
  final int? sanityRestore;
  final String? useDialogue;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.imagePath,
    required this.type,
    this.canCombine = false,
    this.canOpen = false,
    this.canRead = false,
    this.containedItemId,
    this.documentContent,
    this.examineDetail,
    this.healAmount,
    this.sanityRestore,
    this.useDialogue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconPath': iconPath,
        'imagePath': imagePath,
        'type': type.index,
        'canCombine': canCombine,
        'canOpen': canOpen,
        'canRead': canRead,
        'containedItemId': containedItemId,
        'documentContent': documentContent,
        'examineDetail': examineDetail,
        'healAmount': healAmount,
        'sanityRestore': sanityRestore,
        'useDialogue': useDialogue,
      };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconPath: json['iconPath'] ?? json['imagePath'] ?? '',
      imagePath: json['imagePath'],
      type: ItemType.values[json['type'] ?? 0],
      canCombine: json['canCombine'] ?? false,
      canOpen: json['canOpen'] ?? false,
      canRead: json['canRead'] ?? false,
      containedItemId: json['containedItemId'],
      documentContent: json['documentContent'] != null
          ? List<String>.from(json['documentContent'])
          : null,
      examineDetail: json['examineDetail'],
      healAmount: json['healAmount'],
      sanityRestore: json['sanityRestore'],
      useDialogue: json['useDialogue'],
    );
  }
}
