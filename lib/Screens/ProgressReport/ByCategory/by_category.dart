import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Utils/colors.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/category_result_model.dart';
import '../../../Utils/CheckConnection.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';
import '../../Authorization/login_screen.dart';

class ByCategory extends StatefulWidget {
  const ByCategory({Key? key}) : super(key: key);

  @override
  State<ByCategory> createState() => _ByCategoryState();
}

class _ByCategoryState extends State<ByCategory> {
  var totalScore;
  double totalPercentIndicator = 0.0;
  var topicName = "Accidental Reporting ";

  List<CategoryResultModel> list = <CategoryResultModel>[];

  bool loader = false;
  bool error = false;
  bool checkConnection = false;

  checkConnectivity() async {
    if (await connection()) {
      loadData();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  loadData() async {
    setState(() {
      loader = true;
      error = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    userToken = prefs.getString("userToken");

    print(userId);
    print(userToken);

    Map body = {"user_id": userId};

    try {
      http.Response response = await http.post(
          Uri.parse(getProgressByCategoryURL),
          headers: {"Authorization": "Bearer $userToken"},
          body: body);

      print(response.body.toString());

      Map jsonData = jsonDecode(response.body);
      print(jsonData);

      if (jsonData['status'] == 1) {
        print(jsonData['message']);
        setState(() {
          totalScore = jsonData['resultAvg'].toString();
          print(totalScore);
          totalPercentIndicator = double.parse(totalScore) / 100;
          print(totalScore);
          totalScore = double.parse(totalScore);

          for (int i = 0; i < jsonData['data'].length; i++) {
            Map<String, dynamic> obj = jsonData['data'][i];
            var pos = CategoryResultModel();
            pos = CategoryResultModel.fromJson(obj);
            list.add(pos);
          }
          print(list);
          loader = false;
          error = false;
        });
      } else {
        print(jsonData['message']);
        setState(() {
          loader = false;
          error = true;
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
              elevation: 0,
              centerTitle: true,
              title: const Text("Progress result by category"),
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
                : error
                    ? const Center(
                        child: Text(
                          "You have not attempted any test",
                          maxLines: 10,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                color: kLightGrey,
                                height:
                                    MediaQuery.of(context).size.height * 0.081,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03),
                                      child: Text(
                                          "Your average test score is ${totalScore != null ? totalScore.toStringAsFixed(1) : ""}%"),
                                    ),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03),
                                      width: MediaQuery.of(context).size.width,
                                      animation: true,
                                      curve: Curves.bounceInOut,
                                      barRadius: const Radius.circular(2),
                                      lineHeight: 6,
                                      percent: totalPercentIndicator,
                                      progressColor: kBlue,
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    return itemWidget(list[index]);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
          );
  }

  Widget itemWidget(CategoryResultModel model) {
    int a = int.parse(model.correctanswer!);
    int b = int.parse(model.totalquestions!);
    print("$a and $b");
    double percent = a / b;
    print(percent);

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01),
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            color: kIndigo,
            size: 14,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.questionbook == null &&
                          model.questionType == null &&
                          model.smartPractice == null &&
                          model.fillblank != null
                      ? "Fill in the Blank"
                      : model.questionbook == null && model.questionType == null
                          ? "${model.smartPractice}"
                          : model.questionType == null
                              ? "${model.questionbook?.name}"
                              : model.questionType == "1"
                                  ? "Multiple Choice with Text"
                                  : model.questionType == "2"
                                      ? "Multiple Choice with Image"
                                      : model.questionType == "3"
                                          ? "Drag and Drop Text"
                                          : model.questionType == "4"
                                              ? "Drag and Drop with Image"
                                              : "",
                  maxLines: 2,

                  //overflow: TextOverflow.ellipsis,
                ),
                LinearPercentIndicator(
                  animation: true,
                  curve: Curves.bounceInOut,
                  barRadius: const Radius.circular(2),
                  lineHeight: 6,
                  percent: percent,
                  progressColor: kIndigoLight,
                )
              ],
            ),
          ),
          Text("${model.correctanswer}/${model.totalquestions}"),
        ],
      ),
    );
  }
}
