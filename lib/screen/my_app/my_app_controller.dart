import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/screen/appointment_chat_screen/appointment_chat_screen_controller.dart';
import 'package:patient_flutter/screen/message_chat_screen/message_chat_screen_controller.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class MyAppController extends GetxController {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int notificationCount = 0;

  @override
  void onInit() {
    log('onInit');
    saveTokenUpdate();
    FlutterAppBadger.removeBadge();
    super.onInit();
  }

  void saveTokenUpdate() async {
    await FirebaseMessaging.instance.subscribeToTopic(ConstRes.subscribeTopic);
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(sound: true, alert: true);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.max,
        showBadge: false);

    /// Required to display a heads up notification (For iOS)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: false, sound: true);

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        requestBadgePermission: false);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        log('SuccessFully Notification Done...  ${message.data}');

        if (message.data[nNotificationType] == '0') {
          if (message.data[nSenderId] != MessageChatScreenController.senderId) {
            showNotification(channel: channel, notification: message.data);
          }
          return;
        }
        if (message.data[nNotificationType] == '1') {
          if (message.data[nAppointmentId] !=
              AppointmentChatScreenController.appointmentId) {
            showNotification(channel: channel, notification: message.data);
          }
          return;
        }
        showNotification(channel: channel, notification: message.data);
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void showNotification(
      {Map<String, dynamic>? notification,
      required AndroidNotificationChannel channel}) {
    flutterLocalNotificationsPlugin.show(
      1,
      notification?[nTitle],
      notification?[nBody],
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelShowBadge: channel.showBadge,
            importance: channel.importance),
        iOS: const DarwinNotificationDetails(
            presentSound: true, presentAlert: true, presentBadge: false),
      ),
    );
  }
}
