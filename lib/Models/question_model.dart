import 'package:flutter/material.dart';

class QuestionModel {
  int? id;
  String? questionBooksId;
  String? questionType;
  String? question;
  String? a;
  String? b;
  String? c;
  String? d;
  String? e;
  List<String>? answer;
  String? createdAt;
  String? updatedAt;
  Color? color;
  IconData? icon;

  QuestionModel(
      {this.id,
      this.questionBooksId,
      this.questionType,
      this.question,
      this.a,
      this.b,
      this.c,
      this.d,
      this.e,
      this.answer,
      this.createdAt,
      this.updatedAt,
      this.color,
      this.icon});

  QuestionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    questionBooksId = json['questionbooks_id'];
    questionType = json['question_type'];
    question = json['question'];
    a = json['a'];
    b = json['b'];
    c = json['c'];
    d = json['d'];
    e = json['e'];
    answer = json['answer'].cast<String>();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['questionbooks_id'] = questionBooksId;
    data['question_type'] = this.questionType;
    data['question'] = question;
    data['a'] = a;
    data['b'] = b;
    data['c'] = c;
    data['d'] = d;
    data['e'] = e;
    data['answer'] = answer;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
