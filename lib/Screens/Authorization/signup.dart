import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Screens/Authorization/login_screen.dart';

import '../../Utils/CheckConnection.dart';
import '../../Utils/colors.dart';
import '../../Utils/offline_ui.dart';
import '../../Utils/url.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  bool error = false;
  bool _isObscure = true;
  bool _isObscure1 = true;
  bool loader = false;
  bool checkConnection = false;

  checkConnectivity() async {
    if (await connection()) {
      registerApi();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  formValidate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        error = false;
      });
      if (_passwordController.text == _rePasswordController.text) {
        checkConnectivity();
      } else {
        setState(() {
          error = true;
        });
      }
    } else {
      return;
    }
  }

  registerApi() async {
    setState(() {
      loader = true;
    });
    Map body = {
      'name': _nameController.text,
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _rePasswordController.text
    };

    try {
      http.Response response =
          await http.post(Uri.parse(registerURL), body: body);
      print(response.body);

      var jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        // ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(jsonData['message'])));
        var jsonData = jsonDecode(response.body.toString());
        print("message is   ${jsonData['message']}");
        //print(jsonData);
        setState(() {
          loader = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Registered successfully")));
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        setState(() {
          loader = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("This email has already been taken")));
        print(jsonData['message']);
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
                        top: MediaQuery.of(context).size.height * 0.08,
                        left: MediaQuery.of(context).size.width * 0.11,
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Create Account ",
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    formValidator(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    InkWell(
                      onTap: () {
                        formValidate();
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
                                "Signup",
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
                          "Already a member  ",
                          style: TextStyle(color: kWhite),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.01,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "SignIn",
                            style: TextStyle(
                                color: kBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget formValidator() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            child: TextFormField(
              controller: _nameController,
              validator: RequiredValidator(errorText: "Required"),
              style: TextStyle(color: kWhite),
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kWhite),
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: kWhite,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: "Enter name",
                  labelText: "Name",
                  hintStyle: TextStyle(color: kWhite)),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Container(
            margin: const EdgeInsets.all(4),
            child: TextFormField(
              controller: _emailController,
              validator: MultiValidator([
                RequiredValidator(errorText: "Required"),
                EmailValidator(errorText: "Not a valid email"),
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
                      borderRadius: BorderRadius.circular(12)),
                  labelText: "Email",
                  hintText: "Enter your email",
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
              validator: MultiValidator([
                RequiredValidator(errorText: "Required"),
                MinLengthValidator(6,
                    errorText: "Password should be at least 6 character"),
              ]),
              style: TextStyle(color: kWhite),
              obscureText: _isObscure,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kWhite),
                  ),
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
                  labelText: "Password",
                  hintText: "Enter your password",
                  hintStyle: TextStyle(color: kWhite)),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Container(
            margin: const EdgeInsets.all(4),
            child: TextFormField(
              controller: _rePasswordController,
              validator: RequiredValidator(errorText: "Required"),
              style: TextStyle(color: kWhite),
              obscureText: _isObscure1,
              decoration: InputDecoration(
                  errorText: error ? "Password do not match" : null,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kWhite),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure1 ? Icons.visibility_off : Icons.visibility,
                      color: kWhite,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure1 = !_isObscure1;
                      });
                    },
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: kWhite,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: "Re-enter password",
                  labelText: "Re-password",
                  hintStyle: TextStyle(color: kWhite)),
            ),
          ),
        ],
      ),
    );
  }
}
