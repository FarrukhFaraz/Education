import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Models/Question4Model_draggable.dart';
import 'package:new_project/Utils/offline_ui.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/question_model.dart';
import '../../../Utils/CheckConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/home_page.dart';
import '../../../Utils/url.dart';
import '../../Authorization/login_screen.dart';

class DragDropText extends StatefulWidget {
  const DragDropText(
      {Key? key,
      required this.title,
      required this.list,
      required this.styleType})
      : super(key: key);

  final String title;
  final int styleType;
  final List<QuestionModel> list;

  @override
  State<DragDropText> createState() => _DragDropTextState();
}

class _DragDropTextState extends State<DragDropText> {
  int index = 0;
  int correctAnswer = 0;
  double ratio = 0.0;

  bool loader = false;
  bool checkConnection = false;

  bool rebuild = false;
  bool nextPage = false;
  bool firstAnswer = false;
  bool secondAnswer = false;

  double height =0.0;

  List<Answers> optionList = <Answers>[]; /////// for printing answer

  List<Answers> firstDataList = <Answers>[]; //////first fill in the blanks
  List<Answers> secondDataList = <Answers>[]; ////// 2ns fill in the blanks

  List<Answers> trashList = <Answers>[];

  List<Answers> checkList = <Answers>[];

  List<Answers> checkAnswer = <Answers>[];
  List<Answers> numberOfAnswers = <Answers>[];

  getAllAnswers() {
    setState(() {
      rebuild = true;
    });

    String z = widget.list[index].answer![0];
    String y = widget.list[index].answer![1];

    Answers a = Answers();
    a.answer = widget.list[index].a;
    optionList.add(a);

    a = Answers();
    a.answer = widget.list[index].b;
    optionList.add(a);

    a = Answers();
    a.answer = widget.list[index].c;
    optionList.add(a);

    a = Answers();
    a.answer = widget.list[index].d;
    optionList.add(a);

    a = Answers();
    a.answer = widget.list[index].e;
    optionList.add(a);

    if (z == "a") {
      print(optionList[0].answer);
      checkList.add(optionList[0]);
    } else if (z == "b") {
      print(optionList[1].answer);
      checkList.add(optionList[1]);
    } else if (z == "c") {
      print(optionList[2].answer);
      checkList.add(optionList[2]);
    } else if (z == "d") {
      print(optionList[3].answer);
      checkList.add(optionList[3]);
    } else if (z == "e") {
      print(optionList[4].answer);
      checkList.add(optionList[4]);
    }

    if (y == "a") {
      print(optionList[0].answer);
      checkList.add(optionList[0]);
    } else if (y == "b") {
      print(optionList[1].answer);
      checkList.add(optionList[1]);
    } else if (y == "c") {
      print(optionList[2].answer);
      checkList.add(optionList[2]);
    } else if (y == "d") {
      print(optionList[3].answer);
      checkList.add(optionList[3]);
    } else if (y == "e") {
      print(optionList[4].answer);
      checkList.add(optionList[4]);
    }

    print("${checkList[0].answer} \t ${checkList[1].answer}");

    setState(() {
      numberOfAnswers.addAll(optionList);
      rebuild = false;
    });
  }

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
    print("wrong Answer ${widget.list.length - correctAnswer}");
    print("total answer ${widget.list.length}");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    userToken = prefs.getString("userToken");

    print(userId);
    print(userToken);

    Map body = {
      "user_id": userId.toString(),
      "question_type": widget.styleType.toString(),
      "totalquestions": widget.list.length.toString(),
      "correctanswer": correctAnswer.toString(),
      "falseanswer": (widget.list.length - correctAnswer).toString()
    };

