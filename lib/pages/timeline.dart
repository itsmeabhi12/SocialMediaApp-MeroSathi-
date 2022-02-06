import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttershare/widgets/post.dart';

final _firestore = Firestore.instance;

class Timeline extends StatefulWidget {
  final String currentuserid;
  Timeline({this.currentuserid});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  bool isLoaded = false;
  List<Widget> totalposts = [];
  Future<List<String>> getFollow() async {
    var dss = await _firestore
        .collection('followersandfollow')
        .document(widget.currentuserid)
        .get();
    List<String> totalFollow = [];
    Map follow = dss['follow'];
    follow.forEach((key, value) {
      if (value == true) {
        totalFollow.add(key.toString());
      }
    });
    return totalFollow;
  }

  getTimeLinePosts() async {
    setState(() {
      isLoaded = false;
    });
    List totfollow = await getFollow();

    totfollow.forEach((element) async {
      QuerySnapshot qss = await _firestore
          .collection('posts')
          .document(element)
          .collection('userPosts')
          .getDocuments();
      for (var dss in qss.documents) {
        Post post = Post.postFrom(dss);
        setState(() {
          totalposts.add(post);
        });
      }
    });
    setState(() {
      isLoaded = true;
    });
  }

  getTimeLine() {
    print(totalposts);
    return Column(children: totalposts);
  }

  @override
  void initState() {
    getTimeLinePosts();
    super.initState();
  }

  Future<Null> refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(title: 'Mero Sathi', isProfile: false),
      body: RefreshIndicator(
        onRefresh: () {
          return refresh();
        },
        child: ListView(
          children: <Widget>[
            Container(
                child: Text(
              'Swipe Up To Refresh Page',
              textAlign: TextAlign.center,
            )),
            isLoaded ? getTimeLine() : circularProgress(),
          ],
        ),
      ),
    );
  }
}
