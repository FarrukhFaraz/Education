import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Screens/Authorization/login_screen.dart';
import 'package:new_project/Utils/offline_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/topic_model.dart';
import '../../../Utils/CheckConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/url.dart';
import 'question_content.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<BookScreen> createState() => _BookScreenState(title);
}

class _BookScreenState extends State<BookScreen> {
  _BookScreenState(this.title);

  final String title;

  List<TopicModel> list = <TopicModel>[];
  int topicId = 0;

  bool loader = false;
  bool checkConnection = false;

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
      http.Response response = await http.get(Uri.parse(allTopicBookURL),
          headers: {"Authorization": "Bearer $userToken"});

      print(userToken);

      print(response.body.toString());

      Map jsonData = jsonDecode(response.body);
      print(jsonData.toString());
      if (jsonData['status'] == 1) {
        setState(() {
          loader = false;
        });
        for (int i = 0; i < jsonData['data'].length; i++) {
          Map<String, dynamic> obj = jsonData['data'][i];
          var pos = TopicModel();
          pos = TopicModel.fromJson(obj);
          list.add(pos);
        }
      } else {
        setState(() {
          loader = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error occured")));
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
              title: Text(title),
              leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                  )),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              child: loader
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, int index) {
                        return itemWidget(
                            index, list[index].name, list[index].id);
                      },
                    ),
            ),
          );
  }

  Widget itemWidget(int index, String? name, int? id) {
    return GestureDetector(
      onTap: () {
        setState(() {
          topicId = id!;
        });
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                QuestionContent(topicId: topicId, title: name!)));
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: BoxDecoration(
          color: (index % 2 == 0) ? bgBlack : bgWhite,
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
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
              height: 0,
            ),
            Expanded(
              child: Text(name!),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
