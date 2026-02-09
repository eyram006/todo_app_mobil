import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour les input formatters
import 'package:flutter_svg/flutter_svg.dart'; // Si tu veux utiliser des SVGs
import 'package:country_code_picker/country_code_picker.dart';

// Réutiliser les couleurs définies dans welcome.dart si elles sont globales,
// sinon, redéfinis-les ici ou importe-les.
// Pour cet exemple, je vais les redéfinir pour que le code soit autonome.
const Color primaryBlue = Color(0xFF21B6EC);
const Color textDark = Color(0xFF161E2B);
const Color textGrey = Color(0xFF6B7280);
const Color lightBlueBg = Color(0xFFE0F7FA); // Inspiré de _FeatureCard




class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variables pour stocker la sélection du pays (simple liste pour l'exemple)
  String? _selectedCountry;
  // mot de passe masqué par défaut
  bool _obscurePassword = true;

  // Validation des champs
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre adresse e-mail';
    }
    // Regex simple pour l'e-mail
    if (!RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b').hasMatch(value)) {
      return 'Veuillez entrer une adresse e-mail valide';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    // Supprimer les espaces, tirets ou parenthèses pour simplifier la validation
    String phone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Vérifier le format : +optionnel suivi de 10 à 12 chiffres
    if (!RegExp(r'^\+?[0-9]{10,12}$').hasMatch(phone)) {
      return 'Veuillez entrer un numéro de téléphone valide (10 à 12 chiffres)';
    }
    return null;
  }


  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un nom d\'utilisateur';
    }
    if (value.length < 3) {
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    //règles plus strictes (au moins une majuscule, une minuscule, un chiffre, un symbole)
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une lettre et un chiffre';
    }
    return null;
  }

  String? _validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner votre pays';
    }
    return null;
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Les informations sont valides, tu peux maintenant procéder à l'enregistrement
      // Par exemple, afficher un message de succès ou naviguer vers une autre page.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enregistrement réussi !')),
      );
      // Exemple de navigation :
      Navigator.pushReplacementNamed(context, '/login'); // Si tu as une page de connexion
      Navigator.pop(context); // Pour revenir à la page précédente
    }
  }

  @override
  void dispose() {
    // Nettoyer les contrôleurs lorsqu'ils ne sont plus nécessaires
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
        elevation: 1, // Pas d'ombre sous l'AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  // Optionnel : Ajouter un SVG ou une image ici
                  Center(
                    child: SvgPicture.asset('assets/images/Logo_ToDo.svg', height: 70),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Remplissez les informations ci-dessous pour commencer.',
                    style: TextStyle(
                      fontSize: 15,
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Champ Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: const Icon(Icons.email_outlined, color: primaryBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: lightBlueBg.withAlpha((0.6 * 255).toInt()),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    validator: _validateEmail,
                    onSaved: (value) => _emailController.text = value ?? '',
                  ),
                  const SizedBox(height: 20),

                  // Champ Numéro de téléphone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[+\d\s()-]')), // Permet chiffres, +, espaces, (), inutile-
                    ],
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone',
                      prefixIcon: const Icon(Icons.phone_outlined, color: primaryBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: lightBlueBg.withAlpha((0.6 * 255).toInt()),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    validator: _validatePhone,
                    onSaved: (value) => _phoneController.text = value ?? '',
                  ),
                  const SizedBox(height: 20),

                  // Champ Nom d'utilisateur
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      prefixIcon: const Icon(Icons.person_outline, color: primaryBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: lightBlueBg.withAlpha((0.6 * 255).toInt()),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    validator: _validateUsername,
                    onSaved: (value) => _usernameController.text = value ?? '',
                  ),
                  const SizedBox(height: 20),

                  // Champ Pays
                  FormField<String>(
                    validator: _validateCountry,
                    builder: (state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Pays',
                          prefixIcon: const Icon(Icons.flag_outlined, color: primaryBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: lightBlueBg.withAlpha((0.6 * 255).toInt()),
                          contentPadding: const EdgeInsets.symmetric(vertical: 1.0),
                        ),
                        child: CountryCodePicker(
                          onChanged: (country) {
                            setState(() {
                              _selectedCountry = country.name;
                            });
                            state.didChange(country.name); // met à jour le FormField
                          },
                          initialSelection: 'TG',
                          showCountryOnly: true,
                          showDropDownButton: true,
                          alignLeft: true,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Champ Mot de passe

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // Cache le mot de passe
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline, color: primaryBlue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword; // bascule l’état
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: lightBlueBg.withAlpha((0.6 * 255).toInt()),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    validator: _validatePassword,
                    onSaved: (value) => _passwordController.text = value ?? '',
                  ),
                  const SizedBox(height: 32),

                  // Bouton d'enregistrement
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _register,
                      child: const Text(
                        'S\'inscrire',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70, // Assure-toi que le texte est lisible
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Lien pour se connecter (si l'utilisateur a déjà un compte)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vous avez déjà un compte ?',
                        style: TextStyle(color: textGrey, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigation vers la page de connexion
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          'Connectez-vous',
                          style: TextStyle(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}