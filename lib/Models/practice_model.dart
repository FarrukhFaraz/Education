import 'package:flutter/material.dart';


class PracticeModel {
  int? id;
  String? name;
  String? createdAt;
  String? updatedAt;
  Color? color;

  IconData? icon ;

  PracticeModel({this.id, this.name, this.createdAt, this.updatedAt, this.color , this.icon});

  PracticeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
