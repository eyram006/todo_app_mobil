import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  Future<String?> uploadFile(File file, String fileName, String taskId) async {
    try {
      final fileExt = fileName.split('.').last;
      final filePath =
          'tasks/$taskId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage.from('attachments').upload(filePath, file);

      final publicUrl = _supabase.storage
          .from('attachments')
          .getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Erreur upload fichier: $e');
    }
  }

  Future<String?> pickAndUploadImage(String taskId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return null;

      final file = File(image.path);
      final fileName = image.name;

      return await uploadFile(file, fileName, taskId);
    } catch (e) {
      throw Exception('Erreur sélection image: $e');
    }
  }

  Future<String?> pickAndUploadDocument(String taskId) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (file == null) return null;

      final fileObj = File(file.path);
      final fileName = file.name;

      return await uploadFile(fileObj, fileName, taskId);
    } catch (e) {
      throw Exception('Erreur sélection document: $e');
    }
  }

  Future<void> deleteFile(String fileUrl, String taskId) async {
    try {
      // Extraire le chemin du fichier depuis l'URL publique
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments
          .sublist(pathSegments.indexOf('attachments') + 1)
          .join('/');

      await _supabase.storage.from('attachments').remove([filePath]);
    } catch (e) {
      throw Exception('Erreur suppression fichier: $e');
    }
  }

  Future<List<String>> getTaskAttachments(String taskId) async {
    try {
      final files = await _supabase.storage
          .from('attachments')
          .list(path: 'tasks/$taskId');
      return files.map((file) {
        final filePath = 'tasks/$taskId/${file.name}';
        return _supabase.storage.from('attachments').getPublicUrl(filePath);
      }).toList();
    } catch (e) {
      debugPrint('Erreur récupération pièces jointes: $e');
      return [];
    }
  }

  String getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    return pathSegments.last;
  }

  String getFileExtensionFromUrl(String url) {
    final fileName = getFileNameFromUrl(url);
    return fileName.split('.').last.toLowerCase();
  }

  bool isImageFile(String url) {
    final ext = getFileExtensionFromUrl(url);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  bool isDocumentFile(String url) {
    final ext = getFileExtensionFromUrl(url);
    return ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'].contains(ext);
  }
}
