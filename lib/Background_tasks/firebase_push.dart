import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FirebasePush {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static FirebasePush current = FirebasePush();

  Future<void> sendLegacyPushNotification(String title, String body) async {
    String? deviceToken = await _messaging.getToken();
    await FirebaseMessaging.instance.requestPermission();

    const String serverKey =
        'AAAAjFtT3oo:APA91bGVW6cBiJS2BwqtTYRm9EWppxgxnTezK988iw0f5ZK2n1yLLXjnAgJRnicNJmetgb9O4rEMpBA1iOwq6TNDL0JBPQKKnbzdN9JJSzUu5D-5VbI530OYOxN-tPs2A446n6wX5Lqw';
    const String fromUrl = 'https://fcm.googleapis.com/fcm/send';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
      'Sender': 'id=602827644554',
    };

    final Map<String, dynamic> message = {
      'notification': {
        'title': title,
        'body': body,
      },
      'to': deviceToken,
    };

    final response = await http.post(
      Uri.parse(fromUrl),
      headers: headers,
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
    } else {}
  }
}
