import 'package:flutter/material.dart';

/// 呼吸灯效果的图标，默认不启动动画，便于按需节省帧消耗。
const Duration kBreathingLightDuration = Duration(seconds: 4);

class BreathingLightIcon extends StatefulWidget {
  const BreathingLightIcon({
    super.key,
    required this.icon,
    required this.color,
    this.animate = false,
    this.duration = kBreathingLightDuration,
    this.size = 24,
    this.sharedProgress,
  });

  final IconData icon;
  final Color color;

  /// 是否启动呼吸动画，默认关闭以减少首屏开销。
  final bool animate;

  /// 统一的动画时长，保持首页多按钮频率一致。
  final Duration duration;

  /// 图标大小，保持与按钮布局一致。
  final double size;

  /// 共享的进度动画，用于多按钮同步动画值。
  final Animation<double>? sharedProgress;

  @override
  State<BreathingLightIcon> createState() => _BreathingLightIconState();
}

class _BreathingLightIconState extends State<BreathingLightIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _progressAnimation;

  @override
  void initState() {
    super.initState();
    _rebuildAnimation();
  }

  @override
  void didUpdateWidget(covariant BreathingLightIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final durationChanged = oldWidget.duration != widget.duration;
    if (durationChanged && _controller != null) {
      _controller!.duration = widget.duration;
    }
    final sharedChanged = oldWidget.sharedProgress != widget.sharedProgress;
    final animateChanged = oldWidget.animate != widget.animate;
    if (sharedChanged || animateChanged || durationChanged) {
      _rebuildAnimation();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.color;
    final animation = widget.sharedProgress ?? _progressAnimation;

    if (!widget.animate || animation == null) {
      return Icon(widget.icon, color: iconColor, size: widget.size);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double progress = animation.value.clamp(0.0, 1.0).toDouble();
        final animatedColor = Color.lerp(
          widget.color,
          widget.color.withOpacity(0.5),
          progress,
        );
        return Icon(
          widget.icon,
          color: animatedColor ?? iconColor,
          size: widget.size,
        );
      },
    );
  }

  void _rebuildAnimation() {
    // 如果有外部动画，则不创建自己的 controller，直接复用以保证所有图标值一致。
    if (widget.sharedProgress != null) {
      _controller?.dispose();
      _controller = null;
      _progressAnimation = widget.sharedProgress;
      return;
    }

    if (widget.animate) {
      _controller ??= AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      _progressAnimation ??= CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      );
      if (!(_controller!.isAnimating)) {
        _controller!.repeat(reverse: true);
      }
      return;
    }

    // 停止动画可避免闲置 ticker 占用帧，但保留 controller 以便快速再次启动。
    if (_controller?.isAnimating == true) {
      _controller!.stop();
      _controller!.value = 0;
    }
    _progressAnimation = null;
  }
}
