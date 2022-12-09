class AboutModel {
  int? id;
  String? content;
  String? createdAt;
  String? updatedAt;

  AboutModel({this.id, this.content, this.createdAt, this.updatedAt});

  AboutModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['content'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['content'] = content;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
