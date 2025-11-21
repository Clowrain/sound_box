import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_box/app.dart';
import 'package:sound_box/features/home/widgets/home_layouts.dart';
import 'package:sound_box/state/pinned_sounds_state.dart';
import 'package:sound_box/state/sound_selection_state.dart';
import 'package:sound_box/utils/pinned_variant_resolver.dart';

/// 应用首页，负责时钟刷新与精选音效入口。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ValueNotifier<DateTime> _nowNotifier;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // 用独立通知器驱动时钟，避免整页 setState 产生额外重建。
    _nowNotifier = ValueNotifier(DateTime.now());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _nowNotifier.value = DateTime.now();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _nowNotifier.dispose();
    super.dispose();
  }

  void _openSounds() {
    Navigator.of(context).pushNamed(SoundRoutes.sounds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1220), Color(0xFF17192F), Color(0xFF0D101C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: OrientationBuilder(
              builder: (context, orientation) {
                final selection = context.watch<SoundSelectionState>();
                final pinnedState = context.watch<PinnedSoundsState>();
                final featured = selection.primary(8);
                final pinnedEntries = pinnedEntriesFromKeys(
                  pinnedState.pinnedKeys,
                  selection.sounds,
                );
                final isPortrait = orientation == Orientation.portrait;

                return _HomeSurfaceCard(
                  isPortrait: isPortrait,
                  child: isPortrait
                      ? HomePortraitLayout(
                          nowListenable: _nowNotifier,
                          onPrimaryAction: _openSounds,
                          featuredSounds: featured,
                          pinnedEntries: pinnedEntries,
                        )
                      : HomeLandscapeLayout(
                          nowListenable: _nowNotifier,
                          onPrimaryAction: _openSounds,
                          featuredSounds: featured,
                          pinnedEntries: pinnedEntries,
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 统一的卡片容器，处理尺寸限制与投影。
class _HomeSurfaceCard extends StatelessWidget {
  const _HomeSurfaceCard({required this.isPortrait, required this.child});

  final bool isPortrait;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxWidth: isPortrait ? 420 : 1000,
        maxHeight: isPortrait ? 720 : 520,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A4459), Color(0xFF2B3042)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}
