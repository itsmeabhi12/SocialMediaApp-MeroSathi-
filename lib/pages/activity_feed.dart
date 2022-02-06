import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'activity_feed_full_view.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  final _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore
            .collection('activityfeed')
            .document(currentUser.id)
            .collection('activities')
            .orderBy('timestamp', descending: false)
            .getDocuments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<ActivityFeedItem> listsitem = [];
          for (var dss in snapshot.data.documents) {
            ActivityFeedItem activityFeedItem = ActivityFeedItem.dataFrom(dss);
            listsitem.add(activityFeedItem);
          }
          return ListView(
            children: listsitem,
          );
        },
      ),
    );
  }
}

class ActivityFeedItem extends StatelessWidget {
  final String type;
  final String dispname;
  final String id;
  final String img;
  final String postid;
  final Timestamp timestamp;
  final String imgurl;
  final String comments;
  ActivityFeedItem(
      {this.type,
      this.id,
      this.img,
      this.postid,
      this.timestamp,
      this.comments,
      this.dispname,
      this.imgurl});

  factory ActivityFeedItem.dataFrom(dss) {
    return ActivityFeedItem(
        type: dss['type'],
        id: dss['id'],
        img: dss['img'],
        postid: dss['postid'],
        timestamp: dss['timestamp'],
        imgurl: dss['imageurl'],
        dispname: dss['name'],
        comments: dss['comment']);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        type == 'follow'
            ? null
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ActivityFeedFullView(
                          postsid: postid,
                        )));
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(img),
          ),
          title: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '$dispname',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                ),
                TextSpan(
                  text: type == "like"
                      ? ' likes your post'
                      : type == 'follow'
                          ? 'Follows You'
                          : ' Commented on your post',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ],
            ),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
          trailing: Container(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(imgurl)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
