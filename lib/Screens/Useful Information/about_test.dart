import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Models/about_test.dart';
import 'package:new_project/Utils/colors.dart';
import 'package:new_project/Utils/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/CheckConnection.dart';
import '../../Utils/offline_ui.dart';
import '../Authorization/login_screen.dart';

class AboutTest extends StatefulWidget {
  const AboutTest({Key? key}) : super(key: key);

  @override
  State<AboutTest> createState() => _AboutTestState();
}

class _AboutTestState extends State<AboutTest> {
  bool loader = true;
  bool checkConnection = false;

  List<AboutModel> aboutList = <AboutModel>[];

  checkConnectivity() async {
    if (await connection()) {
      callAboutTestApi();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  callAboutTestApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");

    try {
      http.Response response = await http.get(
        Uri.parse(aboutTestURL),
        headers: {"Authorization": "Bearer $userToken"},
      );

      print(userToken);
      print("browser == ${response.body}");

      Map jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        for (int i = 0; i < jsonData["data"].length; i++) {
          Map<String, dynamic> object = jsonData["data"][i];
          // print('latest ==' + object.toString());
          AboutModel about = AboutModel();

          about = AboutModel.fromJson(object);
          aboutList.add(about);
        }
        setState(() {
          loader = false;
        });
      } else {
        setState(() {
          loader = false;
        });
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
  void initState() {
    // TODO: implement initState
    super.initState();
    checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return checkConnection
        ? OfflineUI(function: checkConnectivity)
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: kLight,
              elevation: 0,
              title: const Text("About the test"),
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios),
              ),
            ),
            body: loader
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: aboutList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Html(
                              data: aboutList[index].content.toString(),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          );
  }
}
