import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
 
class ImageScreen extends StatefulWidget {
  final DocumentSnapshot user;
  ImageScreen(this.image,this.user);
  final File image;
  @override
  _ImageScreenState createState() => _ImageScreenState();
}
 
class _ImageScreenState extends State<ImageScreen> {
  FirebaseUser logginedinuser;
  final _store = Firestore.instance;
  bool isLoading = false;
  String imageUrl;
  var enabled = true; 

  @override
  Widget build(BuildContext context) {
    var onPress;
    if (enabled) {
      onPress = () async {
        setState(() {
          enabled = false;
          isLoading = true;
        });
        print("URL--------------------" + await uploadFile());
        uploadURL();
        Navigator.pop(context, imageUrl);
      };
    }
    return Scaffold(
      body: Center(
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Center(
            child: Image.file(
              widget.image,
              height: 600,
              width: double.infinity,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onPress,
        child: Icon(Icons.send),
        backgroundColor: Colors.lightBlueAccent,
      ),
    );
  }
 
  Future<String> uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('Chat Images').child(fileName);
    StorageUploadTask uploadTask = storageReference.putFile(widget.image);
    imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return imageUrl;
  }
 
  void uploadURL() {
       _store.collection('messages').add({
      'sender': widget.user.data['name'],
      'text': imageUrl,
      'messageTime': DateTime.now(),
      'isImage': true,
    });
    print("SUCCESS");
  }
}