import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_instructions_card.dart';
import '../widgets/ticket_upload_card.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  void _showMockFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Aquesta funcionalitat de càrrega estarà disponible aviat."),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Registrar Compra",
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de instrucciones
            const TicketInstructionsCard(),
            const SizedBox(height: 24),
            
            // Tarjeta de subida de archivos
            TicketUploadCard(
              onCameraTap: () => _showMockFeedback(context),
              onGalleryTap: () => _showMockFeedback(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
