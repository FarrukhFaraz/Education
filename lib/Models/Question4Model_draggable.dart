
import 'package:flutter/material.dart';
import 'package:new_project/Utils/colors.dart';

class Answers {
  String? answer;
  Color? color;
}

List<Answers> getAnswersList() {
  List<Answers> answerList = <Answers>[];

  Answers a = Answers();
  a.answer = "this is first answer";
  a.color=kLightRed;
  answerList.add(a);

  a = Answers();
  a.answer = "this is 2nd Answer";
  a.color=kLightRed;
  answerList.add(a);

  a = Answers();
  a.answer = "this is 3rd answer";
  a.color=kLightGreen;
  answerList.add(a);

  a = Answers();
  a.answer = "this is 4th answer";
  a.color=kLightGreen;
  answerList.add(a);

  a = Answers();
  a.answer = "this is 5th answer";
  a.color=kLightRed;
  answerList.add(a);

  return answerList;
}
