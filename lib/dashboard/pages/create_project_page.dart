import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/theme.dart';

import '../models/project.dart';
import '../services/project_service.dart';

// Use AppColors directly

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
            backgroundColor: AppColors.error,
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
            backgroundColor: AppColors.error,
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
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Nouveau Projet",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textDark),
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
                "Créer un nouveau projet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Remplissez les informations ci-dessous pour créer votre projet.",
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Champ Nom du projet
              _buildLabel("Nom du projet *"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Exemple : Refonte du site web"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom du projet est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Champ Description
              _buildLabel("Description (facultatif)"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(
                  "Décrivez brièvement l'objectif et les détails de votre projet...",
                ),
              ),

              const SizedBox(height: 24),

              // Sélecteur de Statut
              _buildLabel("Statut initial"),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: InputDecoration(
                    hintText: "Choisissez le statut de départ",
                    hintStyle: TextStyle(
                      color: AppColors.textGrey.withOpacity(0.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'to do',
                      child: Row(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            color: AppColors.lightBlue,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "À faire",
                            style: TextStyle(color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'in progress',
                      child: Row(
                        children: [
                          Icon(
                            Icons.sync,
                            color: AppColors.lightGreen,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "En cours",
                            style: TextStyle(color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'done',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.lightPurple,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Terminé",
                            style: TextStyle(color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedStatus = value);
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textGrey,
                  ),
                  dropdownColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sélecteur de Date limite
              _buildLabel("Date limite (facultatif)"),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: _selectedDeadline != null
                            ? AppColors.primary
                            : AppColors.textGrey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDeadline == null
                              ? "Choisir une date limite"
                              : "${_selectedDeadline!.day.toString().padLeft(2, '0')}/${_selectedDeadline!.month.toString().padLeft(2, '0')}/${_selectedDeadline!.year}",
                          style: TextStyle(
                            color: _selectedDeadline == null
                                ? AppColors.textGrey.withOpacity(0.5)
                                : AppColors.textDark,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (_selectedDeadline != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedDeadline = null),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                        )
                      else
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textGrey,
                          size: 24,
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
                    backgroundColor: AppColors.primary,
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
        color: AppColors.textDark,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.5)),
      filled: true,
      fillColor: AppColors.surface,
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
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
