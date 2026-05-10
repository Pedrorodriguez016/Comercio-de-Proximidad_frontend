import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/auth_controller.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnamesController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary,
              Color(0xFFA6643C), 
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Crear Cuenta",
                    style: GoogleFonts.notoSerif(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Únete a nuestra comunidad",
                    style: GoogleFonts.manrope(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neutral.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: "Nombre",
                                  prefixIcon: Icon(Icons.person_outline, color: AppColors.secondary),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _surnamesController,
                                decoration: const InputDecoration(
                                  hintText: "Apellidos",
                                  prefixIcon: Icon(Icons.person_outline, color: AppColors.secondary),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: "Correo electrónico",
                                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.secondary),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: "Contraseña",
                                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.secondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        MaterialButton(
                          onPressed: authController.isLoading 
                            ? null 
                            : () async {
                                final success = await authController.register(
                                  _nameController.text, 
                                  _surnamesController.text, 
                                  _emailController.text, 
                                  _passwordController.text
                                );
                                if (success && context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                          height: 55,
                          minWidth: double.infinity,
                          color: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: authController.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Registrarse",
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "¿Ya tienes cuenta? Inicia sesión",
                            style: GoogleFonts.manrope(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
