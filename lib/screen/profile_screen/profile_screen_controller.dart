import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/edit_profile_screen/edit_profile_screen.dart';
import 'package:patient_flutter/screen/splash_screen/splash_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/pref_service.dart';
import 'package:patient_flutter/utils/firebase_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class ProfileScreenController extends GetxController {
  bool isNotification = false;
  PrefService prefService = PrefService();
  RegistrationData? userData;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void onInit() {
    fetchPatientApiCall();
    prefData();
    super.onInit();
  }

  void onNotificationTap() {
    // Inverser la valeur de la notification
    isNotification = !isNotification;

    // Mettre à jour l'état pour refléter le changement
    update([kNotificationUpdate]);

    // Effectuer l'appel API pour mettre à jour les détails de l'utilisateur
    ApiService.instance
        .updateUserDetails(isNotification: isNotification ? 1 : 0)
        .then((value) {
      if (value.status == true) {
        // Mise à jour réussie, aucune action supplémentaire requise
      } else {
        // Mise à jour échouée, inverser à nouveau la valeur de la notification
        isNotification = !isNotification;
        update([
          kNotificationUpdate
        ]); // Mettre à jour l'état pour refléter le changement
        CustomUi.snackBar(
            iconData: Icons.error_rounded, message: value.message);
      }
    });
  }

  void prefData() async {
    await prefService.init();
    userData = prefService.getRegistrationData();
    isNotification = userData?.isNotification == 1;
    update([kProfileUpdate, kNotificationUpdate]);
  }

  void onEditProfileNavigate() {
    Get.to(() => const EditProfileScreen())?.then((value) {
      userData = prefService.getRegistrationData();
      update([kProfileUpdate]);
    });
  }

  void onLogoutTap() {
    ApiService.instance.logOut().then((value) async {
      if (value.status == true) {
        await prefService.preferences?.clear();
        PrefService.userId = -1;
        PrefService.identity = '';
        CustomUi.snackBar(
            iconData: Icons.logout_rounded,
            message: value.message,
            positive: true);
        Get.offAll(() => const SplashScreen());
      } else {
        CustomUi.snackBar(
            iconData: Icons.logout_rounded, message: value.message);
      }
    });
  }

  void fetchPatientApiCall() {
    ApiService.instance.fetchPatient();
  }

  void onDeleteContinueTap() {
    //CustomUi.loader();
    ApiService.instance.deleteUserAccount().then((value) async {
      if (value.status == true) {
        await deleteFirebaseUser();
        await prefService.preferences?.clear();
        PrefService.userId = -1;
        PrefService.identity = '';
        Get.back();
        CustomUi.snackBar(
            message: value.message ?? '',
            iconData: Icons.delete_rounded,
            positive: true);
        Get.offAll(() => const SplashScreen());
      } else {
        Get.back();
        CustomUi.snackBar(
            message: value.message ?? '', iconData: Icons.delete_rounded);
      }
    });
  }

  Future<void> deleteFirebaseUser() async {
    String patientId = CommonFun.setPatientId(patientId: userData?.id);
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    await db
        .collection(FirebaseRes.userChatList)
        .doc(patientId)
        .collection(FirebaseRes.userList)
        .get()
        .then((value) {
      for (var element in value.docs) {
        db
            .collection(FirebaseRes.userChatList)
            .doc(element.id)
            .collection(FirebaseRes.userList)
            .doc(patientId)
            .update({FirebaseRes.isDeleted: true, FirebaseRes.deletedId: time});
        db
            .collection(FirebaseRes.userChatList)
            .doc(patientId)
            .collection(FirebaseRes.userList)
            .doc(element.id)
            .update({FirebaseRes.isDeleted: true, FirebaseRes.deletedId: time});
      }
    });
  }
}