    try {
      http.Response response = await http.post(
          Uri.parse(submitDragDropTextStyleURL),
          headers: {"Authorization": "Bearer $userToken"},
          body: body);

      Map jsonData = jsonDecode(response.body);

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
    getAllAnswers();

    setState(() {
      ratio = 1 / widget.list.length;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int count =0;
    for(int i=0; i<numberOfAnswers.length; i++){
      if(numberOfAnswers[i].answer.toString().length>50){
        count++;
      }
    }
    if(count==0){
        height= MediaQuery.of(context).size.height*0.15;
      }else{
        height= MediaQuery.of(context).size.height*0.3;
      }

    return checkConnection
        ? OfflineUI(function: checkConnectivity)
        : Scaffold(
            appBar: AppBar(
              backgroundColor: kLight,
              elevation: 0,
              centerTitle: true,
              title: Text(widget.title),
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
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Column(
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(Icons.circle, size: 15)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  (widget.list[index].question)!,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.029),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            alignment: Alignment.center,
                            child: dragTarget(firstDataList,
                                "Drag your 1st answer here", firstAnswer, 0),
                          ),
                          firstDataList.isNotEmpty
                              ? Container(
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.019),
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  alignment: Alignment.center,
                                  child: dragTarget(
                                      secondDataList,
                                      "drag your 2nd answer here",
                                      secondAnswer,
                                      0),
                                )
                              : Container(),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.06),
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black54),
                                borderRadius: BorderRadius.circular(12),
                                color: kLightBLue),
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height * 0.18,
                            child: dragTarget(trashList,
                                "Drag all wrong answers here", false, 1),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.12,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: height,
                            child: rebuild ? const SizedBox() : draggable(),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
  }

  Widget dragTarget(List<Answers> dataList, String text, bool answer, int v) {
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
              border:
                  v == 0 ? Border.all(width: 1, color: Colors.black26) : null,
            ),
            child: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black26),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                  color: kLightBLue,
                  borderRadius: BorderRadius.circular(6),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        (dataList[index].answer)!,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    v == 0
                        ? nextPage
                            ? Image.asset(
                                answer
                                    ? "assets/icons/check.png"
                                    : "assets/icons/no.png",
                                width: MediaQuery.of(context).size.width * 0.08,
                                color: answer ? kDarkGreen : kRed,
                              )
                            : const SizedBox()
                        : const SizedBox(),
                  ],
                ),
              );
            },
          );
        }
      },
      onAccept: (dat) {
        setState(() {
          print("this is v  $v");
          Answers answer = dat as Answers;
          if (v == 0) {
            if (firstDataList.isEmpty) {
              checkAnswer.clear();
              firstDataList.add(answer);
              checkAnswer.add(answer);
              optionList.remove(answer);
              if (checkAnswer[0].answer == checkList[0].answer) {
                firstAnswer = true;
              }
              if (optionList.isEmpty) {
                nextPage = true;
              }
              return;
            }
            if (secondDataList.isEmpty) {
              checkAnswer.add(answer);
              secondDataList.add(answer);
              optionList.remove(answer);
              //trashList.addAll(answerList);
              //answerList.clear();

              if (checkAnswer[1].answer == checkList[1].answer) {
                secondAnswer = true;
                if (optionList.isEmpty) {
                  nextPage = true;
                }
                if (firstAnswer == true) {
                  print("true");
                  correctAnswer++;
                }
              } else {
                if (optionList.isEmpty) {
                  nextPage = true;
                }
                print("false");
                return;
              }
            }
          }
          if (v == 1) {
            trashList.add(answer);
            optionList.remove(answer);
          }
          if (optionList.isEmpty) {
            nextPage = true;
          }
        });
      },
    );
  }

  Widget draggable() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: optionList.map((answer) {
        return Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.019),
          child: Draggable(
            data: answer,
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
                answer.answer!,
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
              child: Text(answer.answer!),
            ),
            child: Container(
              alignment: Alignment.center,
              //height: 50,
              width: MediaQuery.of(context).size.width * 0.17,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kGrey, width: 2)),
              child: Text(
                answer.answer!,
                maxLines: 15,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        );
      }).toList(),
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
                    if (nextPage == true) {
                      if (index < (widget.list.length - 1)) {
                        setState(() {
                          nextPage = false;
                          firstAnswer = false;
                          secondAnswer = false;

                          numberOfAnswers.clear();
                          optionList.clear();
                          firstDataList.clear();
                          secondDataList.clear();
                          trashList.clear();
                          checkList.clear();
                          checkAnswer.clear();

                          index++;
                          ratio = ratio + (1 / widget.list.length);
                          if(ratio>1){
                            ratio=1.0;
                          }
                          print(ratio);
                          getAllAnswers();
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
                      Container(),
                      index == (widget.list.length - 1)
                          ? Text(
                              "Submit",
                              style: TextStyle(
                                  color: nextPage ? kLightBlack : bgBlack,
                                  fontSize: 16),
                            )
                          : Text(
                              "Next",
                              style: TextStyle(
                                  color: nextPage ? kLightBlack : bgBlack,
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
