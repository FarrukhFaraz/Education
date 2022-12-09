import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Models/booking_test.dart';
import 'package:new_project/Screens/Authorization/login_screen.dart';
import 'package:new_project/Utils/colors.dart';
import 'package:new_project/Utils/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/CheckConnection.dart';
import '../../Utils/offline_ui.dart';

class BookingTest extends StatefulWidget {
  const BookingTest({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<BookingTest> createState() => _BookingTestState();
}

class _BookingTestState extends State<BookingTest> {
  bool checkConnection = false;
  bool loader = true;
  List<BookingModel> bookingList = <BookingModel>[];

  checkConnectivity() async {
    if (await connection()) {
      callBookingTestApi();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  callBookingTestApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");

    try {
      http.Response response = await http.get(
        Uri.parse(bookingTestURL),
        headers: {"Authorization": "Bearer $userToken"},
      );

      print(userToken);
      print("browser == ${response.body}");

      Map jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        for (int i = 0; i < jsonData["data"].length; i++) {
          Map<String, dynamic> object = jsonData["data"][i];
          // print('latest ==' + object.toString());
          BookingModel booking = BookingModel();

          booking = BookingModel.fromJson(object);
          bookingList.add(booking);
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
              elevation: 0,
              backgroundColor: kLight,
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
                    itemCount: bookingList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Html(
                              data: bookingList[index].content.toString(),
                              /*style: {
                          "body": Style(
                              fontSize: FontSize(16),
                              fontWeight: FontWeight.bold)
                        },*/
                            )
                          ],
                        ),
                      );
                    },
                  ),
          );
  }
}
