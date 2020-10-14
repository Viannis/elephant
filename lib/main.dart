import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gudalur/screens/googlemaps1.dart';
import 'package:gudalur/screens/authScreen.dart';
import './screens/googlemaps.dart';
import './screens/splashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './components/languageProvider.dart';

void main() {
  runApp(MyApp());
  // For having only portrait up mode so that app's widgets won't crash during auto rotate
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool token = false; // For checking user's auth status whether logged In or not
  bool loading = true;
  FirebaseAuth auth = FirebaseAuth.instance;
  TamilLangProvider tamilLangProvider = new TamilLangProvider();

  @override
  void initState(){
    Timer(Duration(seconds: 2), timeDelay);
    super.initState();
  }

  void timeDelay() {
    getCurrentLanguage().then((dummy){
      checkAuthStatus().then((value) {
        setState((){
          token = value;
          loading = false;
        });
      });
    });
  }

  Future<bool> checkAuthStatus() async{
    return await auth.currentUser() == null ? false : true;
  }

  Future<void> getCurrentLanguage() async{
    tamilLangProvider.tamilLang = await tamilLangProvider.languagePreference.getLang();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_){
        return tamilLangProvider;
      },
      child: Consumer<TamilLangProvider>(
        builder: (BuildContext context, value, Widget child){
          return MaterialApp(
            title: 'Yaanai',
            debugShowCheckedModeBanner: false,
            home: loading ? SplashScreen() : !token ? DriveScreen() : MapScreen()
          );
        },
      ),
    );
  }
}

class DriveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logos/imgman.png',
                    width:  MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                  ),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: new Text(
                      "Welcome",
                      style: new TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                      ),
                    ),
                  )
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 20.0),
                      child: GestureDetector(
                        child: new Container(
                            alignment: Alignment.center,
                            height: 60.0,
                            decoration: new BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFF282a57), Colors.lightBlueAccent]),
                                color: Color(0xFF18D191),
                                borderRadius: new BorderRadius.circular(9.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                new Text("Forest Officials",
                                    style: new TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1,
                                        fontSize: 20.0, color: Colors.white)),
                                        SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 20,
                                            color: Colors.white,
                                          )
                              ],
                            )),
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => LoginScreen(),
                              ));
                        },
                      ),
                    ),
                  )
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 25.0),
                      child: GestureDetector(
                          child: new Container(
                              alignment: Alignment.center,
                              height: 60.0,
                              decoration: new BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFF282a57), Colors.greenAccent]),
                                  color: Color(0xFF4364A1),
                                  borderRadius: new BorderRadius.circular(9.0)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  new Text("Area Peoples",
                                      style: new TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1,
                                          fontSize: 20.0, color: Colors.white)),
                                          SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                ],
                              )),
                          onTap: () {
                            Navigator.push(context, CupertinoPageRoute(
                                builder: (context) => PeopleScreen()));
                          }),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
