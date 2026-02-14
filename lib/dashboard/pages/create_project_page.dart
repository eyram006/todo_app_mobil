import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';
import '../services/project_service.dart';

// --- Palette de couleurs "TODO" (Même que Dashboard) ---
const Color primaryBlue = Color(0xFF21B6EC);
const Color surfaceColor = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF161E2B);
const Color textGrey = Color(0xFF6B7280);
const Color backgroundColor = Color(0xFFF9FAFB);
const Color errorRed = Color(0xFFF44336);

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedStatus = 'to do';
  DateTime? _selectedDeadline;
  bool _isLoading = false;

  final ProjectService _projectService = ProjectService();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vous devez être connecté pour créer un projet."),
            backgroundColor: errorRed,
          ),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    final newProject = Project(
      id: '', // L'ID sera généré par la base de données
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      deadline: _selectedDeadline,
      ownerId: user.id,
    );

    try {
      await _projectService.createProject(newProject);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Projet créé avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retourne true pour signaler le succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la création : ${e.toString()}"),
            backgroundColor: errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Nouveau Projet",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: surfaceColor,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: textDark),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Détails du projet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Remplissez les informations ci-dessous pour créer un nouveau projet.",
                style: TextStyle(color: textGrey, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Champ Nom du projet
              _buildLabel("Nom du projet"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Ex: Refonte du site web"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom du projet est requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Champ Description
              _buildLabel("Description (Optionnel)"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration("Décrivez l'objectif du projet..."),
              ),

              const SizedBox(height: 24),

              // Sélecteur de Statut
              _buildLabel("Statut initial"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: _inputDecoration("Sélectionnez le statut"),
                items: const [
                  DropdownMenuItem(value: 'to do', child: Text("À faire")),
                  DropdownMenuItem(value: 'in progress', child: Text("En cours")),
                  DropdownMenuItem(value: 'done', child: Text("Terminé")),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedStatus = value);
                },
              ),

              const SizedBox(height: 24),

              // Sélecteur de Date limite
              _buildLabel("Date limite (Optionnel)"),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: textGrey, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDeadline == null
                            ? "Sélectionner une date"
                            : "${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}",
                        style: TextStyle(
                          color: _selectedDeadline == null ? textGrey : textDark,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedDeadline != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedDeadline = null),
                          child: const Icon(Icons.close, color: textGrey, size: 20),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Bouton de création
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Créer le projet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    );
  }
}
