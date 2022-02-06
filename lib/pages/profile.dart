import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'home.dart';
import 'edit_profile.dart';
import 'package:fluttershare/widgets/custom_image.dart';

class Profile extends StatefulWidget {
  String passedUserid;
  Profile({this.passedUserid});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String viewOfPost = 'grid';
  bool isLoading = false;
  List<Post> posts = [];
  int totalpost = 0;
  bool isFollowed = false;
  int totalfollowers = 0;
  int totalfollow = 0;

  final _fireStore = Firestore.instance;
  Column countsHandle({String title, int num}) {
    return Column(
      children: <Widget>[
        Text(
          '${num}',
          style: TextStyle(fontSize: 18),
        ),
        Text(
          '$title',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        )
      ],
    );
  }

  getfollowunfollowdata() async {
    DocumentSnapshot dss = await _fireStore
        .collection('followersandfollow')
        .document(widget.passedUserid)
        .get();
    Map follow = dss['follow'];
    Map followers = dss['followers'];

    followers.forEach((key, value) {
      if (currentUser.id == key) {
        if (value == true) {
          isFollowed = true;
        }
      }
      if (value == true) {
        totalfollowers++;
      }
      setState(() {});
    });
    follow.forEach((key, value) {
      if (value) {
        totalfollow++;
      }
    });
    setState(() {});
  }

  followUnfollow() {
    if (isFollowed) {
      _fireStore
          .collection('followersandfollow')
          .document(widget.passedUserid)
          .updateData({'followers.${currentUser.id}': false});
      _fireStore
          .collection('followersandfollow')
          .document(currentUser.id)
          .updateData({'follow.${widget.passedUserid}': false});

      setState(() {
        isFollowed = false;
        totalfollowers--;
      });
    } else if (!isFollowed) {
      _fireStore
          .collection('followersandfollow')
          .document(widget.passedUserid)
          .updateData({'followers.${currentUser.id}': true});
      _fireStore
          .collection('followersandfollow')
          .document(currentUser.id)
          .updateData({'follow.${widget.passedUserid}': true});
      _fireStore
          .collection('activityfeed')
          .document(widget.passedUserid)
          .collection('activities')
          .document()
          .setData({
        'type': 'follow',
        'name': currentUser.displayname,
        'id': currentUser.id, // id of liker
        'img': currentUser.photo, // img of liker
        'imageurl': 'null', // img that was liked
        'postid': 'null',
        'timestamp': DateTime.now()
      });
      setState(() {
        isFollowed = true;
        totalfollowers++;
      });
    }
  }

  buildProfile() {
    bool isMe = (widget.passedUserid == currentUser.id);
    return FutureBuilder(
        future: _fireStore
            .collection('users')
            .document(isMe ? currentUser.id : widget.passedUserid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return linearProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.purple,
                      backgroundImage: CachedNetworkImageProvider(user.photo),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        countsHandle(title: 'Posts', num: totalpost),
                        countsHandle(title: 'Following', num: totalfollow),
                        countsHandle(title: 'Followers', num: totalfollowers),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            '${user.displayname}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${user.username}',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(user.bio),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Container(
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          color: Colors.purple,
                          onPressed: () async {
                            bool refresh = false;
                            isMe
                                ? refresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfile(user: currentUser)))
                                : followUnfollow();
                            if (refresh != null) {
                              if (refresh) {
                                setState(() {});
                              }
                            }
                          },
                          child: Text(
                            isMe ? 'Edit' : getText(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        });
  }

  String getText() {
    return isFollowed ? 'UnFollow' : 'Follow';
  }

  showProfilePost() {
    if (isLoading) {
      return circularProgress();
    }

    if (posts.isEmpty) {
      return Column(
        children: <Widget>[
          Icon(
            Icons.photo_library,
            size: 70,
            color: Colors.blueAccent,
          ),
          Text(
            'No Post Yet',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          )
        ],
      );
    }
    if (viewOfPost == 'grid') {
      List<Widget> gridlist = [];
      posts.forEach((element) {
        var img = cachedNetworkImageLoading(element.imageurl);
        gridlist.add(img);
      });
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        childAspectRatio: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        physics: NeverScrollableScrollPhysics(),
        children: gridlist,
      );
    }
    return Column(
      children: posts,
    );
  }

  fentchProfilePost() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot qss = await _fireStore
        .collection('posts')
        .document(widget.passedUserid)
        .collection('userPosts')
        .getDocuments();

    for (var dss in qss.documents) {
      Post post = Post.postFrom(dss);
      posts.add(post);
    }
    setState(() {
      totalpost = qss.documents.length;
      isLoading = false;
    });
  }

  @override
  void initState() {
    fentchProfilePost();
    getfollowunfollowdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
          title: 'Profile',
          isProfile: true,
          showSignout: true,
          context: context),
      body: ListView(
        children: <Widget>[
          buildProfile(),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    viewOfPost = 'grid';
                  });
                },
                icon: Icon(Icons.grid_on),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      viewOfPost = 'list';
                    });
                  },
                  icon: Icon(Icons.format_list_bulleted))
            ],
          ),
          SizedBox(
            height: 30,
          ),
          showProfilePost()
        ],
      ),
    );
  }
}
