class TranscriptModel {
  int? id;
  String? settcontent;
  String? createdAt;
  String? updatedAt;

  TranscriptModel({this.id, this.settcontent, this.createdAt, this.updatedAt});

  TranscriptModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    settcontent = json['settcontent'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['settcontent'] = this.settcontent;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
