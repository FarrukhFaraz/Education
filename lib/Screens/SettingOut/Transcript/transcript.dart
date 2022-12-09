import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Models/transcript_model.dart';
import 'package:new_project/Utils/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utils/CheckConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/offline_ui.dart';
import '../../Authorization/login_screen.dart';

class Transcript extends StatefulWidget {
  const Transcript({Key? key}) : super(key: key);

  @override
  State<Transcript> createState() => _TranscriptState();
}

class _TranscriptState extends State<Transcript> {
  bool loader = true;
  bool checkConnection = false;

  List<TranscriptModel> contentList = <TranscriptModel>[];

  checkConnectivity() async {
    if (await connection()) {
      contentApi();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  contentApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");

    try {
      http.Response response = await http.get(
        Uri.parse(transcriptURL),
        headers: {"Authorization": "Bearer $userToken"},
      );

      print(userToken);
      print("browser == ${response.body}");

      Map jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        for (int i = 0; i < jsonData["data"].length; i++) {
          Map<String, dynamic> object = jsonData["data"][i];
          // print('latest ==' + object.toString());
          TranscriptModel content = TranscriptModel();

          content = TranscriptModel.fromJson(object);
          contentList.add(content);
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
              title: const Text("Transcript"),
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
                    itemCount: contentList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Html(
                              data: contentList[index].settcontent.toString(),
                            ),
                            SizedBox(height: 15),
                            const Divider(indent: 0, endIndent: 0,thickness: 2),
                          ],
                        ),
                      );
                    },
                  ),
          );
  }
}
