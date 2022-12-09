import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Models/topic_model.dart';
import 'package:new_project/Screens/Authorization/login_screen.dart';
import 'package:new_project/Screens/KnowledgeScreen/SearchQuestion/searched_topic.dart';
import 'package:new_project/Utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utils/CheckConnection.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';

class SearchTopicList extends StatefulWidget {
  const SearchTopicList({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SearchTopicList> createState() => _SearchTopicListState(title);
}

class _SearchTopicListState extends State<SearchTopicList> {
  _SearchTopicListState(this.title);

  final String title;

  final TextEditingController _searchController = TextEditingController();

  String searchedText = "";
  bool loader = false;

  bool checkConnection = false;

  int topicId = 0;
  List<TopicModel> list = <TopicModel>[];
  List<TopicModel> searchedList = <TopicModel>[];

  getSearchedData(String value) {
    setState(() {
      searchedList.clear();
      if (value.trim().isNotEmpty) {
        for (int i = 0; i < list.length; i++) {
          if (list[i]
              .name
              .toString()
              .toLowerCase()
              .contains(value.trim().toLowerCase())) {
            searchedList.add(list[i]);
            print(list[i].name);
          }
        }
      }
    });
  }

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
      http.Response response = await http.get(Uri.parse(allTopicSearchURL),
          headers: {"Authorization": "Bearer $userToken"});

      print(response.body.toString());

      Map jsonData = jsonDecode(response.body);
      print(jsonData.toString());

      if (jsonData['status'] == 1) {
        print(jsonData['msg']);

        for (int i = 0; i < jsonData['data'].length; i++) {
          Map<String, dynamic> obj = jsonData['data'][i];
          TopicModel pos = TopicModel();
          pos = TopicModel.fromJson(obj);
          list.add(pos);
        }
        setState(() {
          loader = false;
        });
      } else {
        setState(() {
          loader = false;
        });
        print(jsonData['msg']);
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
              centerTitle: true,
              elevation: 0,
              title: Text(title),
              leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                  )),
            ),
            body: loader
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          color: bgLightBlue,
                          height: MediaQuery.of(context).size.height * 0.09,
                          padding: EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.015),
                          child: TextField(
                            onChanged: (val) {
                              getSearchedData(val.trim());
                              setState(() {
                                searchedText = val.trim().toString();
                              });
                            },
                            controller: _searchController,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              fillColor: Colors.white,
                              hintText: "Type here",
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2.0),
                              ),
                            ),
                          ),
                        ),
                        searchedList.isEmpty && searchedText.isNotEmpty
                            ? Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("No topic available for "),
                                    Text(
                                      "' $searchedText '",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ))
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.79,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                child: ListView.builder(
                                    itemCount: searchedList.length,
                                    itemBuilder: (context, index) {
                                      return itemWidget(
                                          index,
                                          searchedList[index].name,
                                          searchedList[index].id);
                                    }),
                              )
                      ],
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
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  SearchedTopic(title: title, topicId: topicId)),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04),
        decoration: BoxDecoration(
          color: (index % 2 == 0) ? bgWhite : bgBlack,
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
