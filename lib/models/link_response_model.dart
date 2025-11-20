// To parse this JSON data, do
//
//     final link = linkFromJson(jsonString);

import 'dart:convert';

class LinkElement {
  int id;
  String title;
  String link;
  String? username;
  int isActive;
  int userId;
  String createdAt;
  String updatedAt;

  LinkElement({
    required this.id,
    required this.title,
    required this.link,
    required this.username,
    required this.isActive,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LinkElement.fromJson(Map<String, dynamic> json) => LinkElement(
    id: json["id"],
    title: json["title"],
    link: json["link"],
    username: json["username"],
    isActive: json["isActive"],
    userId: json["user_id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "link": link,
    "username": username,
    "isActive": isActive,
    "user_id": userId,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
