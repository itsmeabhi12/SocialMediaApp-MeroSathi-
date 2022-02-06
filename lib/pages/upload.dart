import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttershare/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Upload extends StatefulWidget {
  final User user;
  Upload({this.user});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController discription = TextEditingController();
  TextEditingController location = TextEditingController();
  final _fireStorage = FirebaseStorage.instance.ref();
  final _fireStore = Firestore.instance;
  String pid = Uuid().v4();
  bool isUploading = false;
  File file;
pickGallery() async{
  File galleryFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  setState(() {
    file = galleryFile;
  });
}
pickCamera() async{
  File cameraFile = await ImagePicker.pickImage(source: ImageSource.camera);
  setState(() {
    file = cameraFile;
  });
}



  Container defaultUploadScreen(context){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg',width: MediaQuery.of(context).size.width),
          Padding(
            padding: const EdgeInsets.all(20),
            child: RaisedButton(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Text('Upload Image'),
              color: Colors.deepPurple,
              onPressed: (){
                return showDialog(context: context,
                builder:(context){
                  return SimpleDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    children: <Widget>[
                      SimpleDialogOption(
                        child: Text('Camera'),
                        onPressed:(){
                          Navigator.pop(context);
                          pickCamera();
                        },
                      ),
                      SimpleDialogOption(
                        child: Text('Gallery'),
                        onPressed:(){
                          Navigator.pop(context);
                          pickGallery();
                        },
                      ),
                      SimpleDialogOption(
                        child: Text('Cancel'),
                        onPressed: ()=>Navigator.pop(context),
                      ),

                    ],
                  );
                }
                );
              }
            ),
          ),
        ],
      ),

    );
  }

  handlingUpload() async{

  setState(() {
    isUploading = true;  // when  this sis true  we  get loading widget on top of screen
  });
    var url =  await uploadingImage();  // we are  uploading  pic and  getting  link  of img after sucessful upload
    await addingInfo(url);  // now  its time to add  link of img  into  firestore  fatabase
    location.clear();                       // clearing textfield
    discription.clear();
    setState(() {               // after  sucessful insertion of data we  want to remove loading  bar
      isUploading =false;      // so  we  set isUploading to  false  check UploadImage()--> lIst view
      pid = Uuid().v4();
    });
  }

  Future<dynamic> uploadingImage()  async{
   StorageUploadTask storageUploadTask = _fireStorage.child(pid).putFile(file);
   StorageTaskSnapshot completed = await storageUploadTask.onComplete;
   var imageurl =  await completed.ref.getDownloadURL();
   return imageurl;
  }

  addingInfo(url){
  _fireStore.collection('posts').document('${widget.user.id}').collection('userPosts').document(pid).setData({
    'ownerid' : widget.user.id,
    'imageurl' : url,
    'discription' : discription.text,
    'location' : location.text,
    'likes': {},
    'username' : widget.user.username,
    'time' : DateTime.now(),
    'imageid': pid
  });

  }
  Future<dynamic> getCurrentLocation() async{
  try {
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    print('Why');
    List<Placemark> placeMark = await Geolocator().placemarkFromCoordinates(
        position.latitude, position.longitude);
    Placemark firstIndex = placeMark[0];
    String actuallocation = '${firstIndex.locality},${firstIndex.country}';
    location.text = actuallocation;
    print('OK');
  }
  catch(e){print(e);}

}
  uploadImage(){
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: (){
          setState(() {
            file =null;
          });
        },
      ),
      title: Text('Upload Picture'),
      actions: <Widget>[
        FlatButton(
          onPressed: ()async {
            await handlingUpload();
          } ,
          child: Text('Upload',style: TextStyle(fontSize: 17),),
        )
      ],
    ),
    body: ListView(
      children: <Widget>[
        isUploading? linearProgress() : SizedBox(),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                   decoration: BoxDecoration(
                     image: DecorationImage(
                       image: FileImage(file),
                       fit: BoxFit.cover
                     )
                   ),
                ))
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ListTile(
          leading: CircleAvatar(
            radius: 23,
            backgroundImage: CachedNetworkImageProvider(widget.user.photo),
          ),
          title: TextField(
            controller: discription,
            decoration: InputDecoration(
              hintText:  'Say Something About Post'
            ),
          ),
        ),
        SizedBox(height: 30,),
        ListTile(
          leading: Icon(Icons.location_on ,color: Colors.green,size: 50,),
          title: TextField(
            controller: location,
            decoration: InputDecoration(
              hintText: 'Location ....'
            ),
          ),
        ),
        SizedBox(height: 20,),
        Container(
          width: 200,
          alignment: Alignment.center,
          child: RaisedButton.icon(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            color: Colors.purple,
            icon: Icon(Icons.location_searching,color: Colors.blueAccent,),
            label: Text('Get Location'),
            onPressed: (){
              getCurrentLocation();
            },
          ),
        )
      ],
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return file == null?defaultUploadScreen(context): uploadImage();
  }
}
