import 'package:flutter/material.dart';

enum HotspotType {
  item,
  examine,
  navigation,
  puzzle,
  jumpscare,
  npc,
  gyro,
  raster,
}

class Hotspot {
  final String id;
  final String name;
  final String description;
  final RelativeRect position;
  final HotspotType type;
  final String? itemId;
  final String? targetSceneId;
  final String? requiredItem;
  final String? onPickupMessage;
  final String? examineMessage;
  final String? useItemMessage;
  final String? grantsItem;
  final String? lockedMessage;
  final bool pickupJumpscare;
  final bool jumpscareOnExamine;
  final double jumpscareIntensity;
  final int? decreasesSanity;
  final int? decreasesHealth;
  final bool isHidden;
  final bool chapterEndTrigger;
  final bool oneTime;
  final List<String>? sfxOnTrigger;

  const Hotspot({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
    required this.type,
    this.itemId,
    this.targetSceneId,
    this.requiredItem,
    this.onPickupMessage,
    this.examineMessage,
    this.useItemMessage,
    this.grantsItem,
    this.lockedMessage,
    this.pickupJumpscare = false,
    this.jumpscareOnExamine = false,
    this.jumpscareIntensity = 0.5,
    this.decreasesSanity,
    this.decreasesHealth,
    this.isHidden = false,
    this.chapterEndTrigger = false,
    this.oneTime = false,
    this.sfxOnTrigger,
  });

  bool matchesPoint(Offset point, Size screenSize) {
    final rect = Rect.fromLTWH(
      position.left * screenSize.width,
      position.top * screenSize.height,
      (position.right - position.left) * screenSize.width,
      (position.bottom - position.top) * screenSize.height,
    );
    return rect.contains(point);
  }
}

class DialogueLine {
  final String speaker;
  final String text;
  final String emotion;
  final String? voicePath;
  final String? speakerSprite;

  const DialogueLine({
    required this.speaker,
    required this.text,
    this.emotion = 'normal',
    this.voicePath,
    this.speakerSprite,
  });
}
