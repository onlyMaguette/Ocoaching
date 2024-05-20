import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:patient_flutter/services/api_service.dart';

import 'coach.dart';

class AppointmentScreenController extends GetxController {
  List<AppointmentData>? appointmentData;
  bool isLoading = false;

  @override
  void onInit() {
    fetchAppointmentData();
    super.onInit();
  }

  void fetchAppointmentData() {
    isLoading = false;
    ApiService.instance.fetchMyAppointments().then((value) {
      appointmentData = value.data;
      isLoading = false;
      update();
    });
  }

  onAppointmentCardTap(AppointmentData? data) {
    Get.to(() => const AppointmentDetailScreen(), arguments: data?.id)
        ?.then((value) {
      fetchAppointmentData();
    });
  }

  // Function to handle booking a free appointment
  void bookFreeAppointment(BuildContext context) {
    // Here you would implement the logic to book a free appointment
    // Let's assume we have a list of available coaches in the appointmentData
    // and we can choose one from the list for the appointment.
    if (appointmentData != null && appointmentData!.isNotEmpty) {
      final selectedCoach = appointmentData![0].doctor?.name;
      // Choosing the first coach for now

      // Now you can implement the code to actually book the appointment,
      // which could involve making API calls or updating database records.
      // For demonstration purposes, let's just display an alert dialog.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Book Appointment'),
            content: Text(
                'You have successfully booked a 15-minute free appointment with ${selectedCoach}!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // If no appointment data is available, display a message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Appointments Available'),
            content: Text(
                'Sorry, there are currently no appointments available. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
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
