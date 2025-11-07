import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_box/data/sound_presets.dart';
import 'package:sound_box/features/home/home_page.dart';
import 'package:sound_box/features/sounds/sounds_page.dart';
import 'package:sound_box/state/sound_selection_state.dart';

class SoundRoutes {
  static const home = '/';
  static const sounds = '/sounds';
}

class SoundBoxApp extends StatelessWidget {
  const SoundBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    const scheme = ColorScheme.dark(
      primary: Color(0xFFB0B6FF),
      secondary: Color(0xFFFFCE6A),
      surface: Color(0xFF0E111A),
    );

    final baseTheme = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: 'NotoSansSC',
    );

    return ChangeNotifierProvider(
      create: (_) => SoundSelectionState(initialOrder: whiteNoiseSounds),
      child: MaterialApp(
        title: 'Sound Box',
        debugShowCheckedModeBanner: false,
        theme: baseTheme.copyWith(
          scaffoldBackgroundColor: scheme.surface,
          textTheme: baseTheme.textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        initialRoute: SoundRoutes.home,
        routes: {
          SoundRoutes.home: (_) => const HomePage(),
          SoundRoutes.sounds: (_) => const SoundsPage(),
        },
      ),
    );
  }
}
