import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_box/core/router/sound_routes.dart';
import 'package:sound_box/features/home/widgets/breathing_light_icon.dart';
import 'package:sound_box/features/home/widgets/home_layouts.dart';
import 'package:sound_box/shared/audio/sound_track_pool.dart';
import 'package:sound_box/shared/state/sound_selection_state.dart';

/// 应用首页，负责时钟刷新与精选音效入口。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<DateTime> _nowNotifier;
  Timer? _ticker;
  late final AnimationController _breathingController;
  late final Animation<double> _breathingProgress;
  final Set<String> _activeBreathingIds = {};
  final SoundTrackPool _trackPool = SoundTrackPool.instance;

  @override
  void initState() {
    super.initState();
    // 用独立通知器驱动时钟，避免整页 setState 产生额外重建。
    _nowNotifier = ValueNotifier(DateTime.now());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _nowNotifier.value = DateTime.now();
    });
    _breathingController = AnimationController(
      vsync: this,
      duration: kBreathingLightDuration,
    );
    _breathingProgress = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _nowNotifier.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _openSounds() {
    Navigator.of(context).pushNamed(SoundRoutes.sounds);
  }

  void _handleHomeSoundTap(String key, String path, double volume) {
    if (path.isEmpty) return;
    _trackPool.toggleTrack(key: key, path: path, volume: volume, loop: true);
  }

  void _toggleBreathing(String id, bool active) {
    final hadAny = _activeBreathingIds.isNotEmpty;
    setState(() {
      if (active) {
        _activeBreathingIds.add(id);
      } else {
        _activeBreathingIds.remove(id);
      }
    });

    final hasAnyActive = _activeBreathingIds.isNotEmpty;
    if (!hadAny && hasAnyActive) {
      // 第一个按钮按下，启动统一动画，从当前进度继续。
      _startBreathingFromCurrent();
    } else if (!hasAnyActive && _breathingController.isAnimating) {
      // 所有按钮关闭时停止动画，保留当前 value 以便下次继续。
      _breathingController.stop(canceled: false);
    }
  }

  void _startBreathingFromCurrent() {
    final start = _breathingController.value.clamp(0.0, 0.99);
    _breathingController.repeat(reverse: true, min: start.toDouble());
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
                final featured = selection.primary(8);
                final isPortrait = orientation == Orientation.portrait;

                return _HomeSurfaceCard(
                  isPortrait: isPortrait,
                  child: isPortrait
                      ? HomePortraitLayout(
                          nowListenable: _nowNotifier,
                          onPrimaryAction: _openSounds,
                          featuredSounds: featured,
                          breathingProgress: _breathingProgress,
                          activeBreathingIds: _activeBreathingIds,
                          onBreathingChanged: _toggleBreathing,
                          onSoundTap: _handleHomeSoundTap,
                        )
                      : HomeLandscapeLayout(
                          nowListenable: _nowNotifier,
                          onPrimaryAction: _openSounds,
                          featuredSounds: featured,
                          breathingProgress: _breathingProgress,
                          activeBreathingIds: _activeBreathingIds,
                          onBreathingChanged: _toggleBreathing,
                          onSoundTap: _handleHomeSoundTap,
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
