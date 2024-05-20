import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class DashboardTopBarTitle extends StatelessWidget {
  final String title;

  const DashboardTopBarTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white, // Bleu clair
            ColorRes.crystalBlue, // Bleu foncé
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Text(
          title.toUpperCase(),
          style: MyTextStyle.montserratBold(
            size: 17,
            color: ColorRes.charcoalGrey,
          ),
        ),
      ),
    );
  }
}
