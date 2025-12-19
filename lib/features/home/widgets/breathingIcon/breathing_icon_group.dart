import 'package:flutter/material.dart';
import 'package:sound_box/features/home/widgets/breathingIcon/breathing_icon_config.dart';
import 'package:sound_box/features/home/widgets/breathingIcon/breathing_icon_controller.dart';
import 'package:sound_box/features/home/widgets/breathingIcon/breathing_icon_item.dart';

class BreathingIconGroup extends StatefulWidget {
  final List<BreathingIconConfig> icons;
  final BreathingIconGroupController controller;

  final double defaultIconSize;
  final double defaultButtonSize;
  final Axis direction;

  const BreathingIconGroup({
    Key? key,
    required this.icons,
    required this.controller,
    this.defaultIconSize = 42,
    this.defaultButtonSize = 80,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  State<BreathingIconGroup> createState() => _BreathingIconGroupState();
}

class _BreathingIconGroupState extends State<BreathingIconGroup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _shadowSmall;
  late Animation<double> _shadowLarge;

  @override
  void initState() {
    super.initState();

    // 4-4 呼吸：4 秒循环
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.95,
          end: 1.07,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.07,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _shadowSmall = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.5,
          end: 6.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 6.0,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _shadowLarge = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 4.0,
          end: 16.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 16.0,
          end: 4.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    widget.controller.addListener(_syncController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncController);
    _controller.dispose();
    super.dispose();
  }

  void _syncController() {
    // 只要有按钮在呼吸就启动动画
    if (widget.controller.hasAnyActive) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
        _controller.reset();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.icons.map((cfg) {
      final isBreathing = widget.controller.activeKeys.contains(cfg.keyId);

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: BreathingIconItem(
          config: cfg,
          breathing: isBreathing,
          scale: _scale,
          shadowSmall: _shadowSmall,
          shadowLarge: _shadowLarge,
          defaultIconSize: widget.defaultIconSize,
          defaultButtonSize: widget.defaultButtonSize,
        ),
      );
    }).toList();

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return widget.direction == Axis.horizontal
            ? Row(mainAxisSize: MainAxisSize.min, children: children)
            : Column(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }
}
