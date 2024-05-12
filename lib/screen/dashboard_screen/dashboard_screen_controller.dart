import 'package:get/get.dart';
import 'package:patient_flutter/utils/color_res.dart';

class DashboardScreenController extends GetxController {
  int currentIndex = 0;
  int appointmentNotifications = 0; // Ajout d'un compteur de notifications
  final inactiveColor = ColorRes.grey;

  void onItemSelected(int value) {
    currentIndex = value;
    update();
  }

  // Méthode pour mettre à jour le nombre de notifications de rendez-vous
  void updateAppointmentNotifications(int newNotifications) {
    appointmentNotifications = newNotifications;
    update(); // Met à jour l'interface utilisateur
  }
}
