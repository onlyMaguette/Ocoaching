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
  TextEditingController customServiceController =
      TextEditingController(); // Ajout du contrôleur customServiceController

  var isCoach = false.obs;

  // Définissez les méthodes pour récupérer et modifier les réseaux sociaux et le tarif des séances
  void setSocialMedia(String value) {
    socialMediaController.text = value;
  }

  void setCustomService(String value) {
    customServiceController.text = value;
  }

  void setSessionRate(String value) {
    sessionRateController.text = value;
  }

  // Déclarez les variables booléennes pour les services offerts
  var isGroupCoachingSelected = false.obs;
  var isSeminarSelected = false.obs;
  var isConferenceSelected = false.obs;
  var isCustomServiceSelected =
      false.obs; // Ajout de la variable pour le service personnalisé

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
    customServiceController.dispose();
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
    // Récupérer les données du contrôleur
    String? name = fullNameController.text;
    String? customService =
        isCustomServiceSelected.value ? customServiceController.text : null;

    // Appeler updateUserDetails avec les données récupérées
    ApiService.instance
        .updateUserDetails(
      name: name,
      customService: customService,
      image: imageFile,
    )
        .then((value) {
      // Traiter la réponse
      Get.back(); // Fermer l'écran après la mise à jour
      if (value.status == true) {
        // Afficher un message de succès si la mise à jour est réussie
        CustomUi.snackBar(
          iconData: Icons.person,
          positive: true,
          message: value.message,
        );
      } else {
        // Afficher un message d'erreur si la mise à jour a échoué
        CustomUi.snackBar(
          iconData: Icons.person,
          message: value.message,
        );
      }
    }).catchError((error) {
      // Gérer les erreurs éventuelles
      print('Erreur lors de la mise à jour du profil: $error');
      // Afficher un message d'erreur générique
      CustomUi.snackBar(
        iconData: Icons.error_outline,
        message: 'Une erreur s\'est produite lors de la mise à jour du profil.',
      );
    });
  }
}
