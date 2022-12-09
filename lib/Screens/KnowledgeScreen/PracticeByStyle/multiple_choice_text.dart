import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/question_model.dart';
import '../../../Utils/CheckConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/home_page.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';
import '../../Authorization/login_screen.dart';

class MultipleChoiceText extends StatefulWidget {
  const MultipleChoiceText({
    Key? key,
    required this.title,
    required this.topicStyle,
    required this.list,
  }) : super(key: key);

  final String title;
  final int topicStyle;
  final List<QuestionModel> list;

  @override
  State<MultipleChoiceText> createState() =>
      _MultipleChoiceTextState(title, topicStyle, list);
}

class _MultipleChoiceTextState extends State<MultipleChoiceText> {
  _MultipleChoiceTextState(this.title, this.topicStyle, this.list);

  final String title;
  final int topicStyle;
  final List<QuestionModel> list;

  bool click = false;
  bool click1 = false;
  bool click2 = false;
  bool click3 = false;
  bool click4 = false;

  bool checkAnswer = false;

  bool loader = false;
  bool checkConnection = false;

  double ratio = 0.0;
  int index = 0;
  int correctAnswer = 0;

  late List answer;

  checkConnectivity() async {
    if (await connection()) {
      submitData();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  submitData() async {
    print("correctAnswer $correctAnswer");
    print("wrong Answer ${list.length - correctAnswer}");
    print("total answer ${list.length}");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    userToken = prefs.getString("userToken");

    print(userId);
    print(userToken);

    Map body = {
      "user_id": userId.toString(),
      "question_type": topicStyle.toString(),
      "totalquestions": list.length.toString(),
      "correctanswer": correctAnswer.toString(),
      "falseanswer": (list.length - correctAnswer).toString()
    };

    try {
      http.Response response = await http.post(
          Uri.parse(submitMultipleTextStyleURL),
          headers: {"Authorization": "Bearer $userToken"},
          body: body);
      Map jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        setState(() {
          loader = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonData['message'])));
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        setState(() {
          loader = false;
        });
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

  @override
  void initState() {
    // TODO: implement initState
    // getList();

    setState(() {
      answer = list[index].answer!;
      ratio = 1 / list.length;
      print(ratio.toString());
      print(answer);
    });

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
              actions: [
                Container(
                    margin: const EdgeInsets.only(right: 6),
                    alignment: Alignment.center,
                    child: Text("Q.${index + 1}")),
              ],
            ),
            bottomNavigationBar: bottomNav(),
            body: loader
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(Icons.circle, size: 15)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(list[index].question!),
                              )
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  if (click == false) {
                                    click = true;
                                    click1 = true;
                                    click2 = false;
                                    click3 = false;
                                    click4 = false;

                                    if (answer[0] == "a") {
                                      print("correct");
                                      correctAnswer = correctAnswer + 1;
                                    } else {
                                      print("wrong");
                                    }
                                  }
                                });
                              },
                              child: question("a", list[index].a, click1)),
                          const SizedBox(height: 10),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  if (click == false) {
                                    click = true;
                                    click1 = false;
                                    click2 = true;
                                    click3 = false;
                                    click4 = false;

                                    if (answer[0] == "b") {
                                      print("correct");
                                      correctAnswer = correctAnswer + 1;
                                    } else {
                                      print("wrong");
                                    }
                                  }
                                });
                              },
                              child: question("b", list[index].b, click2)),
                          const SizedBox(height: 10),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  if (click == false) {
                                    click = true;
                                    click1 = false;
                                    click2 = false;
                                    click3 = true;
                                    click4 = false;

                                    if (answer[0] == "c") {
                                      print("correct");
                                      correctAnswer = correctAnswer + 1;
                                    } else {
                                      print("wrong");
                                    }
                                  }
                                });
                              },
                              child: question("c", list[index].c, click3)),
                          const SizedBox(height: 10),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  if (click == false) {
                                    click = true;
                                    click1 = false;
                                    click2 = false;
                                    click3 = false;
                                    click4 = true;

                                    if (answer[0] == "d") {
                                      print("correct");
                                      correctAnswer = correctAnswer + 1;
                                    } else {
                                      print("wrong");
                                    }
                                  }
                                });
                              },
                              child: question("d", list[index].d, click4)),
                        ],
                      ),
                    ),
                  ),
          );
  }

  Widget question(String option, String? text, bool check) {
    String icon = "assets/icons/no.png";
    Color color = kLightRed;
    Color iconColor = Colors.red;

    if (click == true) {
      if (answer[0] == option) {
        setState(() {
          icon = "assets/icons/check.png";
          color = kLightGreen;
          iconColor = Colors.green;
        });
      }
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: MediaQuery.of(context).size.height*0.02,
      ),
      // alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
     // height: MediaQuery.of(context).size.height * 0.07,
      decoration: BoxDecoration(
          border: check
              ? Border.all()
              : Border.all(width: 1.5, color: click ? color : kLightBlack),
          color: check ? kLightBLue : bgWhite,
          borderRadius: BorderRadius.circular(6)),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          click
              ? Image.asset(
                icon,
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.06,
                color: iconColor,
              )
              : const SizedBox(),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              text!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
            percent: ratio,
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
                    if (click == true) {
                      setState(() {
                        click = false;
                        click1 = false;
                        click2 = false;
                        click3 = false;
                        click4 = false;
                      });
                      if (index < (list.length - 1)) {
                        setState(() {
                          index++;
                          ratio = ratio + (1 / list.length);
                          if(ratio>1){
                            ratio=1.0;
                          }
                          print(ratio);
                          answer = list[index].answer!;
                        });
                      } else {
                        setState(() {
                          loader = true;
                        });
                        checkConnectivity();
                      }
                    }
                  },
                  child: Row(
                    children: [
                      index == (list.length - 1)
                          ? Text(
                              "Submit",
                              style: TextStyle(
                                  color: click ? kLightBlack : bgBlack,
                                  fontSize: 16),
                            )
                          : Text(
                              "Next",
                              style: TextStyle(
                                  color: click ? kLightBlack : bgBlack,
                                  fontSize: 16),
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
