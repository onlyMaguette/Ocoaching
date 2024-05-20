/*
import 'package:sendgrid_mailer/sendgrid_mailer.dart';

class EmailService {
  final String apiKey;

  EmailService(this.apiKey);

  Future<void> sendConfirmationEmail(
      String to, String date, String time) async {
    final mailer = Mailer(apiKey);
    final toAddress = Address(to);
    final fromAddress = Address('your-email@example.com');
    final content = Content(
        'text/plain', 'Votre rendez-vous est confirmé pour le $date à $time.');
    final subject = 'Confirmation de rendez-vous';

    final email = Email([toAddress], fromAddress, subject, content: [content]);

    try {
      await mailer.send(email);
      print('Email confirmation sent to $to for $date at $time');
    } catch (e) {
      print('Error sending confirmation email: $e');
    }
  }
}
*/
