import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/horror_theme.dart';
import 'models/game_state.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'services/jumpscare_service.dart';
import 'pages/main_menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: HorrorTheme.deepBlack,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storageService = StorageService();
  await storageService.init();

  final audioService = AudioService();
  await audioService.init();

  final jumpscareService = JumpscareService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
        Provider.value(value: storageService),
        Provider.value(value: audioService),
        Provider.value(value: jumpscareService),
      ],
      child: const RedPaperUmbrellaApp(),
    ),
  );
}

class RedPaperUmbrellaApp extends StatefulWidget {
  const RedPaperUmbrellaApp({super.key});

  @override
  State<RedPaperUmbrellaApp> createState() => _RedPaperUmbrellaAppState();
}

class _RedPaperUmbrellaAppState extends State<RedPaperUmbrellaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audioService = context.read<AudioService>();
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      audioService.pauseAll();
    } else if (state == AppLifecycleState.resumed) {
      audioService.resumeAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '红纸伞',
      debugShowCheckedModeBanner: false,
      theme: HorrorTheme.darkTheme,
      darkTheme: HorrorTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainMenuPage(),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const _NoGlowScrollBehavior(),
          child: child!,
        );
      },
    );
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
