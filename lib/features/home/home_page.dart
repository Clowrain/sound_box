import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sound_box/app.dart';
import 'package:sound_box/features/home/widgets/dot_matrix_clock.dart';
import 'package:sound_box/models/white_noise_sound.dart';
import 'package:sound_box/state/pinned_sounds_state.dart';
import 'package:sound_box/state/sound_selection_state.dart';
import 'package:sound_box/utils/pinned_variant_resolver.dart';

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
                  child: isPortrait
                      ? _PortraitLayout(
                          nowListenable: _nowNotifier,
                          onPrimaryAction: _openSounds,
                          featuredSounds: featured,
                          pinnedEntries: pinnedEntries,
                        )
                      : _LandscapeLayout(
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

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({
    required this.nowListenable,
    required this.onPrimaryAction,
    required this.featuredSounds,
    required this.pinnedEntries,
  });

  final ValueListenable<DateTime> nowListenable;
  final VoidCallback onPrimaryAction;
  final List<WhiteNoiseSound> featuredSounds;
  final List<PinnedVariantEntry> pinnedEntries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: _DisplaySurface(nowListenable: nowListenable),
              ),
              const SizedBox(height: 16),
              _PrimaryActions(onPrimaryAction: onPrimaryAction),
              const SizedBox(height: 12),
              Expanded(
                flex: 3,
                child: _QuickSoundGrid(
                  sounds: featuredSounds,
                  pinnedEntries: pinnedEntries,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({
    required this.nowListenable,
    required this.onPrimaryAction,
    required this.featuredSounds,
    required this.pinnedEntries,
  });

  final ValueListenable<DateTime> nowListenable;
  final VoidCallback onPrimaryAction;
  final List<WhiteNoiseSound> featuredSounds;
  final List<PinnedVariantEntry> pinnedEntries;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final availableHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 330;
              final pillHeight = ((availableHeight - gap * 2) / 3)
                  .clamp(72.0, 110.0)
                  .toDouble();

              return Column(
                children: [
                  _SidePill(
                    height: pillHeight,
                    onTap: onPrimaryAction,
                    child: const Icon(
                      Icons.graphic_eq,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: gap),
                  _SidePill(
                    height: pillHeight,
                    child: Icon(Icons.settings, color: Colors.white70),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _DisplaySurface(
                  nowListenable: nowListenable,
                  minRows: 10,
                  minColumns: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _QuickSoundGrid(
                  sounds: featuredSounds,
                  crossAxisCount: 2,
                  pinnedEntries: pinnedEntries,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisplaySurface extends StatelessWidget {
  const _DisplaySurface({
    required this.nowListenable,
    this.minRows = 14,
    this.minColumns = 20,
  });

  final ValueListenable<DateTime> nowListenable;
  final int minRows;
  final int minColumns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.35),
          width: 4,
        ),
        color: const Color(0xFF2D3344),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
          BoxShadow(color: Color(0x3310111A), blurRadius: 40, spreadRadius: 8),
        ],
      ),
      child: RepaintBoundary(
        child: ValueListenableBuilder<DateTime>(
          valueListenable: nowListenable,
          builder: (_, now, __) {
            return DotMatrixClock(
              time: now,
              minRows: minRows,
              minColumns: minColumns,
            );
          },
        ),
      ),
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({required this.onPrimaryAction});

  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SquareButton(
            label: '音效',
            icon: Icons.graphic_eq,
            onTap: onPrimaryAction,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SquareButton(
            label: '设置',
            icon: Icons.settings_outlined,
            onTap: onPrimaryAction,
          ),
        ),
      ],
    );
  }
}

class _QuickSoundGrid extends StatelessWidget {
  const _QuickSoundGrid({
    required this.sounds,
    this.crossAxisCount = 3,
    this.pinnedEntries = const [],
  });

  final List<WhiteNoiseSound> sounds;
  final int crossAxisCount;
  final List<PinnedVariantEntry> pinnedEntries;

  @override
  Widget build(BuildContext context) {
    final items = _gridItems();

    return LayoutBuilder(
      builder: (context, constraints) {
        const targetSize = 72.0;
        const gap = 12.0;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final computedCrossAxisCount = (availableWidth / (targetSize + gap))
            .floor()
            .clamp(crossAxisCount, 6);

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: computedCrossAxisCount,
            childAspectRatio: 1,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _SquareButton(
              icon: item.icon,
              label: item.label,
              onTap: () {},
            );
          },
        );
      },
    );
  }

  List<_GridItem> _gridItems() {
    if (pinnedEntries.isNotEmpty) {
      return pinnedEntries
          .map(
            (entry) => _GridItem(
              icon: entry.sound.icon,
              label: entry.variant.name.isNotEmpty
                  ? entry.variant.name
                  : entry.sound.name,
            ),
          )
          .toList();
    }
    return sounds
        .map((sound) => _GridItem(icon: sound.icon, label: sound.name))
        .toList();
  }
}

