import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Screens/Authorization/signup.dart';
import 'package:new_project/Utils/home_page.dart';
import 'package:new_project/Utils/offline_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/CheckConnection.dart';
import '../../Utils/colors.dart';
import '../../Utils/url.dart';
import 'forgot_password.dart';

var userId;
var userToken;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DateTime? currentBackPressTime;

  bool _isObscure = true;
  bool isLogin = false;
  bool loader = false;

  bool checkConnection = false;

  void login() {
    if (_formKey.currentState!.validate()) {
      checkConnectivity();
    } else {
      return;
    }
  }

  checkConnectivity() async {
    if (await connection()) {
      loginApi();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  void loginApi() async {
    setState(() {
      loader = true;
      isLogin = true;
    });

    Map body = {
      "email": _emailController.text,
      'password': _passwordController.text
    };

    try {
      http.Response response = await http.post(Uri.parse(loginURL), body: body);

      print("status code   ${response.statusCode}");

      Map jsonData = jsonDecode(response.body);

      if (jsonData["status"] == 1) {
        setState(() {
          loader = false;
        });

        userId = (jsonData['data']['user']['id']);
        userToken = (jsonData['data']['token']);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("userId", userId.toString());
        prefs.setString("userToken", userToken);

        print("userId  $userId");
        print("userToken  $userToken");

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonData['message'])));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        setState(() {
          loader = false;
        });
        print("error message    ${jsonData['message']}");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid email/password"),
        ));
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

  @override
  Widget build(BuildContext context) {
    return checkConnection
        ? OfflineUI(function: checkConnectivity)
        : SafeArea(
            child: Scaffold(
            backgroundColor: kLightGrey,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1,
                        left: MediaQuery.of(context).size.width * 0.11),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Welcome !",
                        style: TextStyle(
                            color: kWhite,
                            fontSize: 32,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.11,
                      top: 6,
                    ),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Sign in to continue",
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                  ),
                  formWidget(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  const ForgotPasswordScreen())));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Forgot password ?",
                        style: TextStyle(color: kWhite),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  InkWell(
                    onTap: () {
                      login();
                    },
                    splashColor: kBlue,
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
                              "Login",
                              style: TextStyle(color: kWhite, fontSize: 20),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member  ",
                        style: TextStyle(color: kWhite),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.01,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SignupScreen()));
                        },
                        child: Text(
                          "Join",
                          style: TextStyle(
                              color: kBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ));
  }

  Widget formWidget() {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(4),
              child: TextFormField(
                style: TextStyle(color: kWhite),
                autofocus: false,
                autocorrect: false,
                controller: _emailController,
                validator: MultiValidator([
                  RequiredValidator(errorText: "Required *"),
                  EmailValidator(errorText: "Not a valid email")
                ]),
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: kWhite)),
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: kWhite,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    hintText: "Enter your e-mail",
                    hintStyle: TextStyle(color: kWhite)),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
              margin: const EdgeInsets.all(4),
              child: TextFormField(
                controller: _passwordController,
                validator: RequiredValidator(errorText: "Required *"),
                style: TextStyle(color: kWhite),
                autofocus: false,
                autocorrect: false,
                obscureText: _isObscure,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: kWhite)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: kWhite,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: kWhite,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    hintText: "Enter your password",
                    hintStyle: TextStyle(color: kWhite)),
              ),
            ),
          ],
        ));
  }
}
