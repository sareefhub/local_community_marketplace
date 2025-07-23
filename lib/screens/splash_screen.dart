import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_community_marketplace/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // wait 3 secs before MyHomePage
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFE0F3F7),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo-splash.png',
            width: 700,
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.white),
         ],
        ),
      ),
    );
  }
}