import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:patient_flutter/services/api_service.dart';

import '../../generated/l10n.dart';
import 'coach.dart';

class AppointmentScreenController extends GetxController {
  List<AppointmentData>? appointmentData;
  bool isLoading = false;
  List<AppointmentData> selectedAppointments = [];
  Coach? selectedCoach;

  @override
  void onInit() {
    fetchAppointmentData();
    super.onInit();
  }

  void fetchAppointmentData() {
    isLoading = true;
    update();
    ApiService.instance.fetchMyAppointments().then((value) {
      appointmentData = value.data;
      isLoading = false;
      update();
    });
  }

  void onAppointmentCardTap(AppointmentData? data) {
    Get.to(() => const AppointmentDetailScreen(), arguments: data?.id)
        ?.then((value) {
      fetchAppointmentData();
    });
  }

  void toggleAppointmentSelection(AppointmentData data) {
    if (selectedAppointments.contains(data)) {
      selectedAppointments.remove(data);
    } else {
      selectedAppointments.add(data);
    }
    update();
  }

  void bookAppointmentsWithCoach(BuildContext context) {
    if (selectedAppointments.isNotEmpty && selectedCoach != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(S.current.bookAppointments),
            content: Text(
              '${S.current.successfulAppointment} ${selectedCoach!.name}!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  selectedAppointments.clear();
                  update();
                },
                child: Text(S.current.ok),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(S.current.selectAppointmentsAndCoach),
            content: Text(S.current.pleaseSelectAppointmentsAndCoach),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(S.current.ok),
              ),
            ],
          );
        },
      );
    }
  }

  // Method to get available coaches
  List<Coach> getAvailableCoaches() {
    // Implement logic to get available coaches here
    // For now, returning an empty list
    return [];
  }

  // Method to get the next available appointment date
  DateTime getNextAvailableAppointmentDate() {
    // Implement logic to get the next available appointment date here
    // For now, returning the current date
    return DateTime.now();
  }

  // Method to get the next available appointment time
  TimeOfDay getNextAvailableAppointmentTime() {
    // Implement logic to get the next available appointment time here
    // For now, returning the current time
    return TimeOfDay.now();
  }

  // Méthode pour obtenir la durée du rendez-vous, fixe à 15 minutes
  Duration getAppointmentDuration() {
    return Duration(minutes: 15); // Durée fixe de 15 minutes
  }
}
