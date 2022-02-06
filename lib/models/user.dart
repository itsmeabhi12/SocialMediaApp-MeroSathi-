import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttershare/pages/search.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String displayname;
  final String bio;
  final String photo;
  User({
    this.id,
    this.email,
    this.bio,
    this.displayname,
    this.username,
    this.photo
  });

  factory User.fromDocument(DocumentSnapshot dss){
    return User(
      id: dss['id'],
      email: dss['email'],
      bio: dss['bio'],
      displayname: dss['displayname'],
      username: dss['username'],
      photo: dss['photo']
    );
  }

}

