import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5E35B1);
  static const Color primaryLight = Color(0xFF7E57C2);
  static const Color primaryDark = Color(0xFF4527A0);
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5);
  static const Color text = Colors.black87;
  static const Color secondaryText = Colors.grey;
  static const Color accent = Colors.orange;
  static const Color success = Colors.green;
  static const Color error = Colors.red;
}

class AppStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.secondaryText,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: BorderSide(color: AppColors.primary),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static CardTheme cardTheme = CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    clipBehavior: Clip.antiAlias,
  );
}

class AppSpacing {
  static const EdgeInsetsGeometry small = EdgeInsets.all(8.0);
  static const EdgeInsetsGeometry medium = EdgeInsets.all(16.0);
  static const EdgeInsetsGeometry large = EdgeInsets.all(24.0);

  // Define specific getters for top and left if needed
  static EdgeInsetsGeometry get smallTop => EdgeInsets.only(top: 8.0);
  static EdgeInsetsGeometry get smallLeft => EdgeInsets.only(left: 8.0);
  static EdgeInsetsGeometry get mediumTop => EdgeInsets.only(top: 16.0);
  static EdgeInsetsGeometry get mediumLeft => EdgeInsets.only(left: 16.0);
  static EdgeInsetsGeometry get largeTop => EdgeInsets.only(top: 24.0);
  static EdgeInsetsGeometry get largeLeft => EdgeInsets.only(left: 24.0);
}

class AppFontSizes {
  static const double small = 12.0;
  static const double body = 16.0;
  static const double subheading = 18.0;
  static const double heading = 24.0;
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 700);
}
