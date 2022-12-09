import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Utils/colors.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/smart_ques_model.dart';
import '../../../Utils/CheckConnection.dart';
import '../../../Utils/home_page.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';
import '../../Authorization/login_screen.dart';

class SmartPractice extends StatefulWidget {
  const SmartPractice({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SmartPractice> createState() => _SmartPracticeState(title);
}

class _SmartPracticeState extends State<SmartPractice> {
  _SmartPracticeState(this.title);

  final String title;

  bool click = false;
  bool clickA = false;
  bool clickB = false;
  bool clickC = false;
  bool clickD = false;

  bool noQuestion = false;
  bool checkAnswer = false;

  bool submit = false;
  bool checkConnection = false;
  bool loader = false;

  int correctAnswer = 0;

  double ratio = 0.0;
  int index = 0;
  List<SmartQuestion> list = <SmartQuestion>[];
  late List answer;

  checkConnectivity() async {
    if (await connection()) {
      getList();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  getList() async {
    setState(() {
      loader = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");

    try {
      http.Response response = await http.get(
          Uri.parse(questionSmartPracticeURL),
          headers: {"Authorization": "Bearer $userToken"});

      print(userToken);

      Map jsonData = jsonDecode(response.body);
//    print(jsonData.toString());

      if (jsonData['status'] == 1) {
        for (int i = 0; i < jsonData['data'].length; i++) {
          Map<String, dynamic> obj = jsonData['data'][i];
          SmartQuestion pos = SmartQuestion();
          pos = SmartQuestion.fromJson(obj);
          list.add(pos);
          print(list.toString());
        }

        setState(() {
          if (list.isNotEmpty) {
            ratio = 1 / list.length;
            answer = list[index].answer!;
            print(answer.toString());
          } else {
            noQuestion = true;
          }
          loader = false;
        });
      } else {
        setState(() {
          loader = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error")));
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

  submitListData() async {
    if (await connection()) {
      submitData();
      setState(() {
        submit = false;
        checkConnection = false;
      });
    } else {
      setState(() {
        submit = true;
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
      "smart_practice": "smart_practice",
      "totalquestions": list.length.toString(),
      "correctanswer": correctAnswer.toString(),
      "falseanswer": (list.length - correctAnswer).toString()
    };

    try {
      http.Response response = await http.post(
          Uri.parse(submitResultSmartPracticeURL),
          headers: {"Authorization": "Bearer $userToken"},
          body: body);

      Map jsonData = jsonDecode(response.body);
      print(jsonData.toString());

      if (jsonData['status'] == 1) {
        setState(() {
          loader = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonData['message'])));

        Navigator.pop(context);
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
    checkConnectivity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return checkConnection
        ? OfflineUI(function: submit ? submitListData : checkConnectivity)
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
                  child: list.isEmpty ? const Text("") : Text("Q.${index + 1}"),
                ),
              ],
            ),
            bottomNavigationBar: bottomNav(),
            body: loader
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : list.isEmpty
                    ? noQuestionWidget()
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
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                              ),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (click == false) {
                                        click = true;
                                        clickA = true;
                                        clickB = false;
                                        clickC = false;
                                        clickD = false;

                                        if (answer[0] == "a") {
                                          print("correct");
                                          correctAnswer = correctAnswer + 1;
                                        } else {
                                          print("wrong");
                                        }
                                      }
                                    });
                                  },
                                  child: question("a", list[index].a, clickA)),
                              const SizedBox(height: 10),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (click == false) {
                                        click = true;
                                        clickA = false;
                                        clickB = true;
                                        clickC = false;
                                        clickD = false;

                                        if (answer[0] == "b") {
                                          correctAnswer = correctAnswer + 1;
                                          print("correct");
                                        } else {
                                          print("wrong");
                                        }
                                      }
                                    });
                                  },
                                  child: question("b", list[index].b, clickB)),
                              const SizedBox(height: 10),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (click == false) {
                                        click = true;
                                        clickA = false;
                                        clickB = false;
                                        clickC = true;
                                        clickD = false;

                                        if (answer[0] == "c") {
                                          correctAnswer = correctAnswer + 1;
                                          print("correct");
                                        } else {
                                          print("wrong");
                                        }
                                      }
                                    });
                                  },
                                  child: question("c", list[index].c, clickC)),
                              const SizedBox(height: 10),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (click == false) {
                                        click = true;
                                        clickA = false;
                                        clickB = false;
                                        clickC = false;
                                        clickD = true;

                                        if (answer[0] == "d") {
                                          correctAnswer = correctAnswer + 1;
                                          print("correct");
                                        } else {
                                          print("wrong");
                                        }
                                      }
                                    });
                                  },
                                  child: question("d", list[index].d, clickD)),
                            ],
                          ),
                        ),
                      ),
          );
  }

  Widget noQuestionWidget() {
    setState(() {
      noQuestion = true;
    });
    print(noQuestion.toString());
    return const Center(
      child: Text("There are no questions in this topic",),
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
      //height: MediaQuery.of(context).size.height * 0.07,,
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
              maxLines: 10,
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
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (click == true || noQuestion == true) {
                          setState(() {
                            click = false;
                            clickA = false;
                            clickB = false;
                            clickC = false;
                            clickD = false;
                            if (index < (list.length - 1)) {
                              ratio = ratio + (1 / list.length);
                              if(ratio>1){
                                ratio=1.0;
                              }
                              print(ratio);
                              index++;
                              answer = list[index].answer!;
                            } else {
                              loader = true;
                              submitListData();
                            }
                          });
                        }
                      },
                      child: index == (list.length - 1)
                          ? Text(
                              "Submit",
                              style: TextStyle(
                                  color:
                                      (click == true) ? kLightBlack : bgBlack,
                                  fontSize: 16),
                            )
                          : Text(
                              "Next",
                              style: TextStyle(
                                  color:
                                      (click == true) ? kLightBlack : bgBlack,
                                  fontSize: 16),
                            ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: kLightBlack,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
