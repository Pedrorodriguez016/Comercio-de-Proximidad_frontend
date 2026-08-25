import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/commerce_model.dart';
import '../theme/app_theme.dart';
import '../screens/commerce_detail_screen.dart';

class CommerceCard extends StatelessWidget {
  final CommerceModel commerce;

  const CommerceCard({
    super.key,
    required this.commerce,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommerceDetailScreen(commerce: commerce),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.store,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commerce.name,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    commerce.address,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AppColors.neutral,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatCategory(commerce.category),
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.neutral,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('aliment')) return 'Alimentació';
    if (lower.contains('ropa') || lower.contains('roba')) return 'Roba';
    if (lower.contains('servei') || lower.contains('servicio')) return 'Serveis';
    if (lower.contains('restaurac')) return 'Restauració';
    if (lower.contains('cultur')) return 'Cultura';
    if (lower.contains('salu')) return 'Salut';
    return cat;
  }
}
