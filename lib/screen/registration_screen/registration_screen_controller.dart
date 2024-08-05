import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/complete_registration_screen/complete_registration_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/pref_service.dart';
import 'package:patient_flutter/utils/update_res.dart';

class RegistrationScreenController extends GetxController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reTypePasswordController = TextEditingController();

  bool fullnameError = false;
  bool emailError = false;
  bool passwordError = false;
  bool reTypePasswordError = false;

  bool isPasswordVisible = true;
  bool isReTypePasswordVisible = true;

  String deviceToken = '';
  PrefService prefService = PrefService();

  // Déclarez les variables pour les nouveaux rôles
  var isMentalCoach = false.obs;
  var isHypnotherapist = false.obs;

  // Déclarez une variable pour stocker le choix du rôle de coach
  var isCoach = false.obs;

  bool isCertified = false; // Variable pour l'attestation de certification RNCP
  bool isCodeApproved =
      false; // Variable pour la signature du code de déontologie Ocoaching
  bool isDocumentUploaded = false;

  // Méthodes pour les nouveaux rôles
  void toggleMentalCoach(bool value) {
    isMentalCoach.value = value;
  }

  void toggleHypnotherapist(bool value) {
    isHypnotherapist.value = value;
  }

  // Méthode pour activer ou désactiver le chargement du document
  void toggleDocumentUploaded(bool value) {
    isDocumentUploaded = value;
    update();
  }

  // Méthode pour activer ou désactiver l'attestation de certification RNCP
  void toggleCertification(bool value) {
    isCertified = value;
    update();
  }

  // Méthode pour basculer le choix du rôle de coach
  void toggleCoach(bool value) {
    isCoach.value = value;
  }

  // Méthode pour activer ou désactiver la signature du code de déontologie Ocoaching
  void toggleCodeApproval(bool value) {
    isCodeApproved = value;
    update();
  }

  // Définir une méthode pour afficher les options "I certify" et "I have read and agree"
  void showCertifyAndAgreeOptions() {
    // Mettre à jour les états des autres options ici
    update();
  }

  // Définir une méthode pour masquer les options "I certify" et "I have read and agree"
  void hideCertifyAndAgreeOptions() {
    // Mettre à jour les états des autres options ici
    update();
  }

  // Méthode pour gérer le téléchargement du diplôme RNCP
  void uploadRNCPDocument() {
    Get.defaultDialog(
      title: S.current.downloadRNCPDiploma,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.current.selectFileToDownload),
          ElevatedButton(
            onPressed: () async {
              // Sélectionner un fichier
              final result = await FilePicker.platform.pickFiles();

              // Vérifier si un fichier a été sélectionné
              if (result != null) {
                // Récupérer le fichier sélectionné
                final file = result.files.single;

                // Faire quelque chose avec le fichier, comme l'afficher
                print('Chemin du fichier : ${file.path}');
              } else {
                // Aucun fichier sélectionné
                print(S.current.noFileSelected);
              }
            },
            child: Text(S.current.selectFile),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: Text(S.current.cancel),
        ),
      ],
    );
  }

  @override
  void onInit() {
    initPrefService();
    FirebaseMessaging.instance.getToken().then((value) {
      deviceToken = value ?? '';
      log('📩  ${deviceToken.toString()}');
    });
    super.onInit();
  }

  void onRegisterClick() async {
    // Vérifier si l'utilisateur a coché "Je suis un coach"
    if (isCoach.value) {
      // Vérifier si toutes les cases associées à "Je suis un coach" sont cochées
      if (!isCertified || !isCodeApproved || !isDocumentUploaded) {
        CustomUi.snackBar(
            iconData: Icons.error,
            positive: false,
            message: S.current.allConditionsNotMet);
        return;
      }
    } else if (isMentalCoach.value) {
      // Vérifier si toutes les cases associées à "Je suis un coach" sont cochées
      if (!isCertified || !isCodeApproved || !isDocumentUploaded) {
        CustomUi.snackBar(
            iconData: Icons.error,
            positive: false,
            message: S.current.allConditionsNotMet);
        return;
      }
    } else if (isHypnotherapist.value) {
      // Vérifier si toutes les cases associées à "Je suis un coach" sont cochées
      if (!isCertified || !isCodeApproved || !isDocumentUploaded) {
        CustomUi.snackBar(
            iconData: Icons.error,
            positive: false,
            message: S.current.allConditionsNotMet);
        return;
      }
    }

    fullnameError = false;
    emailError = false;
    passwordError = false;
    reTypePasswordError = false;
    if (fullNameController.text.trim().isEmpty) {
      fullnameError = true;
    }
    if (emailController.text.trim().isEmpty) {
      emailError = true;
    }

    if (passwordController.text.trim().isEmpty) {
      passwordError = true;
    }
    if (reTypePasswordController.text.trim().isEmpty) {
      reTypePasswordError = true;
    }
    update();
    if (fullnameError || emailError || passwordError || reTypePasswordError) {
      return;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      CustomUi.snackBar(
          iconData: Icons.email,
          positive: false,
          message: S.current.pleaseEnterValidEmail);
      return;
    }
    if (passwordController.text.trim() !=
        reTypePasswordController.text.trim()) {
      CustomUi.snackBar(
          iconData: Icons.password,
          positive: false,
          message: S.current.passwordDosentMatchEnterSamePassword);
      return;
    }

    createUserWithEmailAndPassword();
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (credential.user != null) {
        // Envoyer un e-mail de vérification
        await credential.user?.sendEmailVerification();

        // Vérifier si l'e-mail est vérifié avant de continuer
        if (!credential.user!.emailVerified) {
          Get.back();
          // Si l'e-mail n'est pas vérifié, afficher un message à l'utilisateur
          CustomUi.snackBar(
              iconData: Icons.email,
              positive: false,
              message: S.current.pleaseVerifiedYourEmail);
        }
        print('Nom de l\'utilisateur: ${fullNameController.text.trim()}');
        // Si l'e-mail est vérifié, continuer avec le processus d'enregistrement
        registrationApi();
      }
    } on FirebaseAuthException catch (e) {
      //Get.back();
      if (e.code == 'weak-password') {
        CustomUi.snackBar(
            iconData: Icons.error,
            message: S.current.thePasswordProvidedIsTooWeak,
            positive: false);
      } else if (e.code == 'email-already-in-use') {
        CustomUi.snackBar(
            iconData: Icons.error,
            message: S.current.theAccountAlreadyExistsForThatEmail,
            positive: false);
      }
    } catch (e) {
      // Gérer d'autres exceptions
    }
  }

  void registrationApi() {
    ApiService.instance
        .registration(
            identity: emailController.text.trim(),
            name: fullNameController.text.trim(),
            deviceToken: deviceToken,
            deviceType: Platform.isAndroid ? 1 : 2,
            loginType: 1)
        .then((value) async {
      print('Réponse de l\'API : $value');
      if (value.status == true) {
        PrefService.userId = value.data?.id ?? -1;
        PrefService.identity = value.data?.identity ?? '';
        await prefService.saveString(
            key: kRegistrationUser, value: jsonEncode(value.data?.toJson()));
        Get.off(() => const CompleteRegistrationScreen(screenType: 0));
      } else {
        CustomUi.snackBar(
            iconData: Icons.app_registration,
            positive: false,
            message: value.message);
      }
    });
  }

  void initPrefService() async {
    await prefService.init();
  }

  void onChangePassword() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  void onChangedReTypePassword() {
    isReTypePasswordVisible = !isReTypePasswordVisible;

    update();
  }
}
