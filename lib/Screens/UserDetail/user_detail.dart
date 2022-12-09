import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Screens/Authorization/login_screen.dart';
import 'package:new_project/Utils/colors.dart';
import 'package:new_project/Utils/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetail extends StatefulWidget {
  const UserDetail({Key? key}) : super(key: key);

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  bool loader = false;
  bool logOutLoader = false;

  var testDate;
  var name;
  var email;

  //var createdAt;
  //var verified;
  //var updated;

  loadData() async {
    setState(() {
      loader = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    userToken = prefs.getString("userToken");

    print(userId);
    print(userToken);

    try {
      http.Response response = await http.get(
          Uri.parse(userDetailURL + userId.toString()),
          headers: {"Authorization": "Bearer $userToken"});

      Map jsonData = jsonDecode(response.body);
      print(jsonData.toString());

      if (jsonData['status'] == 1) {
        setState(() {
          name = jsonData['data']['name'];
          print(name);
          email = jsonData['data']['email'];
          print(email);
          testDate = jsonData['data']['test_date'];
          print(testDate);
          loader = false;
        });
      } else {
        setState(() {
          loader = false;
        });
        print(jsonData['message']);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonData['message'])));
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

  logOut() async {
    setState(() {
      loader = true;
      logOutLoader = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");
    userId = prefs.getString("userId");

    print("$userId\n$userToken");

    try {
      http.Response response = await http.post(Uri.parse(userLogOutURL),
          headers: {"Authorization": "Bearer $userToken"});

      Map jsonData = jsonDecode(response.body);

      print("$jsonData");

      if (jsonData['status'] == 1) {
        await prefs.clear();

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Log Out successfully")));

        setState(() {
          logOutLoader = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false);
      } else {
        setState(() {
          logOutLoader = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Logout Error ")));
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
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: loader
          ? Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.2),
              child: const CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    bottom: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.025,
                    right: MediaQuery.of(context).size.width * 0.01,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(1),
                        // width: MediaQuery.of(context).size.width * 0.083,
                        // height: MediaQuery.of(context).size.height * 0.04,
                        child: Image.asset(
                          "assets/icons/person.png",
                          width: MediaQuery.of(context).size.width * 0.07,
                          height: MediaQuery.of(context).size.height * 0.03,
                          //fit: BoxFit.cover,
                          color: kLightBlack,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      Expanded(
                        child: Text(
                          name.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, color: kLightBlack),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    bottom: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.025,
                    right: MediaQuery.of(context).size.width * 0.01,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(1),
                        // width: MediaQuery.of(context).size.width * 0.083,
                        // height: MediaQuery.of(context).size.height * 0.04,
                        child: Image.asset(
                          "assets/icons/mail.png",
                          width: MediaQuery.of(context).size.width * 0.07,
                          height: MediaQuery.of(context).size.height * 0.03,
                          color: kLightBlack,
                          //fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.03,
                      ),
                      Expanded(
                        child: Text(
                          email.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: kLightBlack, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    bottom: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.025,
                    right: MediaQuery.of(context).size.width * 0.01,
                  ),
                  padding: EdgeInsets.all(2),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(1),
                        child: Image.asset(
                          color: kLightBlack,
                          width: MediaQuery.of(context).size.width * 0.07,
                          height: MediaQuery.of(context).size.height * 0.03,
                          "assets/icons/date.png",
                          //fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.03,
                      ),
                      Expanded(
                        child: Text(
                          testDate != null
                              ? "Last Test Date: $testDate"
                              : "last Test Date will show here",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: kLightBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    bottom: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.025,
                    right: MediaQuery.of(context).size.width * 0.01,
                  ),
                  padding: EdgeInsets.all(2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Logout"),
                              content: logOutLoader
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.09,
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator())
                                  : const Text("Are you sure to logout"),
                              actions: [
                                logOutLoader
                                    ? const Text("")
                                    : TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: kBlue,
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.18,
                                            child: Text(
                                              "No",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: kWhite,
                                                  fontSize: 16),
                                            )),
                                      ),
                                logOutLoader
                                    ? const Text("")
                                    : TextButton(
                                        onPressed: () {
                                          logOut();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: kBlue,
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.18,
                                          child: Text(
                                            "Yes",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: kWhite,
                                                fontSize: 16),
                                          ),
                                        ),
                                      )
                              ],
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              //width: MediaQuery.of(context).size.width * 0.083,
                              // height: MediaQuery.of(context).size.height * 0.04,
                              padding: EdgeInsets.all(1),
                              child: Image.asset(
                                "assets/icons/log-out.png",
                                color: kLightBlack,
                                width: MediaQuery.of(context).size.width * 0.07,
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                                // fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03,
                            ),
                            Text(
                              "Logout",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: kLightBlack, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const Text("")
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
