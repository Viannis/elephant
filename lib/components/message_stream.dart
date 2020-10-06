import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messagebubble.dart';
 
final _controller = ScrollController();
final _store = Firestore.instance;
 
class MessageStream extends StatelessWidget {
  final DocumentSnapshot user;
  MessageStream(this.user);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _store.collection('messages').orderBy('messageTime', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Timer(
            Duration(seconds: 1),
            () => _controller.animateTo(
              _controller.position.maxScrollExtent,
              duration: Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
            ),
          );
          var messages = snapshot.data.documents;
          List<MessageBubble> textwidgets = messages.map((message) => MessageBubble(
            text: message['text'],
            sender: message['sender'],
            isMe: message['sender'] == user.data['name'],
            isImage: message['isImage'],
            time: DateFormat("dd MMM,yy - hh:mm:aa").format(DateTime.parse(message['messageTime'].toDate().toString())),
          )).toList();
          return Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              color: Colors.white,
              child: ListView(
                children: textwidgets,
                controller: _controller,
              ),
            ),
          );
        }
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator()
              ),
              SizedBox(width: 20),
              Text(
                'Loading ...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  fontSize: 20
                ),
              )
            ],
          )
        );
      },
    );
  }
}