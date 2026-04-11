import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TypeBadge extends StatelessWidget {
  final String type;
  final bool small;

  const TypeBadge({super.key, required this.type, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getTypeColor(type);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical:   small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}