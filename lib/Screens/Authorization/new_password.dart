import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Screens/Authorization/forgot_password.dart';
import 'package:new_project/Screens/Authorization/login_screen.dart';
import 'package:new_project/Utils/colors.dart';

import '../../Utils/CheckConnection.dart';
import '../../Utils/offline_ui.dart';
import '../../Utils/url.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState(email);
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  _NewPasswordScreenState(this.email);

  final String email;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  String errorText = "";

  bool error = false;
  bool checkConnection = false;
  bool loader = false;
  String? userToken;

  formValidate() {
    setState(() {
      error = false;
    });
    if (_formKey.currentState!.validate()) {
      if (passwordController.text == rePasswordController.text) {
        checkConnectivity();
      } else {
        setState(() {
          error = true;
          errorText = "Password do not match";
        });
      }
    }
  }

  checkConnectivity() async {
    if (await connection()) {
      changePassword();
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

  changePassword() async {
    setState(() {
      loader = true;
    });

    Map body = {
      "password": passwordController.text.trim(),
      "password_confirmation": rePasswordController.text.trim(),
      "email": email
    };

    try {
      http.Response response =
          await http.post(Uri.parse(resetPasswordURL), body: body);

      Map jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password successfully changed")));
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Something went wrong\nPlease try again later!")));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong\nPlease try again later!")));
    }
    setState(() {
      loader = false;
    });
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
                        "Enter New Password",
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: passwordController,
                              validator: MultiValidator(
                                [
                                  RequiredValidator(errorText: "Required"),
                                  MinLengthValidator(
                                    6,
                                    errorText:
                                        "Password should be at least 6 character",
                                  ),
                                ],
                              ),
                              style: TextStyle(color: kWhite),
                              decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: kWhite)),
                                  prefixIcon: Icon(
                                    Icons.mail_outline,
                                    color: kWhite,
                                  ),
                                  labelText: "Enter password",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  hintText: "Enter password",
                                  hintStyle: TextStyle(color: kWhite)),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            TextFormField(
                              controller: rePasswordController,
                              style: TextStyle(color: kWhite),
                              autofocus: false,
                              decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: kWhite)),
                                  errorText: error ? errorText : null,
                                  prefixIcon: Icon(
                                    Icons.mail_outline,
                                    color: kWhite,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  hintText: "Re-enter password",
                                  labelText: "Re-enter password",
                                  hintStyle: TextStyle(color: kWhite)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    InkWell(
                      onTap: () {
                        if (loader == false) {
                          formValidate();
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
