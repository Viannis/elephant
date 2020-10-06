import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gudalur/components/languageProvider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../main.dart';

class UserTowerScreen extends StatefulWidget {
  final DocumentSnapshot tower;
  UserTowerScreen(this.tower);

  @override
  _UserTowerScreenState createState() => _UserTowerScreenState();
}

class _UserTowerScreenState extends State<UserTowerScreen> {
  final dbRef = Firestore.instance;
  
  @override
  Widget build(BuildContext context) {
    final langChange = Provider.of<TamilLangProvider>(context);
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(254, 254, 254, 1),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color.fromRGBO(61, 90, 241, 1),
          title: FittedBox(
            child: Text(
              langChange.tamilLang ? widget.tower['tname'] : widget.tower['name'],
              style: TextStyle(
                  color: Color.fromRGBO(240, 240, 240, 1),
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w900,
                  fontSize: 22.0,
                  letterSpacing: .2),
            ),
          ),
        ),
        body: Container(
          child: getPlaces(langChange),
        ),
      ),
    );
  }

  Widget getPlaces(TamilLangProvider lang) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.tower.reference.collection("Location").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
         return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                          Image.asset(
                            'assets/logos/404.png',
                            width: MediaQuery.of(context).size.width * 0.9,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Oops!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Something went wrong. Please check your Internet connectivity',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,

                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          FlatButton(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                            ),
                            color: Color.fromRGBO(61, 90, 241, 1),
                            onPressed: (){
                              Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) => DriveScreen()));
                            }, 
                            child: Text(
                              'Go to home',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white
                              ),
                            )
                          )
                        ],
                      ),
                    )
                  );
        } else {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Container(
                child: Center(
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
                )
              );
            default:
              var places = snapshot.data.documents;
              return ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        elevation: 0,
                        color: Color.fromRGBO(240, 243, 246, 1),
                        margin: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(5.0),
                                    child: lang.tamilLang ? Text(
                                      places[index]['tname'],
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 18.0,
                                          color:
                                              Color.fromRGBO(73, 100, 252, 1)),
                                    ) : Text(
                                      places[index]['name'],
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 18.0,
                                          color:
                                              Color.fromRGBO(73, 100, 252, 1)),
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(5.0),
                                      child: lang.tamilLang ? Text(
                                         places[index]['count'] > 0 ? 'யானை நடமாட்டம் உள்ளது' : 'யானை நடமாட்டம் இல்லை',
                                            style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontStyle: FontStyle.normal,
                                            fontSize: 18.0,
                                            ),
                                      ) : Text(
                                         places[index]['count'] > 0 ? 'Presence of Elephants' : 'Absence of Elephants',
                                            style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontStyle: FontStyle.normal,
                                            fontSize: 18.0,
                                            ),
                                      ),
                                    
                                      ),
                                     
                                ],
                              )),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 5.0,left: 5, bottom: 5),
                                      child: Text(
                                        places[index]['timestamp'] != null ? ("Last updated " + timeago.format(DateTime.parse(places[index]['timestamp'].toDate().toString()),locale: 'en_short') + " ago") : ("Loading..."),
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.1
                                        ),
                                      )
                                    )
                                  ],
                                )
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
          }
        }
      },
    );
  }
}
