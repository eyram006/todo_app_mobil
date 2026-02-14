import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/dashboard/pages/dashbord_page.dart';

const Color primaryBlue = Color(0xFF21B6EC);
const Color textDark = Color(0xFF161E2B);
const Color textGrey = Color(0xFF6B7280);
const Color lightBlueBg = Color(0xFFE0F7FA);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  bool _loading = false;

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedCountry;
  bool _obscurePassword = true;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre adresse e-mail';
    }
    // Validation temporaire simplifiée pour les tests
    if (!value.contains('@')) {
      return 'Veuillez entrer une adresse e-mail valide';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro';
    }
    // Validation temporaire simplifiée pour les tests
    if (value.length < 8) {
      return 'Numéro trop court';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un nom d\'utilisateur';
    }
    if (value.length < 2) {
      return 'Au moins 2 caractères requis';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 4) {
      return 'Au moins 4 caractères requis';
    }
    return null;
  }

  String? _validateCountry(String? value) {
    // Validation temporaire désactivée pour les tests
    return null;
  }

  Future<void> _register() async {
    print('🔄 Début de la méthode _register');

    if (!_formKey.currentState!.validate()) {
      print('❌ Validation du formulaire échouée');
      return;
    }

    print('✅ Validation du formulaire réussie');
    setState(() => _loading = true);

    try {
      print(
        '📧 Tentative d\'inscription avec email: ${_emailController.text.trim()}',
      );

      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print(
        '📨 Réponse de signUp reçue: ${response.user != null ? 'Utilisateur créé' : 'Utilisateur null'}',
      );

      final user = response.user;
      if (user == null) {
        print('❌ Utilisateur null après signUp');
        throw 'Erreur lors de la création du compte';
      }

      print('👤 Utilisateur créé avec ID: ${user.id}');

      // Vérification de sécurité pour _selectedCountry
      final countryCode =
          _selectedCountry ?? '+228'; // Code par défaut pour le Togo
      print('🌍 Pays sélectionné: $countryCode');

      print('💾 Insertion du profil dans la base de données...');
      await supabase.from('profiles').insert({
        'id': user.id,
        'username': _usernameController.text.trim(),
        'phone': countryCode + _phoneController.text.trim(),
        'country': countryCode,
      });

      print('✅ Profil inséré avec succès');

      if (!mounted) {
        print('⚠️ Widget non monté, arrêt');
        return;
      }

      print('🎉 Affichage du message de succès');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inscription réussie 🎉')));

      print('🏠 Navigation vers le Dashboard');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } on AuthException catch (e) {
      print('❌ Erreur AuthException: ${e.message}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      print('❌ Erreur générale: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    print('🔄 Fin de la méthode _register, remise à zéro du loading');
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Créer un compte',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/Logo_ToDo.svg',
                      height: 70,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration(
                      label: 'E-mail',
                      icon: Icons.email_outlined,
                    ),
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 20),

                  // USERNAME
                  TextFormField(
                    controller: _usernameController,
                    decoration: _inputDecoration(
                      label: 'Nom d\'utilisateur',
                      icon: Icons.person_outline,
                    ),
                    validator: _validateUsername,
                  ),

                  const SizedBox(height: 20),

                  // PHONE ROW FIXED
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicWidth(
                        child: FormField<String>(
                          validator: _validateCountry,
                          builder: (state) {
                            return Container(
                              decoration: BoxDecoration(
                                color: lightBlueBg.withAlpha(
                                  (0.6 * 255).toInt(),
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                              ),
                              child: CountryCodePicker(
                                onChanged: (country) {
                                  setState(() {
                                    _selectedCountry = country.dialCode;
                                  });
                                  state.didChange(country.dialCode);
                                },
                                initialSelection: 'TG',
                                showOnlyCountryWhenClosed: true,
                                showDropDownButton: true,
                                showFlag: true,
                                alignLeft: true,
                                favorite: const ['TG', 'FR', 'US'],
                                padding: EdgeInsets.zero,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: _inputDecoration(
                            label: 'Numéro',
                            icon: Icons.phone_outlined,
                          ),
                          validator: _validatePhone,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      label: 'Mot de passe',
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'S\'inscrire',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryBlue),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: lightBlueBg.withAlpha((0.6 * 255).toInt()),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}
