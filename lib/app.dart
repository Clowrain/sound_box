import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_box/core/router/sound_routes.dart';
import 'package:sound_box/core/theme/app_theme.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/features/home/home_page.dart';
import 'package:sound_box/features/sounds/sounds_page.dart';
import 'package:sound_box/shared/state/pinned_sounds_state.dart';
import 'package:sound_box/shared/state/sound_selection_state.dart';

class SoundBoxApp extends StatelessWidget {
  const SoundBoxApp({super.key, required this.initialSounds});

  final List<WhiteNoiseSound> initialSounds;

  @override
  Widget build(BuildContext context) {
    final theme = buildAppTheme();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SoundSelectionState(initialOrder: initialSounds),
        ),
        ChangeNotifierProvider(create: (_) => PinnedSoundsState()),
      ],
      child: MaterialApp(
        title: 'Sound Box',
        debugShowCheckedModeBanner: false,
        theme: theme,
        initialRoute: SoundRoutes.home,
        routes: {
          SoundRoutes.home: (_) => const HomePage(),
          SoundRoutes.sounds: (_) => const SoundsPage(),
        },
      ),
    );
  }
}
