import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailService {
  final String apiKey;
  final String baseUrl;

  EmailService(this.apiKey, this.baseUrl);

  Future<void> sendConfirmationEmail(
      String to, String date, String time) async {
    final url = Uri.parse('$baseUrl/email/2/send');
    final headers = {
      'Authorization': 'App $apiKey',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({
      'from': {'email': 'your-email@example.com'},
      'to': [
        {'email': to}
      ],
      'subject': 'Confirmation de rendez-vous',
      'text': 'Votre rendez-vous est confirmé pour le $date à $time.',
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Email confirmation sent to $to for $date at $time');
      } else {
        print('Failed to send email: ${response.body}');
      }
    } catch (e) {
      print('Error sending confirmation email: $e');
    }
  }
}
