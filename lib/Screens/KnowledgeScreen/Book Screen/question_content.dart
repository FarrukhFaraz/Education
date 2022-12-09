import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Screens/Authorization/login_screen.dart';
import 'package:new_project/Screens/KnowledgeScreen/Book%20Screen/demo_question.dart';
import 'package:new_project/Utils/colors.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utils/CheckConnection.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';

class QuestionContent extends StatefulWidget {
  const QuestionContent({
    Key? key,
    required this.topicId,
    required this.title,
  }) : super(key: key);

  final String title;
  final int topicId;

  @override
  State<QuestionContent> createState() => _QuestionContentState(topicId, title);
}

class _QuestionContentState extends State<QuestionContent> {
  _QuestionContentState(this.topicId, this.title);

  final String title;
  final int topicId;

  bool checkConnection = false;
  bool loader = false;
  bool noContent = false;
  String content = "";

  checkConnectivity() async {
    if (await connection()) {
      getQuestionContent();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  getQuestionContent() async {
    setState(() {
      loader = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");
    try {
      http.Response response = await http.get(
          Uri.parse(demoContentBookURL + topicId.toString()),
          headers: {"Authorization": "Bearer $userToken"});

      print(userToken);
      print(response.body.toString());

      Map jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        print(jsonData['msg']);

        setState(() {
          loader = false;
          content = jsonData['data']['content'];
        });
        print(content);
      } else {
        print(jsonData['msg']);
        setState(() {
          noContent = true;
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
    checkConnectivity();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return checkConnection
        ? OfflineUI(function: checkConnectivity)
        : Scaffold(
            appBar: AppBar(
              backgroundColor: kLight,
              centerTitle: true,
              elevation: 0,
              title: Text(title),
              leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios)),
            ),
            bottomNavigationBar: bottomNav(),
            body: loader
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : noContent
                    ? const Center(
                        child:
                            Text("There is no content available in this topic"),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: Html(
                          data: content,
                        )),
          );
  }

  Widget bottomNav() {
    return Container(
      color: bgWhite,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.09,
      child: Column(
        children: [
          LinearPercentIndicator(
            width: MediaQuery.of(context).size.width,
            lineHeight: 5,
            percent: 0,
            backgroundColor: kLightGreen,
            progressColor: kDarkGreen,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        color: kLightBlack,
                      ),
                      Text(
                        "Previous",
                        style: TextStyle(color: kLightBlack, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DemoQuestion(
                              title: title,
                              topicId: topicId,
                            )));
                  },
                  child: Row(
                    children: [
                      Text(
                        "Next",
                        style: TextStyle(color: kLightBlack, fontSize: 16),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: kLightBlack,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
