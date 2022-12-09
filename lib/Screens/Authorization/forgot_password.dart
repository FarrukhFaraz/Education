import 'dart:convert';

import 'package:auth_handler/auth_handler.dart';
import 'package:email_auth/email_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Screens/Authorization/login_screen.dart';
import 'package:new_project/Screens/Authorization/otp_screen.dart';

import '../../Utils/CheckConnection.dart';
import '../../Utils/colors.dart';
import '../../Utils/offline_ui.dart';
import '../../Utils/url.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  TextEditingController otp = TextEditingController();
  late EmailAuth auth;
  AuthHandler authHandler = AuthHandler();

  bool loader = false;
  bool checkConnection = false;

  checkConnectivity() async {
    if (await connection()) {
      userExistApi();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  userExistApi() async {
    setState(() {
      loader = true;
    });
    //SharedPreferences prefs = await SharedPreferences.getInstance();

    Map body = {"email": _emailController.text.trim()};
    try {
      http.Response response =
          await http.post(Uri.parse(forgotPasswordURL), body: body);
      Map jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
       // auth = EmailAuth(sessionName: "Education");
        setState(() {
          loader=false;
        });

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OtpScreen(
              email: _emailController.text.trim(),
            )));

        //sendOtp();

      } else {
        setState(() {
          loader = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user found with this email")));
      }
    } catch (e) {
      print(e);
      setState(() {
        loader = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something went wrong!")));
    }
  }

  /*sendOtp() async {
    setState(() {
      loader = true;
    });
    var res = await auth.sendOtp(recipientMail: _emailController.text.trim());
    if (res) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("OTP has been sent")));
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OtpScreen(
                email: _emailController.text.trim(),
              )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong\nTry again later")));
    }
    setState(() {
      loader = false;
    });
  }*/

  @override
  void initState() {
/*
    authHandler.config(
      senderEmail: "noreply@copyit.dev",
      senderName: "Education",
      otpLength: 6,
    );*/

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return checkConnection
        ? OfflineUI(function: checkConnectivity)
        : SafeArea(
            child: Scaffold(
              backgroundColor: kLightGrey,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.02,
                          top: MediaQuery.of(context).size.height * 0.032,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: kWhite,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.11,
                          left: MediaQuery.of(context).size.width * 0.11),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _emailController,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "Required"),
                            EmailValidator(errorText: "Not a valid E-mail")
                          ]),
                          style: TextStyle(color: kWhite),
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kWhite),
                              ),
                              prefixIcon: Icon(
                                Icons.mail_outline,
                                color: kWhite,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: "Enter your email",
                              hintStyle: TextStyle(color: kWhite)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    InkWell(
                      onTap: () {
                        if (loader == false) {
                          checkConnectivity();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          color: kBlack,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: loader
                            ? const CircularProgressIndicator()
                            : Text(
                                "Send",
                                style: TextStyle(color: kWhite, fontSize: 20),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
