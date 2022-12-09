import 'package:flutter/material.dart';
import 'package:new_project/Screens/Useful%20Information/about_test.dart';
import 'package:new_project/Screens/Useful%20Information/booking_test.dart';
import 'package:new_project/Screens/Useful%20Information/nearest_centre.dart';
import 'package:new_project/Screens/Useful%20Information/preparing_test.dart';
import 'package:new_project/Screens/Useful%20Information/taking_test.dart';

import '../../Utils/colors.dart';

class UsefulInformationWidget extends StatefulWidget {
  const UsefulInformationWidget({Key? key}) : super(key: key);

  @override
  State<UsefulInformationWidget> createState() =>
      _UsefulInformationWidgetState();
}

class _UsefulInformationWidgetState extends State<UsefulInformationWidget> {
  @override
  void initState() {
    // TODO: implement initState
//    getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            InkWell(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AboutTest()));
                },
                child: itemWidget("About the test", "assets/icons/file.png")),
            InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const PreparingTest(title: 'Preparing Test'),
                    ),
                  );
                },
                child: itemWidget(
                    "Preparing for a test", "assets/icons/file.png")),
            InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const BookingTest(title: "Booking Test"),
                    ),
                  );
                },
                child: itemWidget("Booking a test", "assets/icons/file.png")),
            InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const TakingTest(title: "Taking Test"),
                    ),
                  );
                },
                child: itemWidget("Taking a test", "assets/icons/file.png")),
            InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const NearestCentre(title: 'Nearest Center'),
                    ),
                  );
                },
                child:
                    itemWidget("Nearest test centre", "assets/icons/map.png")),
          ],
        ),
      ),
    );
  }

  Widget itemWidget(String title, String image) {
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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.030,
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16 , color: kLightBlack),
            ),
          ),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}
