import 'package:flutter/material.dart';

import '../theme_constants.dart';

class SimpleCard extends StatelessWidget {
  const SimpleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: kBackgroundColor,
        border: Border.all(color: kBorderColor),
        borderRadius: BorderRadius.circular(kCornerRadius),
      ),
      child: child,
    );
  }
}
