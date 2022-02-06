import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'home.dart';

class Suggest extends StatelessWidget {
  final _firestore = Firestore.instance;
  suggestion1() async {
    List myfollow = [];
    var dss = await _firestore
        .collection("followersandfollow")
        .document(currentUser.id)
        .get();
    Map follow = dss['follow'];
    follow.forEach((key, value) async {
      if (value == true) {
        myfollow.add(key);
      }
    });
    return myfollow;
  }

  suggestion2() async {
    List myfollow = await suggestion1();
    List followfollow = [];
    List finalfollow = [];
    for (var element in myfollow) {
      var dss = await _firestore
          .collection("followersandfollow")
          .document(element)
          .get();
      Map follow = dss['follow'];
      follow.forEach((key, value) {
        if (value == true) {
          if (key != currentUser.id) {
            followfollow.add(key);
          }
        }
      });
    }
    List removeindex = [];
    for (var i = 0; i < followfollow.length; i++) {
      for (var j = 0; j < myfollow.length; j++) {
        if (followfollow[i] == myfollow[j]) {
          removeindex.add(i);
        }
      }
    }
    var reversedlist = List.from(removeindex.reversed);
    print(reversedlist);
    reversedlist.forEach((element) {
      followfollow.removeAt(element);
    });

    return followfollow;
  }

  Future<Widget> suggestion3() async {
    List followfollow = await suggestion2();
    List<Suggestlist> founduserlist = [];
    for (var element in followfollow) {
      var usrr = await _firestore.collection('users').document(element).get();
      User suggested = User.fromDocument(usrr);
      Suggestlist userResult = Suggestlist(
        founduser: suggested,
      );
      founduserlist.add(userResult);
    }
    return ListView(
      children: founduserlist,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: suggestion3(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return snapshot.data;
          }),
    );
  }
}

class Suggestlist extends StatelessWidget {
  final User founduser;
  Suggestlist({this.founduser});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Profile(
                        passedUserid: founduser.id,
                      )));
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.pinkAccent,
                    Colors.purpleAccent,
                    Colors.purple
                  ])),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(founduser.photo),
            ),
            title: Text(
              founduser.displayname,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(founduser.username),
          ),
        ),
      ),
    );
  }
}
