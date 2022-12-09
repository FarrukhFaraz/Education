import 'package:flutter/material.dart';
import 'package:new_project/Screens/ProgressReport/ByCategory/by_category.dart';
import 'package:new_project/Screens/ProgressReport/PreviousTestResult/previous_result.dart';
import 'package:new_project/Utils/colors.dart';

class ProgressReport extends StatefulWidget {
  const ProgressReport({Key? key}) : super(key: key);

  @override
  State<ProgressReport> createState() => _ProgressReportState();
}

class _ProgressReportState extends State<ProgressReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ByCategory()));
              },
              child:
                  progressWidget("By Category", "assets/icons/category.png")),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.009,
          ),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PreviousResult()));
              },
              child: progressWidget(
                  "Previous Test Result", "assets/icons/file.png")),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.009,
          ),
        ],
      ),
    ));
  }

  Widget progressWidget(String text, String image) {
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
              width: MediaQuery.of(context).size.width * 0.07,
              height: MediaQuery.of(context).size.height * 0.03,
              //fit: BoxFit.cover,
              color: kLightBlack,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.030,
          ),
          Expanded(
              child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: kLightBlack),
          )),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}
