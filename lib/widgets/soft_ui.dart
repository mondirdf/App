import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme_constants.dart';

class SoftContainer extends StatelessWidget {
  const SoftContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = kSoftRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: kLightShadowColor,
            offset: kLightShadowOffset,
            blurRadius: kSoftBlur,
          ),
          BoxShadow(
            color: kDarkShadowColor,
            offset: kDarkShadowOffset,
            blurRadius: kSoftBlur,
          ),
        ],
      ),
      child: child,
    );
  }
}

class InsetContainer extends StatelessWidget {
  const InsetContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = kSoftRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x55FFFFFF),
            offset: kLightShadowOffset,
            blurRadius: 10,
            blurStyle: BlurStyle.inner,
          ),
          BoxShadow(
            color: Color(0x22000000),
            offset: kDarkShadowOffset,
            blurRadius: 12,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: child,
    );
  }
}

class SoftButton extends StatelessWidget {
  const SoftButton.primary({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  })  : isPrimary = true,
        isCircular = false;

  const SoftButton.secondary({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isCircular = false,
  }) : isPrimary = false;

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isCircular;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(isCircular ? 999 : 16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: isCircular ? 12 : 16,
            vertical: isCircular ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: isPrimary ? kPrimaryColor : kBackgroundColor,
            borderRadius: radius,
            boxShadow: isPrimary
                ? const <BoxShadow>[]
                : const <BoxShadow>[
                    BoxShadow(
                      color: kLightShadowColor,
                      offset: kLightShadowOffset,
                      blurRadius: kSoftBlur,
                    ),
                    BoxShadow(
                      color: kDarkShadowColor,
                      offset: kDarkShadowOffset,
                      blurRadius: kSoftBlur,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: isCircular ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: isPrimary ? Colors.white : kPrimaryColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : kPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
