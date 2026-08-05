import 'hotspot.dart';

class Scene {
  final String id;
  final int chapterId;
  final String? backgroundPath;
  final String description;
  final String? ambientSound;
  final String? bgm;
  final List<Hotspot> hotspots;
  final List<DialogueLine> onEnterDialogue;
  final Function? onEnter;
  final bool isDark;

  const Scene({
    required this.id,
    required this.chapterId,
    this.backgroundPath,
    required this.description,
    this.ambientSound,
    this.bgm,
    this.hotspots = const [],
    this.onEnterDialogue = const [],
    this.onEnter,
    this.isDark = false,
  });
}
