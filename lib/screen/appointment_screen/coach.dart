// coach.dart
class Coach {
  final String id;
  final String name;
  final String email;
  final String phone;
  final Duration appointmentDuration; // Add appointment duration property

  Coach(this.name, this.email, this.phone, this.appointmentDuration, this.id);
}
