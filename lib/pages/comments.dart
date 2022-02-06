import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String userimage;
  final String currentusername;
  final String postId;
  final String currentuserId;
  final String imageurl;
  final String displyname;
  final String passeduserid;
  Comments(
      {this.imageurl,
      this.currentuserId,
      this.userimage,
      this.currentusername,
      this.postId,
      this.displyname,
      this.passeduserid});
  @override
  CommentsState createState() => CommentsState();
}

class CommentsState extends State<Comments> {
  final _firestore = Firestore.instance;

  postComments() async {
    await _firestore
        .collection('comment')
        .document(widget.postId)
        .collection('comments')
        .document()
        .setData({
      'comment': comments.text,
      'commenter_usrname': widget.currentusername,
      'commenter_img': widget.userimage,
      'time': DateTime.now()
    });
    _firestore
        .collection('activityfeed')
        .document(widget.passeduserid)
        .collection('activities')
        .document()
        .setData({
      'type': 'comment',
      'name': widget.displyname,
      'comment': comments.text,
      'id': widget.currentuserId, // id of commenter
      'img': widget.userimage, //  image of commenter
      'imageurl': widget.imageurl, //this img was commented
      'postid': widget.postId,
      'timestamp': DateTime.now()
    });

    comments.clear();
  }

  viewComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('comment')
          .document(widget.postId)
          .collection('comments')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          );
        }
        List<Comment> comments = [];
        for (var dss in snapshot.data.documents) {
          Comment newcomment = Comment.fromDocument(dss);
          comments.add(newcomment);
        }
        return ListView(
          children: comments,
        );
      },
    );
  }

  TextEditingController comments = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(showBack: true, title: 'Comments', isProfile: true),
      body: Column(
        children: <Widget>[
          Expanded(
              child: Container(
            child: viewComments(),
          )),
          ListTile(
            title: TextField(
              controller: comments,
            ),
            trailing: OutlineButton(
              onPressed: () {
                postComments();
              },
              child: Text('Comment'),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String comment;
  final String usrname;
  final String img;
  final timestamp;
  Comment({this.comment, this.usrname, this.img, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot dss) {
    return Comment(
      comment: dss['comment'],
      img: dss['commenter_img'],
      usrname: dss['commenter_usrname'],
      timestamp: dss['time'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.red,
          backgroundImage: CachedNetworkImageProvider(img)),
      title: Text('$comment (by $usrname)'),
      subtitle: Text(timeago.format(timestamp.toDate())),
    );
  }
}
