import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gudalur/screens/chat_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:gudalur/utilities/constants1.dart';
 
class WelcomeScreen extends StatefulWidget {
  final DocumentSnapshot chatUser;
  WelcomeScreen(this.chatUser);
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}
 
class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
 
  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(seconds: 1), vsync: this);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white).animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }
 
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image.asset('assets/logos/imgchat.jpg'),
                      height: 60.0,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TypewriterAnimatedTextKit(
                      totalRepeatCount: 2,
                      text: ['Yaanai Chat...'],
                      textStyle: TextStyle(
                        fontSize: 30.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 48.0,
              ),
              RoundedButton(
                title: 'Start Chat',
                colour: Color.fromRGBO(61, 90, 241, 1),
                onPressed: () {
                  Navigator.pushReplacement(context, CupertinoPageRoute(
                             builder: (context) => ChatScreen(widget.chatUser),
                           ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}