import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class FrostedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Color? borderColor;

  const FrostedCard({
    Key? key,
    required this.child,
    this.padding,
    this.borderRadius = 24.0,
    this.blur = 15.0,
    this.color,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(key) {
    final isDark = Theme.of(key).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 20.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: color ??
                  (isDark
                      ? AppColors.glassBackgroundDark
                      : AppColors.glassBackgroundLight),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ??
                    (isDark
                        ? AppColors.glassBorderDark
                        : AppColors.glassBorderLight),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
