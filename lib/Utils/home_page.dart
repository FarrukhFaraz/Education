import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:new_project/Screens/KnowledgeScreen/knowledge_widget.dart';
import 'package:new_project/Screens/ProgressReport/progressReport.dart';
import 'package:new_project/Screens/SettingOut/setting_out.dart';
import 'package:new_project/Screens/Useful%20Information/useful_information_widget.dart';
import 'package:new_project/Screens/UserDetail/user_detail.dart';

import '../Models/tabBar_model.dart';
import 'CheckConnection.dart';
import 'colors.dart';
import 'offline_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String appBarTitle = "Knowledge Question";

  bool knowledgeQuestion = true;
  bool progressReport = false;
  bool usefulInformation = false;
  bool userDetail = false;
  bool settingOut = false;

  bool checkConnection = false;

  late String imageUrl;

  List imageList = [];

  List<TabBarModel>? tabList = <TabBarModel>[];

  DateTime? currentBackPressTime;

  checkConnectivity() async {
    if (await connection()) {
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    imageList = getImageList();
    imageUrl = imageList[0];
    tabList = getTabBarList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return checkConnection
        ? OfflineUI(function: checkConnectivity)
        : Scaffold(
          appBar: AppBar(
            title: Text(
              appBarTitle,
              style: TextStyle(color: kBlack),
            ),
            centerTitle: true,
            backgroundColor: kWhite,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12, top: 2),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.128,
                  color: Colors.grey,
                  child: ListView.builder(
                      dragStartBehavior: DragStartBehavior.start,
                      scrollDirection: Axis.horizontal,
                      itemCount: tabList!.length,
                      itemBuilder: (context, index) {
                        return tabBarWidget(index, tabList![index].name,
                            tabList![index].icon, tabList![index].color);
                      }),
                ),
                returnWidget(),
              ],
            ),
          ),
        );
  }

  Widget tabBarWidget(int index, String name, String icon, Color color) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            tabList = getTabBarList();
            tabList![index].color = bgWhite;

            if (index == 0) {
              knowledgeQuestion = true;
              progressReport = false;
              usefulInformation = false;
              userDetail = false;
              settingOut = false;
            } else if (index == 1) {
              knowledgeQuestion = false;
              progressReport = true;
              usefulInformation = false;
              userDetail = false;
              settingOut = false;
            } else if (index == 2) {
              knowledgeQuestion = false;
              progressReport = false;
              usefulInformation = true;
              userDetail = false;
              settingOut = false;
            } else if (index == 3) {
              checkConnectivity();
              knowledgeQuestion = false;
              progressReport = false;
              usefulInformation = false;
              userDetail = true;
              settingOut = false;
            } else if (index == 4) {
              knowledgeQuestion = false;
              progressReport = false;
              usefulInformation = false;
              userDetail = false;
              settingOut = true;
            }
            if (knowledgeQuestion == false) {
              tabList![0].color = bgLightBlue;
            }
            imageUrl = imageList[index];
            appBarTitle = name;
          });
        },
        child: Column(
          children: [
            Image(
              image: AssetImage(icon),
              height: MediaQuery.of(context).size.height * 0.04,
              color: color,
              width: MediaQuery.of(context).size.width * 0.08,
            ),
            Text(
              name,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget returnWidget() {
    if (knowledgeQuestion == true) {
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: const KnowledgeWidget());
    } else if (progressReport == true) {
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.39,
          child: const ProgressReport());
    } else if (userDetail == true) {
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: const UserDetail());
    } else if (usefulInformation == true) {
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.43,
          child: const UsefulInformationWidget());
    } else if (settingOut == true) {
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: const SettingOut());
    } else {
      return const SizedBox();
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
