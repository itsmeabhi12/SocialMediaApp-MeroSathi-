import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/models/user.dart';
import 'profile.dart';
import 'suggest.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController textEditingController = TextEditingController();
  Future<QuerySnapshot> user;
  final _firestore = Firestore.instance;
  searchHandler(String value) {
    setState(() {
      user = _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: value)
          .getDocuments();
    });
  }

  AppBar searchHeader() {
    return AppBar(
      title: TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () {
              textEditingController.clear();
            },
            icon: Icon(Icons.cancel),
          ),
          hintText: 'Search User ',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.purple),
              borderRadius: BorderRadius.all(Radius.circular(40))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.purple),
              borderRadius: BorderRadius.all(Radius.circular(40))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.purple),
              borderRadius: BorderRadius.all(Radius.circular(40))),
        ),
        onFieldSubmitted: searchHandler,
      ),
    );
  }

  Center deafultSearch(BuildContext context) {
    final oreientation = MediaQuery.of(context).orientation;
    return Center(
      child: Container(
        child: ListView(shrinkWrap: true, children: <Widget>[
          SvgPicture.asset(
            'assets/images/search.svg',
            width: oreientation == Orientation.portrait ? 300 : 200,
          ),
          Text(
            'Search People',
            style: TextStyle(
                fontSize: 40,
                color: Colors.purple,
                fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Suggest()));
            },
            child: Text(
              "See Suggestion",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          )
        ]),
      ),
    );
  }

  FutureBuilder<QuerySnapshot> resultSearch() {
    return FutureBuilder<QuerySnapshot>(
      future: user,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> founduserlist = [];
        for (var dss in snapshot.data.documents) {
          var founduser = User.fromDocument(dss);
          UserResult userResult = UserResult(
            founduser: founduser,
          );
          founduserlist.add(userResult);
        }
        return ListView(
          children: founduserlist,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: searchHeader(),
      body: user == null ? deafultSearch(context) : resultSearch(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User founduser;
  UserResult({this.founduser});
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
