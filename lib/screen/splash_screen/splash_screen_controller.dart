import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/custom/countries.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/auth_screen/auth_screen.dart';
import 'package:patient_flutter/screen/complete_registration_screen/complete_registration_screen.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/pref_service.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class SplashScreenController extends GetxController {
  PrefService prefService = PrefService();
  RegistrationData? userData;
  Countries? country;
  bool isLoading = true; // Set to true initially to display the spinner
  bool isLogin = false;

  void init() {
    prefData();
  }

  void prefData() async {
    await prefService.init();
    await countryData();
    isLogin = prefService.getBool(key: kLogin) ?? false;
    userData = prefService.getRegistrationData();
    PrefService.userId = userData?.id ?? -1;
    PrefService.identity = userData?.identity ?? '';

    update();
    navigateRoot();
  }

  Future<void> countryData() async {
    String response = await rootBundle.loadString(AssetRes.countryJson);
    country = Countries.fromJson(jsonDecode(response));
    String encode = jsonEncode(country?.toJson());
    prefService.saveString(key: kCountries, value: encode);
  }

  Future<void> navigateRoot() async {
    try {
      final globalSettings = await ApiService.instance.fetchGlobalSettings();
      print(globalSettings.status);
      if (globalSettings.status == true) {
        dollar = globalSettings.data?.currency ?? '\$';
        if (PrefService.userId == -1) {
          // If user is not logged in, redirect to the authentication screen
          Get.off(() => AuthScreen());
          return; // No need to continue, stop here
        } else {
          final profile = await ApiService.instance.fetchMyUserDetails();
          if (profile.status == true) {
            PrefService.userId = profile.data?.id ?? -1;
            PrefService.identity = profile.data?.identity ?? '';
            if (profile.data?.phoneNumber == null ||
                profile.data!.phoneNumber!.isEmpty) {
              if (isLogin) {
                Get.off(() => const CompleteRegistrationScreen(screenType: 1));
              } else {
                Get.off(() => const CompleteRegistrationScreen(screenType: 0));
              }
            } else {
              Get.off(() => const DashboardScreen());
            }
          }
        }
      } else {
        CustomUi.snackBar(
            iconData: Icons.error, message: S.current.somethingWentWrong);
      }
    } catch (error) {
      print('Error: $error');
      // Handle the error here, e.g., show an error message to the user
    } finally {
      // Stop the loading spinner when navigation is finished (whether successful or not)
      isLoading = false;
      update();
    }
  }

  void redirectToAuthScreen() {
    Get.off(() => AuthScreen());
  }
}
