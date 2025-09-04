import 'dart:ui';

class AppColor {
  // Dark theme base
  static Color background = const Color(0xFF0B0F17); // app background
  static Color surface = const Color(0xFF0F1724); // cards / panels
  static Color cardBorder = const Color(0xFF1E2633);

  // Gradients
  static Color gradientFirst = const Color(0xFF0D1B2A);
  static Color gradientSecond = const Color(0xFF162535);

  // Text
  static Color textPrimary = const Color(0xFFE6EEF6);
  static Color textSecondary = const Color(0xFF9FB3C8);

  // Accent / actions
  static Color audioBlueBackground = const Color(0xFF2EA0FF);
  static Color audioBluishBackground = const Color(0xFF193547);
  static Color audioGreyBackground = const Color(0xFF11161C);
  static Color menu1Color = const Color(0xFFB8922B);
  static Color menu2Color = const Color(0xFFCF5A45);
  static Color menu3Color = const Color(0xFF2FB6E4);

  static Color starColor = const Color(0xFFF2C94C);
  static Color loveColor = const Color(0xFFEB5A7A);
  static Color subTitleText = const Color(0xFF7E94A6);
  // backward-compatible names (mapped to dark equivalents)
  static Color homePageBackground = background;
  // gradientFirst / gradientSecond already defined above
  static Color homePageTitle = textPrimary;
  static Color homePageSubtitle = textSecondary;
  static Color homePageDetail = audioBlueBackground;
  static Color homePageIcons = textPrimary;
  static Color homePageContainerTextSmall = textSecondary;
  static Color homePageContainerTextBig = textPrimary;
  static Color homePagePlanColor = const Color(0xFF4B5563);
  static Color coursePageTopIconColor = const Color(0xFF2A3B4A);
  static Color coursePageTitleColor = textPrimary;
  static Color coursePageContainerGradient1stColor = const Color(0xFF233242);
  static Color coursePageContainerGradient2ndColor = const Color(0xFF2A3B4A);
  static Color coursePageIconColor = textPrimary;
  static Color loopColor = audioBlueBackground;
  static Color setsColor = const Color(0xFF6B7280);
  static Color circuitsColor = const Color(0xFF111827);
  static Color creamColor = surface;
  static Color loginButtonColor = const Color(0xFF283544);
  static Color tabVarViewColor = surface;
  // aliases already reference the main fields above where appropriate
}
