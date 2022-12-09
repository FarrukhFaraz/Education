import 'package:flutter/material.dart';
import 'package:new_project/Models/practice_model.dart';

import '../../../Utils/colors.dart';

List<PracticeModel> getList() {
  List<PracticeModel> list = <PracticeModel>[];

  PracticeModel m = PracticeModel();
  m.id = 1;
  m.name = "Multiple choice with Text";
  m.icon = Icons.arrow_forward_ios;
  m.color = bgWhite;
  list.add(m);

  m = PracticeModel();
  m.id = 2;
  m.name = "Multiple choice with Images";
  m.icon = Icons.arrow_forward_ios;
  m.color = bgBlack;
  list.add(m);

  m = PracticeModel();
  m.id = 3;
  m.name = "Drag and Drop with Text";
  m.icon = Icons.arrow_forward_ios;

  m.color = bgWhite;
  list.add(m);

  m = PracticeModel();
  m.id = 4;
  m.name = "Drag and Drop with Images";
  m.icon = Icons.arrow_forward_ios;
  m.color = bgBlack;
  list.add(m);

  return list;
}
