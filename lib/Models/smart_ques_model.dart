class SmartQuestion {
  int? id;
  String? question;
  String? a;
  String? b;
  String? c;
  String? d;
  List<String>? answer;
  String? createdAt;
  String? updatedAt;

  SmartQuestion(
      {this.id,
        this.question,
        this.a,
        this.b,
        this.c,
        this.d,
        this.answer,
        this.createdAt,
        this.updatedAt});

  SmartQuestion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    a = json['a'];
    b = json['b'];
    c = json['c'];
    d = json['d'];
    answer = json['answer'].cast<String>();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['a'] = this.a;
    data['b'] = this.b;
    data['c'] = this.c;
    data['d'] = this.d;
    data['answer'] = this.answer;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}