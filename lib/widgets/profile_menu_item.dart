import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.onBackground,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.neutral),
      onTap: onTap,
    );
  }
}
