class KnowledgeModel {
  late String title;
  late String leadingIcon;
}

List<KnowledgeModel> getKnowledgeQuestionList() {
  List<KnowledgeModel> knowledgeQuestionList = <KnowledgeModel>[];

  KnowledgeModel m = KnowledgeModel();

  m.title = "Question Book";
  m.leadingIcon = "assets/icons/knowledgeBook.png";
  knowledgeQuestionList.add(m);

  m = KnowledgeModel();
  m.title = "Practice by Category";
  m.leadingIcon = "assets/icons/menu.png";
  knowledgeQuestionList.add(m);

  m = KnowledgeModel();
  m.title = "Practice by question style";
  m.leadingIcon = "assets/icons/tap.png";
  knowledgeQuestionList.add(m);

  m = KnowledgeModel();
  m.title = "Fill in the Blanks";
  m.leadingIcon = "assets/icons/file.png";
  knowledgeQuestionList.add(m);

  m = KnowledgeModel();
  m.title = "Smart practice";
  m.leadingIcon = "assets/icons/smartPractice.png";
  knowledgeQuestionList.add(m);

  m = KnowledgeModel();
  m.title = "Search a question";
  m.leadingIcon = "assets/icons/search.png";
  knowledgeQuestionList.add(m);

  return knowledgeQuestionList;
}
