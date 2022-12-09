import 'package:flutter/material.dart';
import 'package:new_project/Models/knowledge_model.dart';
import 'package:new_project/Screens/KnowledgeScreen/Practice%20by%20Category/practice_by_category.dart';
import 'package:new_project/Screens/KnowledgeScreen/SearchQuestion/search_topic_list.dart';
import 'package:new_project/Screens/KnowledgeScreen/SmartPractice/smart_practice.dart';
import 'package:new_project/Utils/colors.dart';

import 'Book Screen/book_screen.dart';
import 'FiilBlank/fill_in_the_blank.dart';
import 'PracticeByStyle/practice_by_style.dart';

class KnowledgeWidget extends StatefulWidget {
  const KnowledgeWidget({Key? key}) : super(key: key);

  @override
  State<KnowledgeWidget> createState() => _KnowledgeWidgetState();
}

class _KnowledgeWidgetState extends State<KnowledgeWidget> {
  List<KnowledgeModel> list = <KnowledgeModel>[];

  bool onTap = false;

  @override
  void initState() {
    // TODO: implement initState
    list = getKnowledgeQuestionList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return itemWidget(index, list[index].leadingIcon, list[index].title);
        },
      ),
    );
  }

  Widget itemWidget(int index, String leadingIcon, String title) {
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BookScreen(
                    title: title,
                  )));
        } else if (index == 1) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PracticeByCategory(text: title)));
        } else if (index == 2) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PracticeStyle(
                    title: title,
                  )));
        }
        else if(index==3){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const FillBlank()));
        }else if (index == 4) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SmartPractice(title: title)));
        } else if (index == 5) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchTopicList(title: title)));
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.01,
          bottom: MediaQuery.of(context).size.height * 0.01,
          left: MediaQuery.of(context).size.width * 0.025,
          right: MediaQuery.of(context).size.width * 0.015,
        ),
        padding: const EdgeInsets.all(2),
        color: onTap ? kLightBlack : bgWhite,
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(2),
              // width: MediaQuery.of(context).size.width * 0.083,
              // height: MediaQuery.of(context).size.height * 0.04,
              child: Image.asset(
                leadingIcon,
                width: MediaQuery.of(context).size.width * 0.07,
                height: MediaQuery.of(context).size.height * 0.03,
                //fit: BoxFit.cover,
                color: kLightBlack,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.03,
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, color: kLightBlack),
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
