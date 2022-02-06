import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String userName;

  void onPress(){
    var formstate =  _formKey.currentState;
    if(formstate.validate()){
      formstate.save();
      SnackBar snackBar = SnackBar(content: Text('Logging in '),);
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 3),(){
      Navigator.pop(context,userName);
      });
    }

  }
  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(title: 'Create Account ', isProfile: true, showBack: false),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Text('Enter Your Username',style: TextStyle(fontSize: 20),),
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    )
                  ),
                onSaved:(value){
                  userName = value;
                },
                autovalidate: true,
                validator: (value){
                    if(value.trim().length<3 ){
                      return 'Username cant less than 3';
                    }
                    else if(value.trim().length>10){
                      return 'Username should be less than 10';
                    }
                    else{
                      return null;
                    }
                },
              ),
            ),
          ),
          RaisedButton(
            color: Colors.green,
            onPressed: onPress,
            child: Text('Create',style: TextStyle(fontSize: 15),),
          )
        ],
      ),
    );
  }
}
