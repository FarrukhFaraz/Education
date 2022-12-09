import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Screens/KnowledgeScreen/Practice%20by%20Category/PracticeQuestion.dart';
import 'package:new_project/Utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/practice_model.dart';
import '../../../Models/question_model.dart';
import '../../../Utils/CheckConnection.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';
import '../../Authorization/login_screen.dart';

class PracticeByCategory extends StatefulWidget {
  const PracticeByCategory({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<PracticeByCategory> createState() => _PracticeByCategory(text);
}

class _PracticeByCategory extends State<PracticeByCategory> {
  _PracticeByCategory(this.text);

  bool checkConnection = false;
  bool show = false;
  bool loader = false;
  final String text;
  List<PracticeModel> list = <PracticeModel>[];
  List<QuestionModel> questionsList = <QuestionModel>[];
  int topicId = 0;

  String topicTitle = "";

  checkConnectivity() async {
    if (await connection()) {
      getCategoryList();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  fetchListData() async {
    list.clear();
    questionsList.clear();
    if (await connection()) {
      setState(() {
        checkConnection = false;
      });
      await getQuestionsList();
      await getCategoryList();
    } else {
      setState(() {
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
          Uri.parse(topicQuestionPracticeURL + topicId.toString()),
          headers: {"Authorization": "Bearer $userToken"});

      Map jsonData = jsonDecode(response.body);
      print(jsonData);

      if (jsonData['status'] == 200) {
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

  getCategoryList() async {
    setState(() {
      loader = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");

    try {
      http.Response response = await http.get(Uri.parse(categoryPracticeURL),
          headers: {"Authorization": "Bearer $userToken"});
      print(userToken);

      Map jsonData = jsonDecode(response.body);
      print(jsonData);
      if (jsonData['status'] == 1) {
        setState(() {
          loader = false;
        });
        for (int i = 0; i < jsonData['data'].length; i++) {
          Map<String, dynamic> obj = jsonData['data'][i];
          PracticeModel pos = PracticeModel();
          pos = PracticeModel.fromJson(obj);
          pos.icon = Icons.add;
          if (i % 2 == 0) {
            pos.color = bgWhite;
          } else {
            pos.color = bgBlack;
          }
          list.add(pos);
        }
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
    checkConnectivity();
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
              title: Text(text),
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
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width,
                    alignment:
                        show ? Alignment.centerRight : Alignment.centerLeft,
                    child: show
                        ? Text(
                            '${questionsList.length}  questions',
                            style: const TextStyle(
                                color: Color.fromRGBO(
                                    255, 255, 255, 0.8156862745098039)),
                          )
                        : const Text("Select your category"),
                  ),
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

        await fetchListData();

        setState(() {
          show = true;
          if (list.isNotEmpty) {
            list[index].color = kBlue;
            list[index].icon = Icons.check;
          }
          topicTitle = name!;
          print(topicTitle);
        });
        //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>NoiseQuestion1(title: title)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: MediaQuery.of(context).size.height * 0.085,
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
      height: MediaQuery.of(context).size.height * 0.085,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: kLightBlack, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(""),
          InkWell(
            onTap: () {
              if (questionsList.isNotEmpty) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PracticeQuestion(
                          title: topicTitle,
                          list: questionsList,
                          questionBookId: topicId,
                        )));
              }
            },
            child: Row(
              children: const [
                Text("Start test "),
                Icon(Icons.arrow_forward_ios, size: 18)
              ],
            ),
          )
        ],
      ),
    );
  }
}
