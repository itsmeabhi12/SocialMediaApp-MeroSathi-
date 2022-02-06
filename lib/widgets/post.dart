import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/profile.dart';

class Post extends StatefulWidget {
  final String ownerid;
  final String username;
  final String discription;
  final String imageurl;
  Map likes;
  final String imageid;
  final String location;

  Post({
    this.ownerid,
    this.username,
    this.discription,
    this.imageurl,
    this.likes,
    this.imageid,
    this.location,
  });

  factory Post.postFrom(DocumentSnapshot dss) {
    return Post(
      ownerid: dss['ownerid'],
      username: dss['username'],
      discription: dss['discription'],
      imageurl: dss['imageurl'],
      likes: dss['likes'],
      imageid: dss['imageid'],
      location: dss['location'],
    );
  }

  int likeCounts(Map likes) {
    int count = 0;
    likes.forEach((key, value) {
      if (value == true) {
        count++;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      ownerid: this.ownerid,
      username: this.username,
      discription: this.discription,
      imageurl: this.imageurl,
      imageid: this.imageid,
      location: this.location,
      totalLikes: likeCounts(likes));
}

class _PostState extends State<Post> {
  final _firestore = Firestore.instance;
  final String ownerid;
  final String username;
  final String discription;
  final String imageurl;
  final String imageid;
  final String location;
  int totalLikes;
  bool isLiked;

  _PostState(
      {this.ownerid,
      this.username,
      this.discription,
      this.imageurl,
      this.imageid,
      this.location,
      this.totalLikes});

  top() {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').document(ownerid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        var dss = snapshot.data;
        User user = User.fromDocument(dss);
        return ListTile(
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(
                            passedUserid: ownerid,
                          )));
            },
            child: CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(user.photo),
            ),
          ),
          title: Text(user.displayname),
          subtitle: Text(
            discription,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  middlepost() {
    return GestureDetector(
      onTap: () => handlelikes(),
      child: Stack(
        children: <Widget>[cachedNetworkImageLoading(imageurl)],
      ),
    );
  }

  handlelikes() {
    // if a  user id  is  not present in likes map  it will be  automaticlly  added  while  updateData
    setState(() {
      isLiked = widget.likes['${currentUser.id}'] == true;
    });
    print(isLiked);
    if (!isLiked) {
      _firestore
          .collection('posts')
          .document(ownerid)
          .collection('userPosts')
          .document(imageid)
          .updateData({'likes.${currentUser.id}': true});
      _firestore
          .collection('activityfeed')
          .document(ownerid)
          .collection('activities')
          .document(imageid)
          .setData({
        'type': 'like',
        'name': currentUser.displayname,
        'id': currentUser.id, // id of liker
        'img': currentUser.photo, // img of liker
        'imageurl': imageurl, // img that was liked
        'postid': imageid,
        'timestamp': DateTime.now()
      });

      setState(() {
        isLiked = true;
        totalLikes++;
        widget.likes['${currentUser.id}'] = true;
      });
    } else if (isLiked) {
      _firestore
          .collection('posts')
          .document(ownerid)
          .collection('userPosts')
          .document(imageid)
          .updateData({'likes.${currentUser.id}': false});

      _firestore
          .collection('activityfeed')
          .document(currentUser.id)
          .collection('activities')
          .document(imageid)
          .delete();

      setState(() {
        isLiked = false;
        totalLikes--;
        widget.likes['${currentUser.id}'] = false;
      });
    }
  }

  footer() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent,
                size: 35,
              ),
              onPressed: () => handlelikes(),
            ),
            Container(
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  '$totalLikes Likes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            IconButton(
              icon: Icon(
                Icons.insert_comment,
                color: Colors.blueAccent,
                size: 35,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Comments(
                              passeduserid: ownerid,
                              imageurl: imageurl,
                              currentuserId: currentUser.id,
                              currentusername: currentUser.username,
                              displyname: currentUser.displayname,
                              postId: imageid,
                              userimage: currentUser.photo,
                            )));
              },
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Icon(
                Icons.location_on,
                color: Colors.green,
              ),
            ),
            Text(
              location,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 3,
          color: Colors.purpleAccent,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = widget.likes['${currentUser.id}'] == true;
    return Column(
      children: <Widget>[
        top(),
        middlepost(),
        footer(),
      ],
    );
  }
}
