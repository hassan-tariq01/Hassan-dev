import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final _supabase = Supabase.instance.client;

  // TODO: Implement real-time notification subscription
  Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId);
  }
}