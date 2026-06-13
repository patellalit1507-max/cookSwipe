import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// FSSAI-style veg/non-veg mark: green square+dot for veg, red for non-veg.
class VegIndicator extends StatelessWidget {
  const VegIndicator({super.key, required this.isVeg, this.size = 18});

  final bool isVeg;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppTheme.vegGreen : AppTheme.nonVegRed;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 1.6),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.45,
        height: size * 0.45,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
