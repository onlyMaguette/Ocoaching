import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/chat/chat.dart';
import 'package:patient_flutter/model/custom/countries.dart';
import 'package:patient_flutter/model/global/global_setting.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/utils/firebase_res.dart';
import 'package:patient_flutter/utils/update_res.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  SharedPreferences? preferences;
  static int userId = -1;
  static String identity = '';

  Future init() async {
    preferences = await SharedPreferences.getInstance();
    return preferences;
  }

  Future<void> saveString({required String key, required String value}) async {
    await preferences?.setString(key, value);
    userId = getRegistrationData()?.id ?? -1;
    log('👉 $userId 👈');
    identity = getRegistrationData()?.identity ?? '';
  }

  Future<void> saveList(
      {required String key, required List<String> value}) async {
    await preferences?.setStringList(key, value);
  }

  String? getString({required String key}) {
    return preferences?.getString(key);
  }

  Future<void> setLogin({required String key, required bool value}) async {
    await preferences?.setBool(key, value);
  }

  bool? getBool({required String key}) {
    return preferences?.getBool(key);
  }

  RegistrationData? getRegistrationData() {
    final String? jsonString = getString(key: kRegistrationUser);
    if (jsonString == null) {
      return null;
    } else {
      try {
        return RegistrationData.fromJson(jsonDecode(jsonString));
      } catch (e) {
        log('Error decoding registration data: $e');
        return null;
      }
    }
  }

  GlobalSettingData? getSettings() {
    final String? jsonString = getString(key: kGlobalSetting);
    if (jsonString == null) return null;
    try {
      return GlobalSettingData.fromJson(jsonDecode(jsonString));
    } catch (e) {
      log('Error decoding global settings: $e');
      return null;
    }
  }

  Countries? getCountries() {
    final String? jsonString = getString(key: kCountries);
    if (jsonString == null) return null;
    try {
      return Countries.fromJson(jsonDecode(jsonString));
    } catch (e) {
      log('Error decoding countries data: $e');
      return null;
    }
  }

  void updateFirebaseProfile() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    RegistrationData? userData = getRegistrationData();
    if (userData == null) {
      log('No user data available, unable to update Firebase profile.');
      return;
    }
    String patientId = CommonFun.setPatientId(patientId: userData.id);
    db
        .collection(FirebaseRes.userChatList)
        .doc(patientId)
        .collection(FirebaseRes.userList)
        .withConverter(
          fromFirestore: Conversation.fromFirestore,
          toFirestore: (Conversation value, options) {
            return value.toFirestore();
          },
        )
        .get()
        .then((value) {
      for (var element in value.docs) {
        db
            .collection(FirebaseRes.userChatList)
            .doc(element.id)
            .collection(FirebaseRes.userList)
            .doc(patientId)
            .withConverter(
              fromFirestore: Conversation.fromFirestore,
              toFirestore: (Conversation value, options) {
                return value.toFirestore();
              },
            )
            .get()
            .then((value) {
          ChatUser? user = value.data()?.user;
          if (user != null) {
            user.username = userData.fullname ?? S.current.unKnown;
            user.image = userData.profileImage;
            user.userid = userData.id;
            db
                .collection(FirebaseRes.userChatList)
                .doc(element.id)
                .collection(FirebaseRes.userList)
                .doc(patientId)
                .update({FirebaseRes.user: user.toJson()});
          } else {
            log('No user data available for conversation ID: ${element.id}');
          }
        });
      }
    });
  }
}
