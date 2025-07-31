import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'home_screen_mobile.dart';
import 'home_screen_tablet.dart';
import 'home_screen_desktop.dart';  // เพิ่ม import ตัว desktop

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return const HomeScreenMobile();
          } else {
            return const HomeScreenMobile();
          }
        },
      ),
      tablet: (context) => OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return const HomeScreenTablet();
          } else {
            return const HomeScreenTablet();
          }
        },
      ),
      desktop: (context) => const HomeScreenDesktop(),  // เพิ่มส่วนนี้สำหรับ desktop

      watch: (context) => const HomeScreenMobile(),

      breakpoints: const ScreenBreakpoints(
        desktop: 1024,
        tablet: 768,
        watch: 200,
      ),
    );
  }
}
