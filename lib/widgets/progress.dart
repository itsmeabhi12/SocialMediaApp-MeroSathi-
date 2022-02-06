import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      valueColor:AlwaysStoppedAnimation(Colors.pinkAccent) ,
    ),
  );
}

Container linearProgress() {
  return Container(
    alignment: Alignment.topCenter,
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.pink),
    ),
  );
}
