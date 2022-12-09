import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Models/question_model.dart';
import 'package:new_project/Screens/KnowledgeScreen/PracticeByStyle/drag_drop_text.dart';
import 'package:new_project/Screens/KnowledgeScreen/PracticeByStyle/multiple_choice_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/practice_model.dart';
import '../../../Utils/CheckConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';
import '../../Authorization/login_screen.dart';
import 'drag_drop_images.dart';
import 'multiple_choice_images.dart';
import 'parctice_by_style_list.dart';

class PracticeStyle extends StatefulWidget {
  const PracticeStyle({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<PracticeStyle> createState() => _PracticeStyleState(title);
}

class _PracticeStyleState extends State<PracticeStyle> {
  _PracticeStyleState(this.title);

  final String title;

  bool checkConnection = false;
  bool show = false;
  bool loader = false;

  List<QuestionModel> questionsList = <QuestionModel>[];
  List<PracticeModel> list = <PracticeModel>[];

  int topicId = 0;
  String topicTitle = "";

  checkConnectivity() async {
    list.clear();
    questionsList.clear();

    if (await connection()) {
      await getQuestionsList();
      list = getList();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        show = false;
        checkConnection = true;
      });
    }
  }

  getQuestionsList() async {
    setState(() {
      loader = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");

    try {
      http.Response response = await http.get(
          Uri.parse(questionsByTopicStyleURL + topicId.toString()),
          headers: {"Authorization": "Bearer $userToken"});

      Map jsonData = jsonDecode(response.body);
      print(jsonData);

      if (jsonData['status'] == 1) {
        for (int i = 0; i < jsonData['data'].length; i++) {
          Map<String, dynamic> obj = jsonData['data'][i];
          QuestionModel pos = QuestionModel();
          pos = QuestionModel.fromJson(obj);
          questionsList.add(pos);
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
    list = getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return checkConnection
        ? OfflineUI(function: checkConnectivity)
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: kLight,
              elevation: 0,
              centerTitle: true,
              title: Text(title),
              leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                  )),
            ),
            bottomNavigationBar: show ? bottomNav() : null,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      color: kGrey,
                      alignment:
                          show ? Alignment.centerRight : Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      height: MediaQuery.of(context).size.height * 0.09,
                      width: MediaQuery.of(context).size.width,
                      child: show
                          ? Text(
                              '${questionsList.length}  questions',
                              style: const TextStyle(
                                  color: Color.fromRGBO(
                                      255, 255, 255, 0.8156862745098039)),
                            )
                          : Text(
                              "Select your question style",
                              style: TextStyle(color: kWhite),
                            )),
                  const SizedBox(height: 6),
                  /*itemWidget(1, "Multiple choice with Text"),
                  const SizedBox(height: 6),
                  itemWidget(2, "Multiple choice with Images"),
                  const SizedBox(height: 6),
                  itemWidget(3, "Drag and Drop with Text"),
                  const SizedBox(height: 6),
                  itemWidget(4, "Drag and Drop with Images"),*/

                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: show
                        ? MediaQuery.of(context).size.height * 0.69
                        : MediaQuery.of(context).size.height * .78,
                    child: loader
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, int index) {
                              return itemWidget(
                                  index,
                                  list[index].id,
                                  list[index].name,
                                  list[index].color,
                                  list[index].icon);
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget itemWidget(
      int index, int? id, String? name, Color? color, IconData? icon) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          show = false;
          topicId = id!;
        });

        await checkConnectivity();

        setState(() {
          show = true;
          if (list.isNotEmpty) {
            list[index].color = kBlue;
            list[index].icon = Icons.check;
          }
          topicTitle = name!;
          print(topicTitle);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 60,
        decoration: BoxDecoration(
          color: color,
          border: (index % 2 != 0)
              ? const Border.symmetric(
                  horizontal: BorderSide(
                  width: 1,
                  color: Colors.black38,
                ))
              : const Border.symmetric(horizontal: BorderSide.none),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.circle,
              size: 10,
            ),
            const SizedBox(
              width: 12,
              height: 0,
            ),
            Expanded(
              child: Text(name!),
            ),
            Icon(icon),
          ],
        ),
      ),
    );
  }

  Widget bottomNav() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: kLightBlack, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
              onTap: () {
                if (topicId == 1) {
                  ////////// Multiple choice with text
                  if (questionsList.isNotEmpty) {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MultipleChoiceText(
                              title: topicTitle,
                              topicStyle: topicId,
                              list: questionsList,
                            )));
                  }
                } else if (topicId == 2) {
                  /////////////// Multiple choice with images

                  if (questionsList.isNotEmpty) {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MultipleChoiceImages(
                              title: topicTitle,
                              topicStyle: topicId,
                              list: questionsList,
                            )));
                  }
                } else if (topicId == 3) {
                  /////////////// Drag and Drop with text

                  if (questionsList.isNotEmpty) {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DragDropText(
                              title: topicTitle,
                              list: questionsList,
                              styleType: topicId,
                            )));

                    /*Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DragDropText(
                              title: title,
                              list: questionsList,
                              questionBookId: topicId,
                            )));*/
                  }
                } else if (topicId == 4) {
                  /////////////// Drag and drop with images
                  Navigator.pop(context);
                  if (questionsList.isNotEmpty) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DragDropImages(
                              title: topicTitle,
                              styleType: topicId,
                              list: questionsList,
                            )));
                  }
                }
              },
              child: const Text("Start test")),
          const Icon(
            Icons.arrow_forward_ios,
            size: 20,
          )
        ],
      ),
    );
  }
}
