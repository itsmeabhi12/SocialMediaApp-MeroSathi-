import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttershare/pages/home.dart';

AppBar header(
    {String title,
    bool isProfile,
    bool showBack = true,
    bool showSignout = false,
    BuildContext context}) {
  signoutButton() {
    return IconButton(
      icon: Icon(Icons.exit_to_app),
      onPressed: () async {
        await googlesignin.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      },
    );
  }

  return AppBar(
    automaticallyImplyLeading: showBack ? true : false,
    title: Text(
      '$title ',
      style: TextStyle(
          fontFamily: isProfile ? '' : 'Signatra',
          fontSize: isProfile ? 18 : 30),
    ),
    centerTitle: true,
    actions: <Widget>[showSignout ? signoutButton() : SizedBox()],
  );
}
