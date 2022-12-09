import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Models/FillInBlankModel.dart';
import 'package:new_project/Utils/home_page.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utils/CheckConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';
import '../../Authorization/login_screen.dart';

class FillBlank extends StatefulWidget {
  const FillBlank({Key? key}) : super(key: key);

  @override
  State<FillBlank> createState() => _FillBlankState();
}

class _FillBlankState extends State<FillBlank> {
  List<FillBlankModel> list = <FillBlankModel>[];

  List<String> optionList = <String>[];
  List<String> ansList = <String>[];

  List<String> trashAns = <String>[];
  List<String> trashList = <String>[];
  List<String> checkList = [];

  List<String> numberOfAnswer = <String>[];

  bool checkConnection = false;
  bool loader = false;

  bool submit = false;
  bool nextPage = false;

  bool noQuestion = false;

  // bool rebuild = false;

  bool noMoreData = false;
  bool firstCorrect = false;

  int index = 0;
  double ratio = 0.0;
  int k = 0;
  int correctQuestion = 0;
  int checkQ = 0; //// its value is 1 for correct answer and 2 for wrong answer

  String number = "";
  String? question;

  double height=0.0;

  checkConnectivity() async {
    if (await connection()) {
      if (submit) {
        submitData();
      } else {
        getList();
      }
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
      http.Response response = await http
          .get(Uri.parse(fillInTheBlankURL), headers: {"Authorization": "Bearer $userToken"});

      Map jsonData = jsonDecode(response.body);
      print(jsonData);
      if (jsonData['statusCode'] == 200) {
        for (int i = 0; i < jsonData['data'].length; i++) {
          Map<String, dynamic> obj = jsonData['data'][i];
          FillBlankModel pos = FillBlankModel();
          pos = FillBlankModel.fromJson(obj);
          list.add(pos);
        }
        setState(() {
          question = list[index].question!;
          optionList.addAll(list[index].quesOption!);
          numberOfAnswer.addAll(optionList);
          ansList.addAll(list[index].answer!);
          trashAns.addAll(ansList);
          if (list.isNotEmpty) {
            ratio = 1 / list.length;
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
          .showSnackBar(const SnackBar(content: Text("Error")));
    }
  }
  submitData() async {
    setState(() {
      loader = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('userId');
    var token = prefs.getString('userToken');

    print('id+=$id\ntoken+=$token');

    Map body = {
      "user_id": id.toString(),
      "fillblank": "fillblank",
      "totalquestions": list.length.toString(),
      "correctanswer": correctQuestion.toString(),
      "falseanswer": (list.length - correctQuestion).toString(),
    };
    try {
      http.Response response = await http.post(Uri.parse('https://accountpos.shoaibkanwalacademy.com/Questionbook/public/api/topicresult'),
          headers: {"Authorization": "Bearer $token"}, body: body);

      Map jsonData = jsonDecode(response.body);
      if (jsonData['status'] == 1) {
        setState(() {
          loader = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Test submitted successfully")));
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        setState(() {
          loader = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something went wrong!")));
      }
    } catch (e) {
      print(e);
      setState(() {
        loader = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Something went wrong!')));
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
    int count = 0 ;
    for(int i=0; i<numberOfAnswer.length; i++){
      if(numberOfAnswer[i].toString().length>50){
        count++;
      }
    }
    if(count==0){
      height=MediaQuery.of(context).size.height*0.15;
    }else{
      height=MediaQuery.of(context).size.height*0.3;
    }


    return checkConnection
        ? OfflineUI(function: checkConnectivity)
        : Scaffold(
            appBar: AppBar(
              backgroundColor: kLight,
              centerTitle: true,
              elevation: 0,
              title: const Text("Fill in the Blanks"),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DragTarget(
                                onAccept: (ans) {
                                  print(ans);
                                  if (question!.contains("_")) {
                                    String ques = ans as String;
                                    setState(() {
                                      number = question!;
                                    });
                                    int count = 0;
                                    List<int> li = [];
                                    String num = question!;
                                    for (int i = 0; i < num.length; i++) {
                                      if (num[i] == "_") {
                                        count++;
                                        li.add(i);
                                      } else {
                                        if (count != 0) {
                                          break;
                                        }
                                      }
                                    }

                                    setState(() {
                                      question =
                                          "<p>${num.replaceRange(li[0], li[li.length - 1] + 1, "<span style='background-color: white;font-size:16px;'><u><b> ${"  $ques   "}</b></u></span>")}</p>";

                                      number = num.replaceRange(
                                          li[0], li[li.length - 1] + 1, ques);
                                      optionList.remove(ques);
                                      trashAns.removeAt(0);
                                      checkList.add(ques);
                                    });
                                  }
                                  if (optionList.isEmpty) {
                                    if (checkList.length == ansList.length) {
                                      int count = 0;
                                      for (int i = 0; i < checkList.length; i++) {
                                        if (checkList[i] == ansList[i]) {
                                          count++;
                                        }
                                      }
                                      if (count == ansList.length) {
                                        setState(() {
                                          correctQuestion++;
                                          checkQ = 1;
                                          nextPage = true;
                                        });
                                      } else {
                                        setState(() {
                                          checkQ = 2;
                                          nextPage = true;
                                        });
                                      }
                                    } else if (!question!.contains('_')) {
                                      setState(() {
                                        nextPage = true;
                                      });
                                    } else {
                                      //// move to next question as invalid question
                                      /// total blanks are not equals to ansList
                                      setState(() {
                                        checkQ = 2;
                                        nextPage = true;
                                      });
                                    }
                                  }
                                },
                                builder: (context, accept, data) {
                                  return Column(
                                    children: [
                                      Wrap(
                                        children: [
                                          RichText(
                                              text: WidgetSpan(
                                                  child: Wrap(
                                            children: [
                                              Html(
                                                data: question,
                                                style: {
                                                  "body": Style(
                                                    lineHeight:
                                                        LineHeight.number(1.5),
                                                  ),
                                                },
                                              ),
                                            ],
                                          ))),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      checkQ == 1
                                          ? Text(
                                              "Correct",
                                              style: TextStyle(
                                                  color: kDarkGreen,
                                                  fontSize: 16),
                                            )
                                          : checkQ == 2
                                              ? Text(
                                                  "Wrong",
                                                  style: TextStyle(
                                                      color: kRed, fontSize: 16),
                                                )
                                              : const SizedBox(),
                                    ],
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.06),
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 9
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black54),
                                  borderRadius: BorderRadius.circular(12),
                                  color: kLightBLue),
                              alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height * 0.18,
                              child: dragTarget(
                                  trashList, "Drag all wrong answers here"),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.06,
                            ),
                            draggableWidget(),
                          ],
                        ),
                      ),
          );
  }

  Widget noQuestionWidget() {
    setState(() {
      noQuestion = true;
    });
    return const Center(
      child: Text("There are no questions in this topic"),
    );
  }

  Widget draggableWidget() {
    print("This is height $height");
    return SizedBox(
      height: /*MediaQuery.of(context).size.height*0.3*/height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        //scrollDirection: Axis.horizontal,
        children: optionList.map((answer) {
          return Container(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.019),
            child: Draggable(
              data: answer,
              onDragStarted: () {
                setState(() {
                  noMoreData = false;
                });
              },
              onDragCompleted: () {
                setState(() {});
              },
              feedback: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width/2 ,
                height: 15,
                //height: MediaQuery.of(context).size.height * 0.04,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: kLightBLue,
                ),
                child: Text(
                  answer,
                  style: const TextStyle(
                      fontSize: 14, decoration: TextDecoration.none),
                ),
              ),
              childWhenDragging: Container(
                //height: 50,
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width * 0.17,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kYellow, width: 2)),
                child: Text(answer),
              ),
              child: Container(
                alignment: Alignment.center,
                //height: 50,
                width: (MediaQuery.of(context).size.width-(MediaQuery.of(context).size.width * (0.03)*numberOfAnswer.length))/numberOfAnswer.length,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kGrey, width: 2)),
                child: Text(
                  answer,
                  maxLines: 15,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget dragTarget(List<String> dataList, String text) {
    return DragTarget(
      builder: (context, data, rejectedData) {
        if (dataList.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 6),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.05,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black26),
            ),
          );
        } else {
          return Stack(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: dataList.length,
                itemBuilder: (context, ind) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    decoration: BoxDecoration(
                      color: kLightBLue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    width: double.infinity,
                    child: Text(
                      (dataList[ind]),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
              noMoreData
                  ? Positioned(
                      left: 10,
                      top: MediaQuery.of(context).size.height * 0.03,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Please first fill the remaining blanks",
                            style: TextStyle(fontSize: 16, color: kRed),
                          ),
                          Image.asset(
                            "assets/icons/no.png",
                            height: MediaQuery.of(context).size.width * 0.08,
                          )
                        ],
                      ),
                    )
                  : SizedBox(),
            ],
          );
        }
      },
      onAccept: (dat) {
        setState(() {
          noMoreData = false;
        });
        String wrong = dat as String;
        if (optionList.isNotEmpty) {
          if (optionList.length > trashAns.length) {
            setState(() {
              trashList.add(wrong);
              optionList.remove(wrong);
            });
          } else if (!question!.contains('_')) {
            setState(() {
              trashList.add(wrong);
              optionList.remove(wrong);
            });
          } else {
            setState(() {
              noMoreData = true;
            });
          }
        }
        if (optionList.isEmpty) {
          setState(() {
            nextPage = true;
          });
          if (checkList.length == ansList.length) {
            int count = 0;
            for (int i = 0; i < checkList.length; i++) {
              if (checkList[i] == ansList[i]) {
                count++;
              }
            }
            if (count == ansList.length) {
              setState(() {
                correctQuestion++;
                checkQ = 1;
                nextPage = true;
              });
            } else {
              setState(() {
                checkQ = 2;
                nextPage = true;
              });
            }
          } else {
            //// move to next question as invalid question
            /// total blanks are not equals to ansList
            setState(() {
              checkQ = 2;
              nextPage = true;
            });
          }
        }
      },
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
                        if (nextPage == true) {
                          if (index < (list.length - 1)) {
                            setState(() {
                              nextPage = false;

                              noQuestion = false;
                              noMoreData = false;
                              firstCorrect = false;
                              checkQ = 0;
                              submit = false;
                              noMoreData = false;
                              noQuestion = false;

                              index++;
                              ratio = ratio + (1 / list.length);
                              if(ratio>1){
                                ratio=1.0;
                              }

                              question = list[index].question!;

                              optionList.clear();
                              ansList.clear();
                              trashAns.clear();
                              trashList.clear();
                              checkList.clear();
                              numberOfAnswer.clear();

                              optionList.addAll(list[index].quesOption!);
                              ansList.addAll(list[index].answer!);
                              trashAns.addAll(ansList);
                              numberOfAnswer.addAll(optionList);

                              print(ratio);
                            });
                          } else {
                            setState(() {
                              submit = true;
                              loader = true;
                            });
                            checkConnectivity();
                          }
                        }
                      },
                      child: index == (list.length - 1)
                          ? Text(
                              "Submit",
                              style: TextStyle(
                                  color: (nextPage == true)
                                      ? kLightBlack
                                      : bgBlack,
                                  fontSize: 16),
                            )
                          : Text(
                              "Next",
                              style: TextStyle(
                                  color: (nextPage == true)
                                      ? kLightBlack
                                      : bgBlack,
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
