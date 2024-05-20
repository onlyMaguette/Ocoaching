import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/custom/countries.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/complete_registration_screen/widget/country_sheet.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:patient_flutter/screen/login_screen/login_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/pref_service.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/update_res.dart';

class CompleteRegistrationScreenController extends GetxController {
  List<String> genders = [S.current.male, S.current.female];
  String selectGender = S.current.male;
  TextEditingController countryController = TextEditingController();
  TextEditingController dateController =
      TextEditingController(text: DateTime.now().formatDateTime(ddMMMYyyy));
  DateTime selectedDate = DateTime.now();
  PrefService prefService = PrefService();
  RegistrationData? userData;
  List<Country> countries = [];
  List<Country> filterCountry = [];
  Country? selectCountry;
  String countryName = '';
  PhoneNumber phoneNumber = PhoneNumber();

  int screenType;
  bool _isSubmitted = false;

  // Variables pour suivre l'état de validité de chaque champ
  var isPhoneNumberValid = false.obs;
  var isCountryValid = false.obs;
  var isGenderValid = false.obs;
  var isDateOfBirthValid = false.obs;

  bool isMobileNumberValid() {
    return phoneNumber.phoneNumber != null &&
        phoneNumber.phoneNumber!.isNotEmpty;
  }

  // Méthode pour vérifier si un pays est sélectionné
  bool isCountrySelected() {
    return selectCountry != null;
  }

  // Méthode pour vérifier si un genre est sélectionné
  bool isGenderSelected() {
    return selectGender.isNotEmpty;
  }

  // Méthode pour vérifier si la date de naissance est sélectionnée
  bool isDOBSelected() {
    return selectedDate != null;
  }

  bool isAllFieldsFilled() {
    return phoneNumber.phoneNumber != null &&
        phoneNumber.phoneNumber!.isNotEmpty &&
        selectCountry != null &&
        selectGender.isNotEmpty &&
        selectedDate != null;
  }

  CompleteRegistrationScreenController(this.screenType);

  @override
  void onInit() {
    prefData();
    super.onInit();
  }

  void onGenderChange(String? value) {
    selectGender = value!;
    update();
  }

  void selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.utc(DateTime.now().year, DateTime.now().month,
          DateTime.utc(DateTime.now().year, DateTime.now().month + 1, 0).day),
      builder: (context, child) {
        return Container(child: child);
      },
    );

    if (newSelectedDate != null) {
      selectedDate = newSelectedDate;
      dateController
        ..text = selectedDate.formatDateTime(ddMMMYyyy)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: dateController.text.length,
            affinity: TextAffinity.upstream));
    }
    update([kChangeDate]);
  }

  void prefData() async {
    await prefService.init();
    userData = prefService.getRegistrationData();
    countries = prefService.getCountries()?.country ?? [];
    filterCountry = prefService.getCountries()?.country ?? [];
    update();
  }

  Future<void> onSubmitBtnClick() async {
    // Vérification de tous les champs obligatoires
    if (!isAllFieldsFilled()) {
      // Affichez les messages d'erreur sous les champs
      CustomUi.snackBar(
        message: S.current.pleaseFillAllFields,
        iconData: Icons.error,
      );
      return;
    }

    //CustomUi.loader(); // Loader personnalisé (s'il est nécessaire)

    // Soumission des données
    ApiService.instance
        .updateUserDetails(
      phoneNumber:
          '${phoneNumber.phoneNumber?.replaceAll(phoneNumber.dialCode.toString(), '')} ${phoneNumber.isoCode}',
      countryCode: selectCountry?.phoneCode,
      gender: selectGender == S.current.male ? 1 : 0,
      dob: DateFormat(yyyyMMDd, 'en').format(selectedDate),
    )
        .then(
      (value) {
        if (value.status == true) {
          Get.back();
          CustomUi.snackBar(
            iconData: Icons.app_registration,
            positive: true,
            message:
                S.current.registrationSuccessfullyDonePleaseLoginToContinue,
          );
          // Redirigez vers le tableau de bord
          if (screenType == 0) {
            Get.offAll(() => const LoginScreen());
          } else {
            Get.offAll(() => const DashboardScreen());
          }
        } else {
          Get.back();
          CustomUi.snackBar(
            message: value.message ?? '',
            iconData: Icons.person,
          );
        }
      },
    );
  }

  @override
  void onClose() {
    dateController.dispose();
    super.onClose();
  }

  void countryBottomSheet() {
    Get.bottomSheet(
      GetBuilder<CompleteRegistrationScreenController>(builder: (context) {
        return CountrySheet(
            country: filterCountry,
            onCountryChange: onCountryChange,
            onCountryTap: onCountryTap,
            controller: countryController);
      }),
      isScrollControlled: true,
    ).then((value) {
      countryController.clear();
      filterCountry = countries;
    });
  }

  void onCountryTap(Country value) {
    countryName = value.countryName ?? '';
    selectCountry = value;
    update();
    Get.back();
  }

  void onCountryChange(String value) {
    filterCountry = countries.where((element) {
      return (element.countryName ?? '')
          .isCaseInsensitiveContains(countryController.text);
    }).toList();
    update();
  }

  void redirectToDashboardScreen() {
    Get.offAll(() => DashboardScreen());
  }
}
