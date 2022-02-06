import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfile extends StatefulWidget {
  EditProfile({this.user});
  final User user;
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _firestore = Firestore.instance;
  bool nameValidted = true;
  bool bioValidated = true;
  TextEditingController name = TextEditingController();
  TextEditingController bio = TextEditingController();
@override
  void initState() {
  name.text=widget.user.displayname;
  print(widget.user.displayname);
  print(widget.user.bio);
  bio.text=widget.user.bio;
    super.initState();
  }

  validateForm() async{
  setState(() {
    name.text.trim().length<3?nameValidted=false:nameValidted=true;
    bio.text.trim().length>50||bio.text.trim().length==0?bioValidated=false:bioValidated=true;
  });
   if(bioValidated && nameValidted)
     {
       await _firestore.collection('users').document(widget.user.id).updateData({
         'displayname' : name.text,
         'bio' : bio.text
     });

         SnackBar snackBar = SnackBar(content: Text('Updated'),);
         _scaffoldKey.currentState.showSnackBar(snackBar);


     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: (){Navigator.pop(context,true);},
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage: CachedNetworkImageProvider(widget.user.photo),
              ),
                Container(
                  width: MediaQuery.of(context).size.width ,
                 child: Text('Display Name : ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.left,)),
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                      errorText: nameValidted?null:'Invalid Name Must be more than 3 digits'
                  ),
                ),
              SizedBox(
                height: 50,
              ),

              Container(alignment: Alignment.centerLeft,child: Text('Edit Bio :',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
              TextField(
              controller: bio,
                decoration: InputDecoration(
                  errorText: bioValidated?null:'Must between 0-50 characters'
                )
              ),
              RaisedButton(
                onPressed: (){
                  validateForm();
                },
                child: Text('Update'),
              )
            ],
          )
        ],
    ),
    );
  }
}
