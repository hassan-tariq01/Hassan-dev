import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart' as app_notification;
import '../auth/auth_service.dart';
import '../utils/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  RealtimeChannel? _notificationChannel;
  Function(List<app_notification.Notification>)? _onNotificationsUpdate;

  /// Initialize the notification service
  Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
    
    // Setup real-time subscription
    _setupRealtimeSubscription();
  }

  /// Setup real-time subscription for notifications
  void _setupRealtimeSubscription() {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) return;

    _notificationChannel = Supabase.instance.client
        .channel('notifications')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: AppConstants.tableNotifications,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: currentUser.id,
      ),
      callback: (payload) {
        _handleNotificationUpdate(payload);
      },
    )
        .subscribe();
  }

  /// Handle notification updates
  void _handleNotificationUpdate(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      if (newRecord != null) {
        final newNotification = app_notification.Notification.fromJson(newRecord);
        // Trigger callback if set
        if (_onNotificationsUpdate != null) {
          // This would typically fetch all notifications and call the callback
          // For now, we'll just log the new notification
          print('New notification: ${newNotification.message}');
        }
        
        // Show local notification
        _showLocalNotification(newNotification);
      }
    } catch (e) {
      print('Error handling notification update: $e');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(app_notification.Notification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'complaint_notifications',
      'Complaint Notifications',
      channelDescription: 'Notifications for complaint updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.message,
      details,
    );
  }

  /// Set callback for notification updates
  void setNotificationCallback(Function(List<app_notification.Notification>) callback) {
    _onNotificationsUpdate = callback;
  }

  /// Fetch notifications for a user
  Future<List<app_notification.Notification>> fetchNotifications(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from(AppConstants.tableNotifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => app_notification.Notification.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await Supabase.instance.client
          .from(AppConstants.tableNotifications)
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationChannel?.unsubscribe();
    _notificationChannel = null;
    _onNotificationsUpdate = null;
  }
}