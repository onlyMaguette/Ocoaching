import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/appointment_screen/appointment_screen.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:patient_flutter/screen/dashboard_screen/widget/custom_animated_bottom_bar.dart';
import 'package:patient_flutter/screen/home_screen/home_screen.dart';
import 'package:patient_flutter/screen/message_screen/message_screen.dart';
import 'package:patient_flutter/screen/profile_screen/profile_screen.dart';
import 'package:patient_flutter/screen/specialists_screen/specialists_screen.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';

const bottomSheetStyle = TextStyle(fontSize: 12);

class DashboardScreen extends StatelessWidget {
  final Position? userLocation; // Modifier le type de Position à Position?

  const DashboardScreen({Key? key, this.userLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardScreenController());
    return GetBuilder(
      init: controller,
      builder: (context) {
        return Scaffold(
          backgroundColor: ColorRes.white,
          bottomNavigationBar: _buildBottomBar(controller),
          body: controller.currentIndex == 0
              ? const HomeScreen()
              : controller.currentIndex == 1
                  ? SpecialistsScreen(userLocation: userLocation)
                  : controller.currentIndex == 2
                      ? const AppointmentScreen()
                      : controller.currentIndex == 3
                          ? const MessageScreen()
                          : const ProfileScreen(),
        );
      },
    );
  }

  Widget _buildBottomBar(DashboardScreenController controller) {
    return CustomAnimatedBottomBar(
      containerHeight: 60,
      selectedIndex: controller.currentIndex,
      showElevation: true,
      curve: Curves.easeIn,
      onItemSelected: controller.onItemSelected,
      items: [
        BottomNavyBarItem(
          image: Icon(
            Icons.home,
            color:
                controller.currentIndex == 0 ? ColorRes.white : ColorRes.grey,
          ),
          title: Text(S.current.home, style: bottomSheetStyle),
        ),
        BottomNavyBarItem(
          image: Icon(
            Icons.medical_services_rounded,
            color:
                controller.currentIndex == 1 ? ColorRes.white : ColorRes.grey,
          ),
          title: Text(S.current.specialists, style: bottomSheetStyle),
        ),
        BottomNavyBarItem(
          image: Stack(
            children: [
              Icon(
                Icons.playlist_add_check,
                size: 30,
                color: controller.currentIndex == 2
                    ? ColorRes.white
                    : ColorRes.grey,
              ),
              if (controller.appointmentNotifications > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${controller.appointmentNotifications}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(S.current.appointments, style: bottomSheetStyle),
        ),
        BottomNavyBarItem(
          image: Image.asset(
            AssetRes.icQuote,
            width: 20,
            color:
                controller.currentIndex == 3 ? ColorRes.white : ColorRes.grey,
          ),
          title: Text(S.current.messages, style: bottomSheetStyle),
        ),
        BottomNavyBarItem(
          image: Icon(
            Icons.person,
            size: 28,
            color:
                controller.currentIndex == 4 ? ColorRes.white : ColorRes.grey,
          ),
          title: Text(S.current.profile, style: bottomSheetStyle),
        ),
      ],
    );
  }
}
