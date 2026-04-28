import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final Color? color;
  final bool showShadow;
  final bool showBorder;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.color,
    this.showShadow = true,
    this.showBorder = true,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: AppColors.border) : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
