import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sound_box/features/home/widgets/breathingIcon/breathing_icon_config.dart';

class BreathingIconItem extends StatelessWidget {
  final BreathingIconConfig config;
  final bool breathing;
  final Animation<double> scale;
  final Animation<double> shadowSmall;
  final Animation<double> shadowLarge;

  final double defaultIconSize;
  final double defaultButtonSize;

  const BreathingIconItem({
    Key? key,
    required this.config,
    required this.breathing,
    required this.scale,
    required this.shadowSmall,
    required this.shadowLarge,
    required this.defaultIconSize,
    required this.defaultButtonSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = config.iconSize ?? defaultIconSize;
    final buttonSize = config.buttonSize ?? defaultButtonSize;

    final double currentScale = breathing ? scale.value : 1.0;

    final shadows = breathing
        ? [
            BoxShadow(
              color: config.breatheColor.withOpacity(0.35),
              blurRadius: shadowLarge.value,
            ),
            BoxShadow(
              color: config.breatheColor.withOpacity(0.25),
              blurRadius: shadowSmall.value,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ];

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromRGBO(40, 44, 52, 0.9),
        boxShadow: shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: config.onTap,
          child: Center(
            child: Transform.scale(
              scale: currentScale,
              child: SvgPicture.asset(
                config.svgAsset!,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                  config.breatheColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
