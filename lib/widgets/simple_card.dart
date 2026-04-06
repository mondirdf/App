import 'package:flutter/material.dart';

import '../theme_constants.dart';

class SimpleCard extends StatelessWidget {
  const SimpleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
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
        borderRadius: BorderRadius.circular(kCornerRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(-6, -6), blurRadius: 12),
          BoxShadow(color: Color(0xFFD0D0D0), offset: Offset(6, 6), blurRadius: 12),
        ],
      ),
      child: child,
    );
  }
}
