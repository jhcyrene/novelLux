import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NovelLuxBrand extends StatelessWidget {
  const NovelLuxBrand({
    super.key,
    this.fontSize = 28,
    this.color,
    this.padding = EdgeInsets.zero,
    this.text = 'NoveLux',
  });

  final double fontSize;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image.asset(
          //   'assets/images/logo2.png',
          //   height: fontSize + 15,
          //   fit: BoxFit.contain,
          // ),
          // const SizedBox(width: 8),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: GoogleFonts.bodoniModa(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: color ??
                  theme.appBarTheme.foregroundColor ??
                  theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}