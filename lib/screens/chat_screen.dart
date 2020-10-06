import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:gudalur/components/message_stream.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants2.dart';
import 'imageScreen.dart';
 
class ChatScreen extends StatefulWidget {
  final DocumentSnapshot chatUser;
  ChatScreen(this.chatUser);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Firestore _store = Firestore.instance;
  File image;
  String imageUrl;
  final picker = ImagePicker();
  String messageSend;
  final textcontroller = TextEditingController();
 
  Future getImage(ImageSource imageSource) async{
    final PickedFile pickedFile = await picker.getImage(source: imageSource);
    File finalImage;
    try {
      finalImage = File(pickedFile.path);
    } catch(e){
      return;
    }
    Navigator.push(context,CupertinoPageRoute(builder: (context) => ImageScreen(finalImage,widget.chatUser)));
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: null,
        title: Text(
          '⚡️Chat',
          style: TextStyle(
              color: Color.fromRGBO(240, 240, 240, 1),
              fontFamily: 'Poppins',
              letterSpacing: .5,
              fontStyle: FontStyle.normal,
              fontSize: 25.0,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color.fromRGBO(61, 90, 241, 1),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(widget.chatUser),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textcontroller,
                      onChanged: (value) {
                        messageSend = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () {
                        getImage(ImageSource.gallery);
                      }),
                  IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        getImage(ImageSource.camera);
                      }),
                  FlatButton(
                    onPressed: () {
                      if (messageSend != null) {
                        _store.collection('messages').add({
                              'sender': widget.chatUser.data['name'],
                              'text': messageSend,
                              'messageTime': DateTime.now(),
                              'isImage': false,
                            });
                            messageSend = null;
                      }
                      textcontroller.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
