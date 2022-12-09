import 'dart:async';

import 'package:auth_handler/auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:new_project/Screens/Authorization/forgot_password.dart';
import 'package:new_project/Utils/colors.dart';

import '../../Utils/CheckConnection.dart';
import '../../Utils/offline_ui.dart';
import 'new_password.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  bool checkConnection = false;
  bool loader = false;
  bool sendOTP = false;

  ///late EmailAuth auth;  this package has now limitation of only 30 mails,you can only verify 30 mails by this package

  AuthHandler authHandler = AuthHandler();

  sendOTPFunction() {
    setState(() {
      sendOTP = false;
    });

    try {
      authHandler.sendOtp(widget.email.trim().toString()).then((value) {
        print(value);
        if (value == true) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Otp Send')));
          setState(() {
            sendOTP = true;
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Otp not sent')));
          Navigator.pop(context);
        }
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Something went wrong!Check Network Connection')));
      Navigator.pop(context);
    }
  }

  checkConnectivity() async {
    if (await connection()) {
      // verifiedOtp();
      checkOtp();
      setState(() {
        loader = true;
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  checkOtp() {
    print('otp textfield: ${otpController.text.trim()}');
    try {
      authHandler.verifyOtp(otpController.text.trim()).then((value) {
        if (value == true) {
          Timer(const Duration(seconds: 2), () {
            setState(() {
              loader = false;
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Otp Verified')));
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => NewPasswordScreen(
                  email: widget.email.toString(),
                )));

          });
        } else {
          Timer(const Duration(seconds: 2), () {
            setState(() {
              loader = false;
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Invalid Otp')));
          });
        }
      });
    } catch (e) {
      print(e);
      setState(() {
        loader = false;
      });
      print('error occurred now');
    }
  }

  /*checkOtp() {
    var res = auth.validateOtp(
        recipientMail: email, userOtp: otpController.text.trim());
    if (res) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("OTP verified")));
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => NewPasswordScreen(
                email: email,
              )));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
    setState(() {
      loader = false;
    });
  }
  */

  @override
  void initState() {
    authHandler.config(
      senderEmail: "educationBook@gmail.com",
      senderName: "Education Book",
      otpLength: 6,
    );
    sendOTPFunction();
    // TODO: implement initState
    //auth = EmailAuth(sessionName: "Education");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: checkConnection
          ? OfflineUI(function: checkConnectivity)
          : Scaffold(
              backgroundColor: kLightGrey,
              body: sendOTP
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen()));
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
                              left: MediaQuery.of(context).size.width * 0.085,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Enter OTP",
                              style: TextStyle(
                                color: kWhite,
                                fontSize: 40,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Container(
                            margin: const EdgeInsets.all(4),
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: otpController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: kWhite),
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: kWhite)),
                                    prefixIcon: Icon(
                                      Icons.mail_outline,
                                      color: kWhite,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    hintText: "Enter otp",
                                    labelText: "Enter otp",
                                    hintStyle: TextStyle(color: kWhite)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                          ),
                          InkWell(
                            onTap: () {
                              if (otpController.text.isNotEmpty) {
                                if (loader == false) {
                                  checkConnectivity();
                                }
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
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Text(
                                      "Send",
                                      style: TextStyle(
                                          color: kWhite, fontSize: 20),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
    );
  }
}
