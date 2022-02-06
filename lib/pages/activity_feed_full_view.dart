import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityFeedFullView extends StatelessWidget {
  final _firestore = Firestore.instance;
  final postsid;

  ActivityFeedFullView({this.postsid});
  showPost() {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore
          .collection('posts')
          .document(currentUser.id)
          .collection('userPosts')
          .document(postsid)
          .get(),
      builder: (context, sanpshot) {
        if (!sanpshot.hasData) {
          return CircularProgressIndicator();
        }
        Post post = Post.postFrom(sanpshot.data);
        return post;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(title: "Posts", isProfile: true, showBack: true),
      body: showPost(),
    );
  }
}
