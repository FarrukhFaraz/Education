class FillBlankModel {
  int? id;
  String? question;
  List<String>? quesOption;
  List<String>? answer;
  String? createdAt;
  String? updatedAt;

  FillBlankModel(
      {this.id,
        this.question,
        this.quesOption,
        this.answer,
        this.createdAt,
        this.updatedAt});

  FillBlankModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    quesOption = json['quesOption'].cast<String>();
    answer = json['answer'].cast<String>();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    data['quesOption'] = quesOption;
    data['answer'] = answer;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}