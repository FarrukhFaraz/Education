class ContentModel {
  int? id;
  String? questionBookId;
  String? content;
  String? createdAt;
  String? updatedAt;

  ContentModel(
      {this.id,
        this.questionBookId,
        this.content,
        this.createdAt,
        this.updatedAt});

  ContentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    questionBookId = json['questionbook_id'];
    content = json['content'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['questionbook_id'] = questionBookId;
    data['content'] = content;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}