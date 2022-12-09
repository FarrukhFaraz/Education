import 'package:flutter/material.dart';
import 'package:new_project/Screens/SettingOut/EnglishSubtitle/english_subtitle.dart';
import 'package:new_project/Screens/SettingOut/SettingOutVideo/setting_out_video.dart';
import 'package:new_project/Screens/SettingOut/Transcript/transcript.dart';

import '../../Utils/colors.dart';

class SettingOut extends StatefulWidget {
  const SettingOut({Key? key}) : super(key: key);

  @override
  State<SettingOut> createState() => _SettingOutState();
}

class _SettingOutState extends State<SettingOut> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingOutVideo()));
          },
          child: settingOutWidget(
              "Watching the Setting out video", "assets/icons/settingOut.png"),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EnglishSubtitle()));
          },
          child: settingOutWidget(
              "Setting out(English subtitle)", "assets/icons/settingOut.png"),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Transcript()));
          },
          child: settingOutWidget(
              "Setting out - the transcript", "assets/icons/file.png"),
        ),
      ],
    );
  }

  Widget settingOutWidget(String title, String image) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.01,
        bottom: MediaQuery.of(context).size.height * 0.01,
        left: MediaQuery.of(context).size.width * 0.025,
        right: MediaQuery.of(context).size.width * 0.015,
      ),
      padding: const EdgeInsets.all(2),
      color: bgWhite,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1),
            // width: MediaQuery.of(context).size.width * 0.083,
            // height: MediaQuery.of(context).size.height * 0.04,
            child: Image.asset(
              image,
              //fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 0.07,
              height: MediaQuery.of(context).size.height * 0.03,
              color: kLightBlack,
            ),
          ),
           SizedBox(width: MediaQuery.of(context).size.width * 0.030,),
          Expanded(
              child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16 , color: kLightBlack),
          )),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}
