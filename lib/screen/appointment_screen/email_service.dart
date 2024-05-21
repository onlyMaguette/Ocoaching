import 'package:sendgrid_mailer/sendgrid_mailer.dart';

class EmailService {
  final String apiKey;

  EmailService(this.apiKey);

  Future<void> sendConfirmationEmail(
      String to, String date, String time) async {
    final mailer = Mailer(apiKey);
    final fromAddress = Address('your-email@example.com');
    final personalization = Personalization([Address(to)]);
    final content = Content(
        'text/plain', 'Votre rendez-vous est confirmé pour le $date à $time.');
    final subject = 'Confirmation de rendez-vous';

    final email = Email(
      [personalization],
      fromAddress,
      subject,
      content: [content],
    );

    try {
      await mailer.send(email);
      print('Email confirmation sent to $to for $date at $time');
    } catch (e) {
      print('Error sending confirmation email: $e');
    }
  }
}
