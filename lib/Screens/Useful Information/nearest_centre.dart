import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Models/near_center.dart';
import 'package:new_project/Screens/Authorization/login_screen.dart';
import 'package:new_project/Utils/colors.dart';
import 'package:new_project/Utils/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Utils/CheckConnection.dart';
import '../../Utils/offline_ui.dart';

class NearestCentre extends StatefulWidget {
  const NearestCentre({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<NearestCentre> createState() => _NearestCentreState();
}

class _NearestCentreState extends State<NearestCentre> {
  bool checkConnection = false;
  bool loader = true;
  List<NearCenterModel> nearCentre = <NearCenterModel>[];

  checkConnectivity() async {
    if (await connection()) {
      callNearCenterApi();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  callNearCenterApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");

    try {
      http.Response response = await http.get(
        Uri.parse(nearestTestCenterURL),
        headers: {"Authorization": "Bearer $userToken"},
      );
      print("browser == ${response.body}");

      Map jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        for (int i = 0; i < jsonData["data"].length; i++) {
          Map<String, dynamic> object = jsonData["data"][i];
          // print('latest ==' + object.toString());
          NearCenterModel nearCenter = NearCenterModel();

          nearCenter = NearCenterModel.fromJson(object);
          nearCentre.add(nearCenter);
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

  static void navigateTo(String lat, String lng) async {
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch ${uri.toString()}';
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
              title: Text(widget.title),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.06,
                        vertical: MediaQuery.of(context).size.height * 0.02),
                    itemCount: nearCentre.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          navigateTo(nearCentre[index].lat.toString(),
                              nearCentre[index].lng.toString());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Image(
                                height: 24,
                                image: AssetImage("assets/icons/location.png")),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02,
                            ),
                            Expanded(
                              child: Text(
                                nearCentre[index].address != null
                                    ? nearCentre[index].address.toString()
                                    : 'No Name',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ));
  }
}
