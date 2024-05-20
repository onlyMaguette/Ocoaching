/*
import 'package:twilio_flutter/twilio_flutter.dart';

class SMSService {
  final TwilioFlutter twilioFlutter;

  SMSService(this.twilioFlutter);

  Future<void> sendConfirmationSMS(
      String phone, String date, String time) async {
    try {
      await twilioFlutter.sendSMS(
        toNumber: phone,
        messageBody: 'Votre rendez-vous est confirmé pour le $date à $time.',
      );
      print('SMS confirmation sent to $phone for $date at $time');
    } catch (e) {
      print('Error sending confirmation SMS: $e');
    }
  }
}
*/
