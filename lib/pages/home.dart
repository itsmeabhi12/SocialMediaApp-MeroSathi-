import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'activity_feed.dart';
import 'timeline.dart';
import 'upload.dart';
import 'search.dart';
import 'profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_account.dart';
import 'package:fluttershare/models/user.dart';

User currentUser;
GoogleSignIn googlesignin = GoogleSignIn();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController _pagecontroller = PageController();
  final _firestore = Firestore.instance;
  bool isAuth = false;
  int selectedIndex = 0;

  void onChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void onTap(int index) {
    _pagecontroller.animateToPage(index,
        duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
  }

  Widget Authencated() {
    return Scaffold(
      body: PageView(
        controller: _pagecontroller,
        onPageChanged: onChanged,
        children: <Widget>[
          currentUser == null
              ? Container()
              : Timeline(currentuserid: currentUser?.id),
          ActivityFeed(),
          Upload(user: currentUser),
          Search(),
          Profile(passedUserid: currentUser?.id)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.whatshot,
              ),
              title: Text('Timeline')),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications_active,
              ),
              title: Text('Activity')),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera,
              ),
              title: Text('Upload')),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
              ),
              title: Text('Search')),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle,
              ),
              title: Text('Profile')),
        ],
        currentIndex: selectedIndex,
        onTap: onTap,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.purpleAccent,
      ),
    );
  }

  Widget unAuthencated() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Colors.purple,
              Colors.redAccent,
            ])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to MeroSathi ',
              style: TextStyle(fontFamily: "Signatra", fontSize: 40.0),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                googlesignin.signIn();
              },
              child: Container(
                height: 55,
                width: 249,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/google_signin_button.png'),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    googlesignin.onCurrentUserChanged.listen((event) {
      changeState(event);
    });
    SigninSilently();
    super.initState();
  }

  Future<GoogleSignIn> SigninSilently() async {
    var value = await googlesignin.signInSilently(suppressErrors: false);
    changeState(value);
  }

  void changeState(event) {
    if (event != null) {
      createUser();
      setState(() {
        isAuth = true;
      });
    }
    if (event == null) {
      setState(() {
        isAuth = false;
      });
    }
  }

  void createUser() async {
    var user = googlesignin.currentUser;
    DocumentSnapshot dss =
        await _firestore.collection('users').document(user.id).get();
    if (!dss.exists) {
      var Username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      _firestore.collection('users').document(user.id).setData({
        'id': user.id,
        'username': Username,
        'email': user.email,
        'photo': user.photoUrl,
        'displayname': user.displayName,
        'time': DateTime.now(),
        'bio': ""
      });
      _firestore.collection('followersandfollow').document(user.id).setData({
        'followers': {},
        'follow': {},
      });
    }
    dss = await _firestore.collection('users').document(user.id).get();
    setState(() {
      currentUser = User.fromDocument(dss);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? Authencated() : unAuthencated();
  }
}
