import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/edit_profile_screen/edit_profile_screen_controller.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileScreenController());
    var isCoach =
        false.obs; // This variable will determine if the user is a coach.

    return Scaffold(
      backgroundColor: ColorRes.white,
      body: GetBuilder(
        init: controller,
        builder: (context) {
          return Scrollbar(
            // Ajout de Scrollbar
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TopBarArea(title: S.current.editProfile),
                  GetBuilder(
                    init: controller,
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: InkWell(
                          onTap: controller.onImageTap,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: controller.imageFile != null
                                    ? Image.file(
                                        controller.imageFile!,
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : controller.userData?.profileImage != null
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                '${ConstRes.itemBaseURL}${controller.userData?.profileImage}',
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) {
                                              return CustomUi.doctorPlaceHolder(
                                                  gender: controller
                                                      .userData?.gender);
                                            },
                                          )
                                        : CustomUi.userPlaceHolder(
                                            height: 120,
                                            gender:
                                                controller.userData?.gender ??
                                                    0,
                                          ),
                              ),
                              Container(
                                height: 28,
                                width: 28,
                                margin: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: ColorRes.charcoalGrey,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      child: Image.asset(
                                        AssetRes.messageEditBox,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      S.current.yourFullname,
                      style: TextStyle(
                        fontSize: 15,
                        color: ColorRes.black,
                        fontWeight: FontWeight.bold, // Texte en gras
                      ),
                    ),
                  ),
                  GetBuilder(
                    init: controller,
                    builder: (context) {
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: ColorRes.silverChalice.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: controller.fullNameController,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                            border: InputBorder.none,
                            //labelText: 'Full Name', // Libellé en gras
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          style: MyTextStyle.montserratBold(
                            size: 17,
                            color: ColorRes.charcoalGrey,
                          ),
                          cursorColor: ColorRes.charcoalGrey,
                          cursorHeight: 17,
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      S.current.profilePhoto,
                      style: TextStyle(
                        fontSize: 15,
                        color: ColorRes.black,
                        fontWeight: FontWeight.bold, // Texte en gras
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: InkWell(
                      onTap: controller.onImageTap,
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          SizedBox(width: 10),
                          Text(S.current.changePhoto),
                        ],
                      ),
                    ),
                  ),
                  Obx(() {
                    if (isCoach.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              S.current.specialities,
                              style: TextStyle(
                                fontSize: 15,
                                color: ColorRes.black,
                                fontWeight: FontWeight.bold, // Texte en gras
                              ),
                            ),
                          ),
                          GetBuilder(
                            init: controller,
                            builder: (context) {
                              return Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      ColorRes.silverChalice.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: controller.specialitiesController,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    border: InputBorder.none,
                                    //labelText: 'Specialities', // Libellé en gras
                                  ),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: MyTextStyle.montserratBold(
                                    size: 17,
                                    color: ColorRes.charcoalGrey,
                                  ),
                                  cursorColor: ColorRes.charcoalGrey,
                                  cursorHeight: 17,
                                ),
                              );
                            },
                          ),
                          // Services Offerts
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              S.current.servicesOffered,
                              style: TextStyle(
                                fontSize: 15,
                                color: ColorRes.black,
                                fontWeight: FontWeight.bold, // Texte en gras
                              ),
                            ),
                          ),
                          GetBuilder(
                            init: controller,
                            builder: (context) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(
                                      () => CheckboxListTile(
                                        title: Text(
                                          S.current.groupCoaching,
                                          style: TextStyle(
                                            color: Color(0xff235689),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        value: controller
                                            .isGroupCoachingSelected.value,
                                        onChanged: (newValue) {
                                          controller.setGroupCoaching(
                                              newValue ?? false);
                                        },
                                      ),
                                    ),
                                    Obx(
                                      () => CheckboxListTile(
                                        title: Text(
                                          S.current.seminar,
                                          style: TextStyle(
                                            color: Color(0xff235689),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        value:
                                            controller.isSeminarSelected.value,
                                        onChanged: (newValue) {
                                          controller
                                              .setSeminar(newValue ?? false);
                                        },
                                      ),
                                    ),
                                    Obx(
                                      () => CheckboxListTile(
                                        title: Text(
                                          S.current.conference,
                                          style: TextStyle(
                                            color: Color(0xff235689),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        value: controller
                                            .isConferenceSelected.value,
                                        onChanged: (newValue) {
                                          controller
                                              .setConference(newValue ?? false);
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    // Ajoute un espacement entre les CheckboxListTile et le TextField
                                    TextField(
                                      controller:
                                          controller.customServiceController,
                                      decoration: InputDecoration(
                                        hintText: S.current.enterCustomService,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Liens vers les Réseaux Sociaux
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              S.current.socialMediaLinks,
                              style: TextStyle(
                                fontSize: 15,
                                color: ColorRes.black,
                                fontWeight: FontWeight.bold, // Texte en gras
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextField(
                              controller: controller.socialMediaController,
                              decoration: const InputDecoration(
                                hintText: 'Facebook, Twitter, LinkedIn...',
                              ),
                            ),
                          ),
                          // Modifier le Tarif des Séances
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              S.current.sessionRate,
                              style: TextStyle(
                                fontSize: 15,
                                color: ColorRes.black,
                                fontWeight: FontWeight.bold, // Texte en gras
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextField(
                              controller: controller.sessionRateController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '${S.current.sessionRate}...',
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return SizedBox
                          .shrink(); // Return an empty widget if not a coach.
                    }
                  }),
                  SizedBox(height: 20), // Ajout d'un espacement fixe
                  SafeArea(
                    top: false,
                    child: TextButtonCustom(
                      onPressed: controller.onContinueTap,
                      title: S.current.continueText,
                      titleColor: ColorRes.white,
                      backgroundColor: Color(0xff235689),
                      bottomMargin: 10,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
