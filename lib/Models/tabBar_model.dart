import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_project/Utils/colors.dart';

class TabBarModel {
  late String name;
  late String icon;
  late Color color;
}

List<TabBarModel> getTabBarList() {
  List<TabBarModel> tabBarList = <TabBarModel>[];

  TabBarModel tab = TabBarModel();
  ///////////////////1
  tab.name = "Knowledge Question";
  tab.icon = "assets/icons/knowledgeBook.png";
  tab.color = bgWhite;
  tabBarList.add(tab);

  /////////////////////2
  tab = TabBarModel();
  tab.name = "Progress Report";
  tab.icon = "assets/icons/progressReport.png";
  tab.color = bgLightBlue;
  tabBarList.add(tab);

  /////////////////////3
  tab = TabBarModel();
  tab.name = "Useful Information";
  tab.icon = "assets/icons/userInformation.png";
  tab.color = bgLightBlue;
  tabBarList.add(tab);

  /////////////////////4
  tab = TabBarModel();
  tab.name = "User Detail";
  tab.icon = "assets/icons/person.png";
  tab.color = bgLightBlue;
  tabBarList.add(tab);

  ///////////////////5
  tab = TabBarModel();
  tab.name = "Setting Out";
  tab.icon = "assets/icons/settingOut.png";
  tab.color = bgLightBlue;
  tabBarList.add(tab);

  return tabBarList;
}

List getImageList() {
  List imageList = [
    "assets/images/knowledge.jpeg",
    "assets/images/progress.jpeg",
    "assets/images/useful.jpeg",
    "assets/images/user.jpeg",
    "assets/images/setting.jpeg",
  ];
  return imageList;
}
