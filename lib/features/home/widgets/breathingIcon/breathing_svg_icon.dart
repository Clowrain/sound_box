import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BreathingSvgIcon extends StatelessWidget {
  const BreathingSvgIcon({
    super.key,
    required this.asset,
    required this.color,
    required this.size,
    required this.isBreathing,
    this.progress,
  });

  final String asset;
  final Color color;
  final double size;
  final bool isBreathing;
  final Animation<double>? progress;

  @override
  Widget build(BuildContext context) {
    final animation = progress;
    if (!isBreathing || animation == null) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value.clamp(0.0, 1.0);
        final scale = _lerp(0.95, 1.07, t);
        final shadowSmall = _lerp(1.5, 6.0, t);
        final shadowLarge = _lerp(4.0, 16.0, t);
        final animatedColor =
            Color.lerp(color, color.withOpacity(0.5), t) ?? color;

        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: shadowLarge,
              ),
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: shadowSmall,
              ),
            ],
          ),
          child: Transform.scale(
            scale: scale,
            child: SvgPicture.asset(
              asset,
              width: size,
              height: size,
              colorFilter: ColorFilter.mode(
                animatedColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        );
      },
    );
  }

  double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }
}
