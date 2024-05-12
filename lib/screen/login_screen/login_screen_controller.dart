import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/complete_registration_screen/complete_registration_screen.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:patient_flutter/screen/login_screen/widget/forgot_password_sheet.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/pref_service.dart';
import 'package:patient_flutter/utils/update_res.dart';

class LoginScreenController extends GetxController {
  Position? userLocation;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController forgotController = TextEditingController();
  bool emailError = false;
  bool passwordError = false;

  String
  deviceToken = '';
  PrefService prefService = PrefService();

  bool isPasswordVisible = true;

  @override
  void onInit() {
    getPref();
    FirebaseMessaging.instance.getToken().then((value) {
      deviceToken = value ?? '';
    });
    super.onInit();
  }

  void onLoginClick() async {
    emailError = false;
    passwordError = false;
    if (emailController.text
        .trim()
        .isEmpty) {
      emailError = true;
    }
    if (passwordController.text
        .trim()
        .isEmpty) {
      passwordError = true;
    }
    update();
    if (emailError || passwordError) {
      return;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      CustomUi.snackBar(
          iconData: Icons.email,
          positive: false,
          message: S.current.pleaseEnterValidEmail);
      return;
    }

    UserCredential? user = await signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim());

    if (user == null) return;
    if (user.user?.emailVerified == true) {
      ApiService()
          .registration(
          identity: emailController.text.trim(),
          deviceToken: deviceToken,
          deviceType: Platform.isAndroid ? 1 : 2,
          loginType: 1,
          name: 'as')
          .then((value) async {
        //Get.back(); // Fermeture du spinner de chargement
        if (value.status == true) {
          PrefService.userId = value.data?.id ?? -1;
          PrefService.identity = value.data?.identity ?? '';
          await prefService.setLogin(key: kLogin, value: true);
          await prefService.saveString(
              key: kPassword, value: passwordController.text);
          await prefService.saveString(
              key: kRegistrationUser, value: jsonEncode(value.data?.toJson()));

          // Redirection selon le type d'utilisateur
          if (value.data?.phoneNumber == null ||
              value.data!.phoneNumber!.isEmpty) {
            // Redirection vers la page d'inscription complète
            Get.off(() => const CompleteRegistrationScreen(screenType: 1));
          } else {
            // Redirection vers le tableau de bord
            Get.off(() => DashboardScreen(userLocation: userLocation));
          }
        } else {
          CustomUi.snackBar(
              message: value.message.toString(), iconData: Icons.login);
        }
      });
    } else {
      //Get.back();
      CustomUi.snackBar(
          message: S.current.pleaseVerifiedYourEmail, iconData: Icons.email);
    }
    // Obtenir la position de l'utilisateur
    try {
      userLocation = await Geolocator.getCurrentPosition();
    } catch (e) {
      // Gérer les erreurs de géolocalisation ici, si nécessaire
      print('Erreur lors de : $e');
    }
    // Redirection vers le tableau de bord avec la position de l'utilisateur
    Get.off(() => DashboardScreen(userLocation: userLocation));
  }

  ///-------------- SIGN IN METHOD --------------///
  Future<UserCredential?> signIn(
      {required String email, required String password}) async {
    try {
      return await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.back();
      if (e.code == 'user-not-found') {
        CustomUi.snackBar(
            iconData: Icons.email, message: S.current.noUserFoundForThisEmail);
      } else if (e.code == 'wrong-password') {
        CustomUi.snackBar(
            message: S.current.passwordDoesntMatch, iconData: Icons.password);
      }
    }
    return null;
  }

  void getPref() async {
    await prefService.init();
  }

  void onForgotPasswordClick() {
    Get.bottomSheet(
      ForgotPasswordSheet(
        onPressed: () async {
          if (forgotController.text.isEmpty) {
            CustomUi.snackBar(
                message: S.current.pleaseEnterMail, iconData: Icons.mail);
            return;
          }
          try {
            await FirebaseAuth.instance
                .sendPasswordResetEmail(email: forgotController.text.trim());
            Get.back();
            forgotController.clear();
            CustomUi.snackBar(
                message: S.current.emailSentSuccessfullySentYourMail,
                iconData: Icons.email,
                positive: true);
          } on FirebaseAuthException catch (e) {
            CustomUi.snackBar(message: "${e.message}", iconData: Icons.mail);
          }
        },
        forgotController: forgotController,
      ),
    );
  }

  void redirectToredirectCompleteRegistrationScreen() {
    Get.off(() =>
        CompleteRegistrationScreen(
            screenType: 0)); // Valeur par défaut pour screenType
  }

  void onChangePassword() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }
}
