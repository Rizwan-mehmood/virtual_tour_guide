import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(
    0xFF85754E,
  ); // Gold accent from Louvre Abu Dhabi
  static const Color secondaryColor = Color(
    0xFF1D252D,
  ); // Dark blue-gray like the museum dome
  static const Color accentColor = Color(0xFFC8B273); // Lighter gold

  // Background Colors
  static const Color scaffoldBackgroundColor = Color(0xFFF8F8F8);
  static const Color cardColor = Colors.white;
  static const Color darkCardColor = Color(0xFF2C3540);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF2D2D2D);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textLightColor = Color(0xFFF8F8F8);

  // Icon Colors
  static const Color iconColor = primaryColor;
  static const Color iconLightColor = Colors.white;

  // Button Colors
  static const Color buttonColor = primaryColor;
  static const Color buttonTextColor = Colors.white;

  // Error Colors
  static const Color errorColor = Color(0xFFD32F2F);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGradient = LinearGradient(
    colors: [secondaryColor, Color(0xFF3D4550)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Themes
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: textPrimaryColor,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
      color: textPrimaryColor,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: textPrimaryColor,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontSize: 22.0,
      fontWeight: FontWeight.w600,
      color: textPrimaryColor,
    ),
    titleLarge: GoogleFonts.lato(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: textPrimaryColor,
    ),
    titleMedium: GoogleFonts.lato(
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
      color: textPrimaryColor,
    ),
    titleSmall: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: textPrimaryColor,
    ),
    bodyLarge: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: textSecondaryColor,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: textSecondaryColor,
    ),
    bodySmall: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: textSecondaryColor,
    ),
    labelLarge: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: textPrimaryColor,
    ),
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
      background: scaffoldBackgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onBackground: textPrimaryColor,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: iconColor),
      titleTextStyle: textTheme.titleLarge,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: buttonTextColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: textTheme.labelLarge?.copyWith(color: buttonTextColor),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: textTheme.labelLarge?.copyWith(color: primaryColor),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      disabledColor: Colors.grey[200],
      selectedColor: primaryColor.withOpacity(0.2),
      secondarySelectedColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: textTheme.bodyMedium,
      secondaryLabelStyle: textTheme.bodyMedium?.copyWith(color: primaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: Colors.grey[300]!),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
      space: 24,
    ),
    iconTheme: const IconThemeData(color: iconColor),
    textTheme: textTheme,
  );
}

// Reusable widgets for the Louvre Abu Dhabi app
class AppWidgets {
  // Custom app bar
  static PreferredSizeWidget appBar(
    String title, {
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    return AppBar(
      title: Text(
        title,
        style: AppTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      elevation: 0,
    );
  }

  // Gradient button
  static Widget gradientButton(
    String text,
    VoidCallback onPressed, {
    Gradient gradient = AppTheme.primaryGradient,
    double borderRadius = 12.0,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
    ),
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: AppTheme.textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  // Exhibition card
  static Widget exhibitionCard(
    String title,
    String imageUrl,
    String date,
    VoidCallback onTap,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with gradient overlay
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    title,
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Date
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: AppTheme.textTheme.bodyMedium),
                  Icon(
                    Icons.arrow_forward,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Information section with icon
  static Widget infoSection(
    String title,
    String content,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(content, style: AppTheme.textTheme.bodyMedium),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Artwork grid item
  static Widget artworkGridItem(
    String imageUrl,
    String title,
    String artist,
    VoidCallback onTap,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    style: AppTheme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section title
  static Widget sectionTitle(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
