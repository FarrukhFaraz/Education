import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utils/colors.dart';
import '../../../Models/Question4Model_draggable.dart';
import '../../../Models/question_model.dart';
import '../../../Utils/CheckConnection.dart';
import '../../../Utils/home_page.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';
import '../../Authorization/login_screen.dart';

class SearchedTopic extends StatefulWidget {
  const SearchedTopic({Key? key, required this.title, required this.topicId})
      : super(key: key);

  final String title;
  final int topicId;

  @override
  State<SearchedTopic> createState() => _SearchedTopicState(topicId);
}

class _SearchedTopicState extends State<SearchedTopic> {
  _SearchedTopicState(this.questionBookId);

  final int questionBookId;

  double ratio = 0.0;
  int index = 0;
  int correctAnswer = 0;

  bool click = false;
  bool click1 = false;
  bool click2 = false;
  bool click3 = false;
  bool click4 = false;

  bool isAnswer = false;
  bool loader = false;
  bool submit = false;
  bool checkConnection = false;

  bool noQuestion = false;
  bool nextPage = false;
  bool rebuild = false;
  bool firstAnswer = false;
  bool secondAnswer = false;

  List<QuestionModel> list = <QuestionModel>[];

  List<Answers> optionList = <Answers>[];

  List<Answers> firstDataList = <Answers>[];
  List<Answers> secondDataList = <Answers>[];

  List<Answers> trashList = <Answers>[];

  List<Answers> checkList = <Answers>[];
  List<Answers> checkAnswer = <Answers>[];

  late List answerIs;
  double height = 0.0;

