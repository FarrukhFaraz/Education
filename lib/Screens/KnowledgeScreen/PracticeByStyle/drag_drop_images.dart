import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/Question4Model_draggable.dart';
import '../../../Models/question_model.dart';
import '../../../Utils/CheckConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/home_page.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';
import '../../Authorization/login_screen.dart';

class DragDropImages extends StatefulWidget {
  const DragDropImages({
    Key? key,
    required this.title,
    required this.styleType,
    required this.list,
  }) : super(key: key);

  final String title;
  final int styleType;
  final List<QuestionModel> list;

  @override
  State<DragDropImages> createState() => _DragDropImagesState();
}

class _DragDropImagesState extends State<DragDropImages> {
  _DragDropImagesState();

  int index = 0;
  int correctAnswer = 0;
  late String url;
  double ratio = 0.0;

  bool loader = false;
  bool checkConnection = false;

  bool rebuild = false;
  bool nextPage = false;
  bool firstAnswer = false;
  bool secondAnswer = false;

  List<Answers> optionList = <Answers>[];

  List<Answers> firstDataList = <Answers>[];
  List<Answers> secondDataList = <Answers>[];

  List<Answers> trashList = <Answers>[];

  List<Answers> checkList = <Answers>[];
  List<Answers> checkAnswer = <Answers>[];

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
          Uri.parse(submitDragDropImageStyleURL),
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
    getAllAnswers();

    setState(() {
      ratio = 1 / widget.list.length;
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
                                child: Text((widget.list[index].question)!),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.029),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.13,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1),
                                        border: Border.all(
                                            color: kBlack, width: 2)),
                                    alignment: Alignment.center,
                                    child: dragTarget(firstDataList,
                                        "Drag 1st answer here", firstAnswer, 0),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: firstDataList.isNotEmpty
                                      ? Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                              border: Border.all(
                                                  color: kBlack, width: 2)),
                                          alignment: Alignment.center,
                                          child: dragTarget(
                                              secondDataList,
                                              "drag 2nd answer here",
                                              secondAnswer,
                                              0),
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.20,
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.02,
                            ),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: Colors.black54),
                              borderRadius: BorderRadius.circular(12),
                              color: kLightBLue,
                            ),
                            child: dragTarget(trashList,
                                "Drag all wrong answers here", false, 1),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          nextPage
                              ? const SizedBox()
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  child:
                                      rebuild ? const SizedBox() : draggable(),
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
                      FadeInImage(
                        placeholder:
                            const AssetImage("assets/images/placeholder.png"),
                        image: NetworkImage((dataList[0].answer)!),
                        height: MediaQuery.of(context).size.height * 0.12,
                        width: double.infinity,
                        //fit: BoxFit.cover,
                      ),
                      nextPage
                          ? Image.asset(
                              answer
                                  ? "assets/icons/check.png"
                                  : "assets/icons/no.png",
                              width: MediaQuery.of(context).size.width * 0.1,
                              color: answer ? kDarkGreen : kRed,
                            )
                          : const SizedBox()
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.only(bottom: 0),
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
              secondDataList.add(answer);
              checkAnswer.add(answer);
              optionList.remove(answer);
              /* trashList.addAll(optionList);
            optionList.clear();*/
              if (checkAnswer[1].answer == checkList[1].answer) {
                setState(() {
                  secondAnswer = true;
                });
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
              }
              if (optionList.isEmpty) {
                nextPage = true;
              }
              return;
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
              child: /*Image.network(answer.answer! , fit: BoxFit.cover,),*/
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
                InkWell(
                  onTap: () {
                    if (nextPage == true) {
                      if (index < (widget.list.length - 1)) {
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
