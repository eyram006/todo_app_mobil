import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    // Initialiser Firebase
    await Firebase.initializeApp();

    // Demander la permission pour les notifications
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Permission status: ${settings.authorizationStatus}');

    // Obtenir le token FCM
    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      await _saveTokenToSupabase(fcmToken);
    }

    // Écouter les changements de token
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToSupabase);

    // Gérer les messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Gérer les messages au premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('profiles')
          .update({
            'fcm_token': token,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      debugPrint('Erreur sauvegarde token FCM: $e');
    }
  }

  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Récupérer le token FCM du destinataire
      final response = await _supabase
          .from('profiles')
          .select('fcm_token')
          .eq('id', recipientId)
          .single();

      final fcmToken = response['fcm_token'] as String?;
      if (fcmToken == null) {
        debugPrint('Aucun token FCM trouvé pour l\'utilisateur $recipientId');
        return;
      }

      // Ici, vous devriez envoyer la notification via votre serveur backend
      // ou utiliser une fonction Supabase Edge pour envoyer via FCM
      // Pour l'instant, on simule avec un appel direct (non recommandé en prod)

      debugPrint('Notification envoyée à $recipientId: $title - $body');

      // Sauvegarder la notification en base pour historique
      await _supabase.from('notifications').insert({
        'recipient_id': recipientId,
        'title': title,
        'body': body,
        'data': data,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Erreur envoi notification: $e');
    }
  }

  Future<void> sendProjectNotification({
    required String projectId,
    required List<String> memberIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    for (final memberId in memberIds) {
      await sendNotification(
        recipientId: memberId,
        title: title,
        body: body,
        data: {'type': 'project', 'project_id': projectId, ...?data},
      );
    }
  }

  Future<void> sendTaskNotification({
    required String taskId,
    required String projectId,
    required List<String> memberIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    for (final memberId in memberIds) {
      await sendNotification(
        recipientId: memberId,
        title: title,
        body: body,
        data: {
          'type': 'task',
          'task_id': taskId,
          'project_id': projectId,
          ...?data,
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erreur récupération notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Erreur marquage notification lue: $e');
    }
  }
}

// Gestionnaire pour les messages en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Message en arrière-plan: ${message.messageId}');
}

// Gestionnaire pour les messages au premier plan
void _handleForegroundMessage(RemoteMessage message) {
  debugPrint('Message au premier plan: ${message.notification?.title}');
}