  getList() async {
    setState(() {
      loader = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");

    try {
      http.Response response = await http.get(
          Uri.parse(questionsSearchURL + questionBookId.toString()),
          headers: {"Authorization": "Bearer $userToken"});

      print(userToken);

      Map jsonData = jsonDecode(response.body);
      print(jsonData.toString());

      if (jsonData['status'] == 200) {
        setState(() {
          loader = false;
        });
        for (int i = 0; i < jsonData['data'].length; i++) {
          Map<String, dynamic> obj = jsonData['data'][i];
          QuestionModel pos = QuestionModel();
          pos = QuestionModel.fromJson(obj);
          list.add(pos);
        }
        if (list.isNotEmpty) {
          setState(() {
            answerIs = list[index].answer!;
            ratio = 1 / list.length;
            print(answerIs.toString());
            print(ratio.toString());
            print(list.length.toString());
          });
          if (list[index].questionType == "3" ||
              list[index].questionType == "4") {
            getAllAnswers();
          }
        }
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

  getAllAnswers() {
    setState(() {
      rebuild = true;
    });

    String z = list[index].answer![0];
    String y = list[index].answer![1];

    Answers a = Answers();
    a.answer = list[index].a;
    optionList.add(a);

    a = Answers();
    a.answer = list[index].b;
    optionList.add(a);

    a = Answers();
    a.answer = list[index].c;
    optionList.add(a);

    a = Answers();
    a.answer = list[index].d;
    optionList.add(a);

    a = Answers();
    a.answer = list[index].e;
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

    int count =0;
    for(int i=0; i<optionList.length; i++){
      if(optionList[i].answer.toString().length>50){
        count++;
      }
    }
    setState(() {
      rebuild = false;

      if(count==0){
        height= MediaQuery.of(context).size.height*0.15;
      }else{
        height= MediaQuery.of(context).size.height*0.3;
      }
    });
  }

  checkConnectivity() async {
    if (await connection()) {
      getList();
      setState(() {
        submit = false;
        checkConnection = false;
      });
    } else {
      setState(() {
        submit = false;
        checkConnection = true;
      });
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
      "questionbook_id": questionBookId.toString(),
      "totalquestions": list.length.toString(),
      "correctanswer": correctAnswer.toString(),
      "falseanswer": (list.length - correctAnswer).toString()
    };

    try {
      http.Response response = await http.post(Uri.parse(submitResultSearchURL),
          headers: {"Authorization": "Bearer $userToken"}, body: body);

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
    noQuestion = false;
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
                    child:
                        list.isEmpty ? const Text("") : Text("Q.${index + 1}")),
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
                          child: list.isEmpty
                              ? Text("")
                              : list[index].questionType == "1"
                                  ? multipleChoiceText()
                                  : list[index].questionType == "2"
                                      ? multipleChoiceImages()
                                      : list[index].questionType == "3"
                                          ? dragDropText()
                                          : list[index].questionType == "4"
                                              ? dragDropImages()
                                              : Container(),
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
      child: Text("There are no questions in this topic"),
    );
  }

  Widget multipleChoiceText() {
    return Column(
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

                  if (answerIs[0] == "a") {
                    print("correct");
                    correctAnswer = correctAnswer + 1;
                  } else {
                    print("wrong");
                  }
                }
              });
            },
            child: multipleText("a", list[index].a, click1)),
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

                  if (answerIs[0] == "b") {
                    print("correct");
                    correctAnswer = correctAnswer + 1;
                  } else {
                    print("wrong");
                  }
                }
              });
            },
            child: multipleText("b", list[index].b, click2)),
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

                  if (answerIs[0] == "c") {
                    print("correct");
                    correctAnswer = correctAnswer + 1;
                  } else {
                    print("wrong");
                  }
                }
              });
            },
            child: multipleText("c", list[index].c, click3)),
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

                  if (answerIs[0] == "d") {
                    print("correct");
                    correctAnswer = correctAnswer + 1;
                  } else {
                    print("wrong");
                  }
                }
              });
            },
            child: multipleText("d", list[index].d, click4)),
      ],
    );
  }

  Widget multipleText(String option, String? text, bool check) {
    String icon = "assets/icons/no.png";
    Color color = kLightRed;
    Color iconColor = Colors.red;

    if (click == true) {
      if (answerIs[0] == option) {
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

  Widget multipleChoiceImages() {
    return Column(
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

                if (answerIs[0] == "a") {
                  print("correct");
                  correctAnswer = correctAnswer + 1;
                } else {
                  print("wrong");
                }
              }
            });
          },
          child: multipleImage("a", list[index].a.toString(), click1),
        ),
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

                if (answerIs[0] == "b") {
                  print("correct");
                  correctAnswer = correctAnswer + 1;
                } else {
                  print("wrong");
                }
              }
            });
          },
          child: multipleImage("b", list[index].b.toString(), click2),
        ),
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

                if (answerIs[0] == "c") {
                  print("correct");
                  correctAnswer = correctAnswer + 1;
                } else {
                  print("wrong");
                }
              }
            });
          },
          child: multipleImage("c", list[index].c.toString(), click3),
        ),
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

                  if (answerIs[0] == "d") {
                    print("correct");
                    correctAnswer = correctAnswer + 1;
                  } else {
                    print("wrong");
                  }
                }
              });
            },
            child: multipleImage("d", list[index].d.toString(), click4)),
      ],
    );
  }

  Widget multipleImage(String option, String imageUrl, bool check) {
    String icon = "assets/icons/no.png";
    Color color = kLightRed;
    Color iconColor = Colors.red;

    if (click == true) {
      if (answerIs[0] == option) {
        setState(() {
          icon = "assets/icons/check.png";
          color = kLightGreen;
          iconColor = Colors.green;
        });
      }
    }
    return Container(
      // alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
          border: check
              ? Border.all()
              : Border.all(width: 1.5, color: click ? color : kLightBlack),
          color: check ? kLightBLue : bgWhite,
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            height: MediaQuery.of(context).size.height * 0.13,
            width: MediaQuery.of(context).size.width * 0.22,
            child: FadeInImage(
              placeholder: const AssetImage("assets/images/placeholder.png"),
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          click
              ? Image.asset(
                  icon,
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.08,
                  color: iconColor,
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget dragDropText() {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.circle, size: 15)),
            const SizedBox(width: 10),
            Expanded(
              child: Text((list[index].question)!),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.029),
        Container(
          height: MediaQuery.of(context).size.height * 0.05,
          alignment: Alignment.center,
          child: dragTargetText(
              firstDataList, "Drag 1st blank answer here", firstAnswer, 0),
        ),
        firstDataList.isNotEmpty
            ? Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.019),
                height: MediaQuery.of(context).size.height * 0.05,
                alignment: Alignment.center,
                child: dragTargetText(secondDataList,
                    "drag 2nd blank answer here", secondAnswer, 0),
              )
            : Container(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.06),
        Container(
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black54),
              borderRadius: BorderRadius.circular(12),
              color: kLightBLue),
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.18,
          child: dragTargetText(
              trashList, "Drag all wrong answers here", false, 1),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.12,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: height,
          child: rebuild ? const SizedBox() : draggableText(),
        ),
      ],
    );
  }

  Widget dragTargetText(
      List<Answers> dataList, String text, bool answer, int v) {
    return DragTarget(
      builder: (context, data, rejectedData) {
        if (dataList.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(6),
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
              //nextPage = true;
              checkAnswer.add(answer);
              secondDataList.add(answer);
              optionList.remove(answer);
              //trashList.addAll(optionList);
              // optionList.clear();
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

  Widget draggableText() {
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
              child: Text(answer.answer!,
              maxLines: 15,
                  overflow: TextOverflow.ellipsis,
              ),
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
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget dragDropImages() {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.circle, size: 15)),
            const SizedBox(width: 10),
            Expanded(
              child: Text((list[index].question)!),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.029),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.13,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      border: Border.all(color: kBlack, width: 2)),
                  alignment: Alignment.center,
                  child: dragTargetImage(
                      firstDataList, "Drag 1st answer here", firstAnswer, 0),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: firstDataList.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            border: Border.all(color: kBlack, width: 2)),
                        alignment: Alignment.center,
                        child: dragTargetImage(secondDataList,
                            "drag 2nd answer here", secondAnswer, 0),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.20,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01,
            horizontal: MediaQuery.of(context).size.width * 0.02,
          ),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black54),
            borderRadius: BorderRadius.circular(12),
            color: kLightBLue,
          ),
          child: dragTargetImage(
              trashList, "Drag all wrong answers here", false, 1),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        nextPage
            ? const SizedBox()
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
                child: rebuild ? const SizedBox() : draggableImages(),
              ),
      ],
    );
  }

  Widget dragTargetImage(
      List<Answers> dataList, String text, bool answer, int v) {
    return DragTarget(
      builder: (context, data, rejectedData) {
        if (dataList.isEmpty) {
          return Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black26),
          );
        } else {
          return v == 0
              ? Container(
                  // height: MediaQuery.of(context).size.height * 0.31,
                  padding: const EdgeInsets.all(5),
                  child: Stack(
                    children: [
                      SizedBox(
                        // height: MediaQuery.of(context).size.height * 0.2,
                        child: FadeInImage(
                          placeholder:
                              const AssetImage("assets/images/placeholder.png"),
                          image: NetworkImage((dataList[0].answer)!),
                          height: MediaQuery.of(context).size.height * 0.12,
                          width: double.infinity,
                          //fit: BoxFit.cover,
                        ),
                      ),
                      nextPage
                          ? Image.asset(
                              answer
                                  ? "assets/icons/check.png"
                                  : "assets/icons/no.png",
                              width: MediaQuery.of(context).size.width * 0.1,
                              color: answer ? kDarkGreen : kRed,
                            )
                          : const SizedBox(),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.only(bottom: 0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: v == 0 ? 1 : 3,
                    mainAxisSpacing: v == 0 ? 0 : 6,
                    crossAxisSpacing: v == 0 ? 0 : 4,
                  ),
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      // height: MediaQuery.of(context).size.height * 0.31,
                      padding: const EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          FadeInImage(
                            placeholder: const AssetImage(
                                "assets/images/placeholder.png"),
                            image: NetworkImage((dataList[index].answer)!),
                            height: MediaQuery.of(context).size.height * 0.12,
                            width: double.infinity,
                            //fit: BoxFit.cover,
                          ),
                          v == 0
                              ? nextPage
                                  ? Image.asset(
                                      answer
                                          ? "assets/icons/check.png"
                                          : "assets/icons/no.png",
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
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
              //nextPage = true;
              checkAnswer.add(answer);
              secondDataList.add(answer);
              optionList.remove(answer);
              //trashList.addAll(optionList);
              // optionList.clear();
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

  Widget draggableImages() {
    return GridView(
      physics: const NeverScrollableScrollPhysics(),
      //scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 1.8,
        crossAxisCount: 3,
        mainAxisSpacing: 4,
      ),
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
              //width: MediaQuery.of(context).size.width/2 ,
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: kLightBLue,
              ),
              child: FadeInImage(
                placeholder: const AssetImage("assets/images/placeholder.png"),
                image: NetworkImage(answer.answer!),
                fit: BoxFit.cover,
              ),
            ),
            childWhenDragging: Container(
              //height: 50,
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width * 0.17,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kYellow, width: 2)),
              child: FadeInImage(
                placeholder: const AssetImage("assets/images/placeholder.png"),
                image: NetworkImage(answer.answer!),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              //height: 50,
              //width: MediaQuery.of(context).size.width * 0.17,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kGrey, width: 2)),
              child: /*Image.network(
                answer.answer!,
                fit: BoxFit.cover,
              ),*/
                  FadeInImage(
                placeholder: const AssetImage("assets/images/placeholder.png"),
                image: NetworkImage(answer.answer!),
                fit: BoxFit.cover,
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
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (click == true || nextPage == true) {
                          setState(() {
                            click = false;
                            click1 = false;
                            click2 = false;
                            click3 = false;
                            click4 = false;
                          });
                          if (index < (list.length - 1)) {
                            setState(() {
                              nextPage = false;
                              firstAnswer = false;
                              secondAnswer = false;

                              optionList.clear();
                              firstDataList.clear();
                              secondDataList.clear();
                              trashList.clear();
                              checkList.clear();
                              checkAnswer.clear();

                              index++;
                              ratio = ratio + (1 / list.length);
                              if(ratio>1){
                                ratio=1.0;
                              }
                              print(ratio.toString());
                              answerIs = list[index].answer!;

                              if (list[index].questionType == "3" ||
                                  list[index].questionType == "4") {
                                getAllAnswers();
                              }
                            });
                          } else {
                            setState(() {
                              loader = true;
                            });
                            submitListData();
                          }
                        } else if (noQuestion == true) {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        }
                      },
                      child: (index == (list.length - 1))
                          ? Text(
                              "Submit",
                              style: TextStyle(
                                  color: (click == true || nextPage == true)
                                      ? kLightBlack
                                      : bgBlack,
                                  fontSize: 16),
                            )
                          : Text(
                              "Next",
                              style: TextStyle(
                                  color: (click == true ||
                                          nextPage == true ||
                                          list.isEmpty)
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
