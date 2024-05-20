import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/registration_screen/registration_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final controller = RegistrationScreenController();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBarArea(title: S.of(context).registration),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: GetBuilder(
                      init: controller,
                      builder: (controller) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            // Ajouter le champ pour attester la certification RNCP
                            CheckboxListTile(
                              title: Text(
                                S.of(context).iAmACoach, // Texte pour l'option
                                style: MyTextStyle.montserratRegular(
                                  color: ColorRes.black,
                                ),
                              ),
                              value: controller.isCoach.value,
                              onChanged: (newValue) {
                                controller.toggleCoach(newValue ?? false);
                                // Mettre à jour la visibilité des autres options en fonction de la valeur de la case à cocher "I'm a coach"
                                if (newValue != null) {
                                  controller.showCertifyAndAgreeOptions();
                                  // Mettre à jour le statut de coach de l'utilisateur dans Firestore
                                  updateUserIsCoach(newValue);
                                } else {
                                  controller.hideCertifyAndAgreeOptions();
                                }
                              },
                            ),
                            Visibility(
                              visible: controller.isCoach.value,
                              child: CheckboxListTile(
                                title: Text(
                                  S.of(context).iCertifyThatIHoldACertification,
                                  style: MyTextStyle.montserratRegular(
                                    color: ColorRes.black,
                                  ),
                                ),
                                value: controller.isCertified ?? false,
                                onChanged: (newValue) {
                                  controller
                                      .toggleCertification(newValue ?? false);
                                },
                              ),
                            ),
                            Visibility(
                              visible: controller.isCoach.value,
                              child: CheckboxListTile(
                                title: Text(
                                  S
                                      .of(context)
                                      .iHaveReadAndAgreeToTheOcoachingCode,
                                  style: MyTextStyle.montserratRegular(
                                    color: ColorRes.black,
                                  ),
                                ),
                                value: controller.isCodeApproved ?? false,
                                onChanged: (newValue) {
                                  controller
                                      .toggleCodeApproval(newValue ?? false);
                                },
                              ),
                            ),

                            // Ajouter le champ pour télécharger et scanner le diplôme RNCP
                            Visibility(
                              visible: controller.isCoach.value,
                              child: TextButtonCustom(
                                onPressed: () {
                                  // Ajouter la logique pour télécharger et scanner le diplôme RNCP
                                  controller.uploadRNCPDocument();
                                },
                                title: S.of(context).uploadRNCPDocument,
                                titleColor: ColorRes.darkSkyBlue,
                                backgroundColor:
                                    ColorRes.darkSkyBlue.withOpacity(0.2),
                              ),
                            ),

                            const SizedBox(
                              height: 40,
                            ),
                            Text(
                              S.of(context).please,
                              style: MyTextStyle.montserratRegular(
                                  color: ColorRes.battleshipGrey),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(
                              height: 40,
                            ),
                            TextWithTextField(
                              title: S.of(context).fullname,
                              controller: controller.fullNameController,
                              isError: controller.fullnameError,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            TextWithTextField(
                              title: S.of(context).email,
                              controller: controller.emailController,
                              isError: controller.emailError,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextWithTextField(
                                title: S.of(context).password,
                                controller: controller.passwordController,
                                isError: controller.passwordError,
                                keyboardType: TextInputType.visiblePassword,
                                onChangedPasswordVisibility:
                                    controller.onChangePassword,
                                isSuffixVisible: true,
                                obSecure: controller.isPasswordVisible,
                                passwordVisible: controller.isPasswordVisible),
                            TextWithTextField(
                              title: S.of(context).retypePassword,
                              controller: controller.reTypePasswordController,
                              isError: controller.reTypePasswordError,
                              keyboardType: TextInputType.visiblePassword,
                              onChangedPasswordVisibility:
                                  controller.onChangedReTypePassword,
                              isSuffixVisible: true,
                              obSecure: controller.isReTypePasswordVisible,
                              passwordVisible:
                                  controller.isReTypePasswordVisible,
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            TextButtonCustom(
                                onPressed: controller.onRegisterClick,
                                title: S.of(context).register,
                                titleColor: ColorRes.white,
                                backgroundColor: ColorRes.crystalBlue),
                            const SizedBox(
                              height: 20,
                            ),
                            const PolicyText(),
                            SizedBox(
                              height: AppBar().preferredSize.height / 3,
                            )
                          ],
                        );
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void updateUserIsCoach(bool isCoach) async {
  try {
    // Récupérer l'utilisateur actuellement authentifié
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Accéder au document de l'utilisateur dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Vérifier si le document existe
      var docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        // Le document existe, mettre à jour le champ "isCoach"
        await userDoc.update({'isCoach': isCoach});
      } else {
        // Le document n'existe pas, le créer avec l'ID utilisateur et les données initiales
        await userDoc.set({'isCoach': isCoach});
      }

      print('User coach status updated successfully!');
    } else {
      print('No user authenticated');
    }
  } catch (e) {
    print('Error updating user coach status: $e');
    // Gérer l'erreur
  }
}

class TextWithTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool isError;
  final bool obSecure;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final bool isSuffixVisible;
  final bool passwordVisible;
  final VoidCallback? onChangedPasswordVisibility;
  final TextStyle? titleStyle; // Ajout d'un style pour le titre

  const TextWithTextField({
    super.key,
    required this.title,
    required this.controller,
    this.isError = false,
    this.obSecure = false,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.isSuffixVisible = false,
    this.passwordVisible = false,
    this.onChangedPasswordVisibility,
    this.titleStyle, // Ajout d'un style pour le titre
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 5,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 7),
          child: Text(
            title,
            style: titleStyle ??
                TextStyle(
                    fontWeight: FontWeight
                        .bold), // Utilisation du style fourni ou du style par défaut
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isError ? ColorRes.ferrariRed : ColorRes.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: ColorRes.aquaHaze,
                filled: true,
                suffixIconConstraints: const BoxConstraints(minWidth: 10),
                suffixIconColor: ColorRes.tuftsBlue,
                suffixIcon: !isSuffixVisible
                    ? const SizedBox()
                    : IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: onChangedPasswordVisibility,
                      ),
              ),
              obscureText: obSecure,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              cursorColor: ColorRes.darkJungleGreen,
            ),
          ),
        )
      ],
    );
  }
}

class PolicyText extends StatelessWidget {
  const PolicyText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: S.of(context).byProceedingForwardYouAgreeToThen,
          style: MyTextStyle.montserratRegular(
              size: 12, color: ColorRes.battleshipGrey),
          children: [
            TextSpan(
                text: S.of(context).privacyPolicy,
                style: MyTextStyle.montserratBold(
                    size: 12, color: ColorRes.charcoalGrey),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    CommonFun.loadUrl(url: ConstRes.privacyPolicy);
                  }),
            TextSpan(
              text: ' ${S.of(context).and} ',
              style: MyTextStyle.montserratRegular(
                  size: 12, color: ColorRes.battleshipGrey),
            ),
            TextSpan(
                text: S.of(context).termsConditions,
                style: MyTextStyle.montserratBold(
                    size: 12, color: ColorRes.charcoalGrey),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    CommonFun.loadUrl(url: ConstRes.termsOfUse);
                  }),
          ],
        ),
      ),
    );
  }
}
