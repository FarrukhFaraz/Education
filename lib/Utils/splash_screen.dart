import 'dart:async';

import 'package:flutter/material.dart';
import 'package:new_project/Screens/Authorization/login_screen.dart';
import 'package:new_project/Utils/colors.dart';
import 'package:new_project/Utils/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  splash() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var userToken = sharedPreferences.getString("userToken");
    Timer(const Duration(milliseconds: 1600), (() {
      if (userToken == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: ((context) => const LoginScreen())));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: ((context) => const HomePage())));
      }
    }));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    splash();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kLightGrey,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width,
            ),
          ],
        ),
      ),
    );
  }
}
