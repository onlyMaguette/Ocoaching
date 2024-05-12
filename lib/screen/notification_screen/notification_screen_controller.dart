import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/model/notification/notification.dart';
import 'package:patient_flutter/services/api_service.dart';

class NotificationScreenController extends GetxController {
  List<NotificationData>? notifications = [];
  bool isLoading = false;
  ScrollController scrollController = ScrollController();
  int start = 0;

  // Méthode pour confirmer le rendez-vous
  void confirmAppointment(NotificationData notification) {
    // Implémentez ici la logique pour confirmer le rendez-vous
    // Vous pouvez appeler une API pour effectuer la confirmation du rendez-vous
    // Par exemple :
    // ApiService.instance.confirmAppointment(notification.id).then((response) {
    //   // Gérez la réponse de l'API en conséquence
    // });
    print('Appointment confirmed for ${notification.title}');
  }

  @override
  void onInit() {
    notificationApiCall();
    fetchScrollData();
    super.onInit();
  }

  void notificationApiCall() {
    isLoading = true;
    ApiService.instance.fetchNotification(start: start).then((value) {
      if (start == 0) {
        notifications = value.data;
      } else {
        notifications?.addAll(value.data!);
      }
      start += notifications!.length;
      isLoading = false;
      update();
    });
  }

  fetchScrollData() {
    scrollController.addListener(
      () {
        if (scrollController.offset ==
            scrollController.position.maxScrollExtent) {
          if (!isLoading) {
            notificationApiCall();
          }
        }
      },
    );
  }

  @override
  void onClose() {
    FlutterAppBadger.removeBadge();
    super.onClose();
  }
}
