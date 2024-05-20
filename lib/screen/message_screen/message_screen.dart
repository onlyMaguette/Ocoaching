import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/dashboard_top_bar_title.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/message_screen/message_screen_controller.dart';
import 'package:patient_flutter/screen/message_screen/widget/message_card.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageScreenController());
    return Column(
      children: [
        DashboardTopBarTitle(title: S.current.messages),
        const SizedBox(height: 3),
        GetBuilder(
          init: controller,
          builder: (c) {
            // Vérifier si la liste des messages est vide
            if (controller.userList.isEmpty) {
              return Expanded(
                child: Center(
                  child: Text(
                    S.current.noMessage,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: controller.userList.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return MessageCard(
                      conversation: controller.userList[index],
                      userData: controller.userData,
                      onLongPress: controller.onLongPress,
                    );
                  },
                ),
              );
            }
          },
        )
      ],
    );
  }
}
