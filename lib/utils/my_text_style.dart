import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';

class MyTextStyle {
  static TextStyle montserratBlack({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.black,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratBold({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.bold,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratExtraBold({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.extraBold,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratLight({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.light,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratMedium({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.medium,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratRegular({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.regular,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratSemiBold({double? size, Color? color}) {
    return TextStyle(
      fontFamily: FontRes.semiBold,
      fontSize: size ?? 16,
      color: color ?? ColorRes.black,
    );
  }

  static TextStyle montserratThin({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.thin,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static const linearTopGradient = LinearGradient(
    colors: [
      ColorRes.crystalBlue,
      ColorRes.tuftsBlue100,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const linearLeftGradient = LinearGradient(
      colors: [ColorRes.crystalBlue, ColorRes.tuftsBlue100],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight);

  static const linearBottomGradient = LinearGradient(
    colors: [
      ColorRes.tuftsBlue100,
      ColorRes.crystalBlue,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const linearGreyGradient = LinearGradient(
    colors: [
      ColorRes.whiteSmoke,
      ColorRes.whiteSmoke,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