class _GridItem {
  const _GridItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _SquareButton extends StatefulWidget {
  const _SquareButton({this.icon, this.label, this.onTap});

  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;

  @override
  State<_SquareButton> createState() => _SquareButtonState();
}

class _SquareButtonState extends State<_SquareButton> {
  static final _GlobalBreathTicker _breathSignal = _GlobalBreathTicker.instance;
  VoidCallback? _breathListener;
  bool _isPressed = false;
  bool _isActive = false;
  double _breathValue = 0;
  bool get _isIconOnly => (widget.label == null) || widget.label!.isEmpty;

  @override
  void initState() {
    super.initState();
    _breathValue = _breathSignal.value;
    _breathListener = () {
      if (!_isActive) return;
      setState(() {
        _breathValue = _breathSignal.value;
      });
    };
    _breathSignal.addListener(_breathListener!);
  }

  @override
  void dispose() {
    _breathSignal.removeListener(_breathListener!);
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isActive = !_isActive;
      _breathValue = _breathSignal.value;
    });
    widget.onTap?.call();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapEnd([TapUpDetails? _]) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  Color _iconColor(double glowStrength) {
    if (!_isIconOnly) return Colors.white;
    if (!_isActive) {
      return Colors.black;
    }
    const glow = Color(0xFFFFF4C9);
    return Color.lerp(Colors.black, glow, glowStrength.clamp(0, 1)) ??
        Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double glowStrength = _isActive ? _breathValue : 0;
    final iconColor = _iconColor(glowStrength);
    final bool showText = !_isIconOnly;
    final double elevation = _isPressed ? 4 : 10;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        onTapDown: _handleTapDown,
        onTapCancel: _handleTapEnd,
        onTapUp: _handleTapEnd,
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E3548), Color(0xFF171C28)],
            ),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.55),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                offset: Offset(0, elevation),
                blurRadius: elevation * 1.8,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0x3329394D),
                offset: const Offset(-2, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isPressed
                    ? const [Color(0xFF1A1F2C), Color(0xFF131722)]
                    : const [Color(0xFF232838), Color(0xFF171C28)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: Center(
              child: _isIconOnly
                  ? _BreathingIcon(
                      icon: widget.icon,
                      color: iconColor,
                      size: 24,
                      intensity: glowStrength,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _BreathingIcon(
                          icon: widget.icon,
                          color: iconColor,
                          size: 22,
                          intensity: glowStrength,
                        ),
                        if (showText) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.label!,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidePill extends StatelessWidget {
  const _SidePill({this.child, this.height = 110, this.onTap});

  final Widget? child;
  final double height;
  final VoidCallback? onTap;
  static const double _width = 70;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          width: _width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1F2C).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _BreathingIcon extends StatelessWidget {
  const _BreathingIcon({
    required this.icon,
    required this.color,
    required this.size,
    required this.intensity,
  });

  final IconData? icon;
  final Color color;
  final double size;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final double glow = intensity.clamp(0, 1);
    final double blur = 8 + 12 * glow;
    final double spread = 0.5 + 2 * glow;
    final double hazeSize = size;
    final Color hazeColor =
        const Color(0xFFFFF4C9).withValues(alpha: 0.05 + 0.25 * glow);
    final Color litIconColor =
        Color.lerp(color, const Color(0xFFFFF4C9), glow * 0.6) ?? color;
    final double scale = 1 + glow * 0.08;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (glow > 0)
          Container(
            width: hazeSize,
            height: hazeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: hazeColor,
                  blurRadius: blur,
                  spreadRadius: spread,
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  hazeColor,
                  hazeColor.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
                stops: const [0, 0.85, 1],
              ),
            ),
          ),
        Transform.scale(
          scale: scale,
          child: Icon(icon, color: litIconColor, size: size),
        ),
      ],
    );
  }
}

class _GlobalBreathTicker extends ChangeNotifier {
  _GlobalBreathTicker._() {
    _ticker = Ticker(_handleTick);
  }

  static final _GlobalBreathTicker instance = _GlobalBreathTicker._();

  static const int _periodMs = 2400;
  late final Ticker _ticker;
  double value = 0;

  @override
  void addListener(VoidCallback listener) {
    final hadListeners = hasListeners;
    super.addListener(listener);
    if (!hadListeners && !_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _ticker.stop();
    }
  }

  void _handleTick(Duration elapsed) {
    final int ms = elapsed.inMilliseconds % _periodMs;
    final double progress = ms / _periodMs;
    final double mirrored = progress <= 0.5 ? progress * 2 : (1 - progress) * 2;
    value = Curves.easeInOut.transform(mirrored);
    notifyListeners();
  }
}
