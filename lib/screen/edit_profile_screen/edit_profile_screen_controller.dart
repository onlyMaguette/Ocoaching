import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/pref_service.dart';
import 'package:patient_flutter/utils/const_res.dart';

class EditProfileScreenController extends GetxController {

  // Déclarez les contrôleurs pour les réseaux sociaux et le tarif des séances
  TextEditingController socialMediaController = TextEditingController();
  TextEditingController sessionRateController = TextEditingController();

  // Définissez les méthodes pour récupérer et modifier les réseaux sociaux et le tarif des séances
  void setSocialMedia(String value) {
    socialMediaController.text = value;
  }

  void setSessionRate(String value) {
    sessionRateController.text = value;
  }

  // Déclarez les variables booléennes pour les services offerts
  var isGroupCoachingSelected = false.obs;
  var isSeminarSelected = false.obs;
  var isConferenceSelected = false.obs;

  // Définissez les méthodes pour modifier les services offerts
  void setGroupCoaching(bool value) {
    isGroupCoachingSelected.value = value;
  }

  void setSeminar(bool value) {
    isSeminarSelected.value = value;
  }

  void setConference(bool value) {
    isConferenceSelected.value = value;
  }

  PrefService prefService = PrefService();
  RegistrationData? userData;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController specialitiesController =
  TextEditingController(); // Ajout du contrôleur specialitiesController
  String? netWorkImage;
  File? imageFile;

  @override
  void onInit() {
    prefData();
    super.onInit();
  }

  @override
  void onClose() {
    // Nettoyez les contrôleurs lorsqu'ils ne sont plus nécessaires
    socialMediaController.dispose();
    sessionRateController.dispose();
    super.onClose();
  }

  void prefData() async {
    await prefService.init();
    userData = prefService.getRegistrationData();
    fullNameController = TextEditingController(text: userData?.fullname ?? '');
    if (userData?.profileImage != null) {
      netWorkImage = userData?.profileImage;
    }
    update();
  }

  void onImageTap() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: ConstRes.imageQuality,
        maxHeight: ConstRes.maxHeight,
        maxWidth: ConstRes.maxWidth);
    if (image != null) {
      imageFile = File(image.path);
      update();
    }
  }

  void onContinueTap() {
    CustomUi.loader();
    ApiService.instance
        .updateUserDetails(image: imageFile, name: fullNameController.text)
        .then((value) {
      Get.back();
      if (value.status == true) {
        CustomUi.snackBar(
            iconData: Icons.person, positive: true, message: value.message);
      } else {
        CustomUi.snackBar(iconData: Icons.person, message: value.message);
      }
    });
  }
}
