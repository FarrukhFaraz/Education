class CategoryResultModel {
  int? id;
  String? userId;
  String? questionbookId;
  String? questionType;
  String? smartPractice;
  String? fillblank;
  String? totalquestions;
  String? correctanswer;
  String? falseanswer;
  String? createdAt;
  String? updatedAt;
  Questionbook? questionbook;

  CategoryResultModel(
      {this.id,
      this.userId,
      this.questionbookId,
      this.questionType,
      this.smartPractice,
      this.fillblank,
      this.totalquestions,
      this.correctanswer,
      this.falseanswer,
      this.createdAt,
      this.updatedAt,
      this.questionbook});

  CategoryResultModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    questionbookId = json['questionbook_id'];
    questionType = json['question_type'];
    smartPractice = json['smart_practice'];
    fillblank = json['fillblank'];
    totalquestions = json['totalquestions'];
    correctanswer = json['correctanswer'];
    falseanswer = json['falseanswer'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    questionbook = json['questionbook'] != null
        ? new Questionbook.fromJson(json['questionbook'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['questionbook_id'] = this.questionbookId;
    data['question_type'] = this.questionType;
    data['smart_practice'] = this.smartPractice;
    data['fillblank'] = this.fillblank;
    data['totalquestions'] = this.totalquestions;
    data['correctanswer'] = this.correctanswer;
    data['falseanswer'] = this.falseanswer;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.questionbook != null) {
      data['questionbook'] = this.questionbook!.toJson();
    }
    return data;
  }
}

class Questionbook {
  int? id;
  String? name;

  Questionbook({this.id, this.name});

  Questionbook.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
