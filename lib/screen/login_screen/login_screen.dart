import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/login_screen/login_screen_controller.dart';
import 'package:patient_flutter/screen/registration_screen/registration_screen.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoginScreenController();
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Image(
                  image: const AssetImage(AssetRes.public_health),
                  height: Get.height / 2.2,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 10,
                ),
                GetBuilder(
                    init: controller,
                    builder: (controller) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            TextWithTextField(
                              title: S.of(context).email,
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextWithTextField(
                              title: S.of(context).password,
                              controller: controller.passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              onChangedPasswordVisibility:
                                  controller.onChangePassword,
                              isSuffixVisible: true,
                              obSecure: controller.isPasswordVisible,
                              passwordVisible: controller.isPasswordVisible,
                              titleStyle: TextStyle(
                                  fontWeight: FontWeight
                                      .bold), // Spécifier le style uniquement ici
                            ),
                            TextButtonCustom(
                              onPressed: () {
                                if (controller.emailController.text
                                        .trim()
                                        .isEmpty ||
                                    controller.passwordController.text
                                        .trim()
                                        .isEmpty) {
                                  // Redirection vers la page CompleteRegistrationScreen si les champs sont vides
                                  controller
                                      .redirectToredirectCompleteRegistrationScreen();
                                } else {
                                  // Sinon, appeler la fonction de connexion
                                  controller.onLoginClick();
                                }
                              },
                              title: S.of(context).login,
                              titleColor: ColorRes.white,
                              backgroundColor: ColorRes.crystalBlue,
                              bottomSafeArea: false,
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: controller.onForgotPasswordClick,
                                child: Text(
                                  S.of(context).forgetPassword,
                                  style: MyTextStyle.montserratBold(
                                      size: 16, color: ColorRes.charcoalGrey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                const SizedBox(
                  height: 20,
                ),
                const PolicyText(),
                SizedBox(
                  height: AppBar().preferredSize.height / 3,
                )
              ],
            ),
          ),
          SafeArea(
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: const SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.arrow_back,
                  color: ColorRes.crystalBlue,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
