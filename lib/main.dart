import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:patient_flutter/screen/languages_screen/languages_screen_controller.dart';
import 'package:patient_flutter/screen/my_app/my_app.dart';
import 'package:patient_flutter/services/pref_service.dart';
import 'package:patient_flutter/utils/update_res.dart';

import 'screen/my_app/my_app_controller.dart';

PrefService prefService = PrefService();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  MyAppController().showNotification(
      channel: const AndroidNotificationChannel(
          'high_importance_channel', // id
          'High Importance Notifications', // title
          importance: Importance.max),
      notification: message.data);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await prefService.init();
  LanguagesScreenController.selectedLanguage =
      prefService.getString(key: kLanguage) ?? Platform.localeName.split('_')[0];
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(
      const RestartWidget(
        child: MyApp(),
      ),
    );
  });
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
