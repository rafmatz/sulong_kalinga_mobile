import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    final response = await _client
        .from('mobile_notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}