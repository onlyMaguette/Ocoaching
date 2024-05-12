import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/notification/notification.dart';
import 'package:patient_flutter/screen/notification_screen/notification_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          TopBarArea(title: S.current.notifications),
          const SizedBox(height: 10),
          GetBuilder(
            init: controller,
            builder: (context) {
              if (controller.notifications?.isEmpty ?? true) {
                // Afficher un message si la liste des notifications est vide
                return Expanded(
                  child: Center(
                    child: Text(
                      'No notification',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                );
              } else {
                // Afficher la liste des notifications
                return Expanded(
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: controller.notifications?.length,
                    itemBuilder: (context, index) {
                      NotificationData? notification =
                          controller.notifications?[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification?.title ?? '',
                                    style: MyTextStyle.montserratMedium(
                                      size: 15,
                                      color: ColorRes.darkJungleGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    notification?.description ?? '',
                                    style: MyTextStyle.montserratLight(
                                      size: 13,
                                      color: ColorRes.smokeyGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (notification != null) {
                                        // Appeler la méthode du contrôleur pour confirmer le rendez-vous
                                        controller
                                            .confirmAppointment(notification!);
                                      }
                                    },
                                    child: Text('Confirmer'),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(thickness: 1),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
