import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/auth_controller.dart';
import '../theme/app_theme.dart';
import '../utils/password_validator.dart';
import '../widgets/password_input_section.dart';
import '../widgets/address_autocomplete_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnamesController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  PasswordValidationResult? _passwordValidation;

  @override
  void dispose() {
    _nameController.dispose();
    _surnamesController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

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
                    "Crear compte",
                    style: GoogleFonts.notoSerif(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Uneix-te a la nostra comunitat",
                    style: GoogleFonts.manrope(
                      color: Colors.white.withValues(alpha: 0.8),
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
                                color: AppColors.neutral.withValues(alpha: 0.1),
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
                                  hintText: "Nom",
                                  prefixIcon: Icon(Icons.person_outline, color: AppColors.secondary),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _surnamesController,
                                decoration: const InputDecoration(
                                  hintText: "Cognoms",
                                  prefixIcon: Icon(Icons.person_outline, color: AppColors.secondary),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: "Correu electrònic",
                                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.secondary),
                                ),
                              ),
                              const SizedBox(height: 15),
                              // Secció modular de Contrasenya i Confirmació amb Validació
                              PasswordInputSection(
                                passwordController: _passwordController,
                                confirmPasswordController: _confirmPasswordController,
                                onChanged: (result) {
                                  _passwordValidation = result;
                                },
                              ),
                              const SizedBox(height: 15),
                              // Secció modular d'Adreça Autocompletada amb OpenStreetMap (Nominatim)
                              AddressAutocompleteField(
                                addressController: _addressController,
                                cityController: _cityController,
                                postalCodeController: _postalCodeController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        MaterialButton(
                          onPressed: authController.isLoading
                              ? null
                              : () async {
                                  if (_nameController.text.trim().isEmpty ||
                                      _emailController.text.trim().isEmpty ||
                                      _passwordController.text.trim().isEmpty ||
                                      _confirmPasswordController.text.trim().isEmpty ||
                                      _addressController.text.trim().isEmpty ||
                                      _cityController.text.trim().isEmpty ||
                                      _postalCodeController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Si us plau, omple tots els camps")),
                                    );
                                    return;
                                  }

                                  final passVal = _passwordValidation ??
                                      PasswordValidator.validate(
                                        _passwordController.text,
                                        _confirmPasswordController.text,
                                      );

                                  if (!passVal.isValid) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(passVal.errorMessage ?? "La contrasenya no compleix els requisits"),
                                      ),
                                    );
                                    return;
                                  }

                                  final success = await authController.register(
                                    _nameController.text.trim(),
                                    _surnamesController.text.trim(),
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                    _addressController.text.trim(),
                                    _cityController.text.trim(),
                                    _postalCodeController.text.trim(),
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
                                  "Registrar-se",
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
                            "Ja tens un compte? Inicia sessió",
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
