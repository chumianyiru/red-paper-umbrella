import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'models/player.dart';
import 'services/audio_service.dart';
import 'utils/theme.dart';
import 'views/main_menu.dart';
import 'views/disclaimer_screen.dart';
import 'views/chapter_select_screen.dart';
import 'views/game_screen.dart';
import 'views/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  final audioService = AudioService();
  await audioService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Player()),
        Provider.value(value: audioService),
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

class _RedPaperUmbrellaAppState extends State<RedPaperUmbrellaApp> {
  bool _disclaimerAccepted = false;

  @override
  void initState() {
    super.initState();
    _checkDisclaimer();
  }

  Future<void> _checkDisclaimer() async {
    final player = Provider.of<Player>(context, listen: false);
    await player.loadGame();
    setState(() {
      _disclaimerAccepted = player.disclaimerAccepted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '红纸伞',
      debugShowCheckedModeBanner: false,
      theme: HorrorTheme.darkTheme,
      darkTheme: HorrorTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: _disclaimerAccepted ? '/menu' : '/disclaimer',
      routes: {
        '/disclaimer': (context) => const DisclaimerScreen(),
        '/menu': (context) => const MainMenu(),
        '/chapter_select': (context) => const ChapterSelectScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/game') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => GameScreen(
              chapterId: args?['chapterId'] ?? 1,
            ),
          );
        }
        return null;
      },
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const _SanityVignette(),
          ],
        );
      },
    );
  }
}

class _SanityVignette extends StatelessWidget {
  const _SanityVignette();

  @override
  Widget build(BuildContext context) {
    return Consumer<Player>(
      builder: (context, player, child) {
        final sanity = player.sanity;
        if (sanity >= 70) return const SizedBox.shrink();
        
        double intensity = 0;
        if (sanity < 50) {
          intensity = (50 - sanity) / 50 * 0.4;
        }
        
        return IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(intensity),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
