import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/purchase_model.dart';
import '../theme/app_theme.dart';

class PurchaseCard extends StatelessWidget {
  final PurchaseModel purchase;
  final String? resolvedCommerceName;

  const PurchaseCard({
    super.key,
    required this.purchase,
    this.resolvedCommerceName,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName =
        (resolvedCommerceName != null && resolvedCommerceName!.isNotEmpty)
        ? resolvedCommerceName!
        : (purchase.commerceName.isNotEmpty
              ? purchase.commerceName
              : 'Comerç Associat');

    final String dateStr =
        "${purchase.date.day.toString().padLeft(2, '0')}/${purchase.date.month.toString().padLeft(2, '0')}/${purchase.date.year}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.onBackground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.neutral,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${purchase.amount.toStringAsFixed(2)} €",
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "+${purchase.pointsEarned.toInt()} pts",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
