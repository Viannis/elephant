import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gudalur/components/languageProvider.dart';
import 'package:provider/provider.dart';
import 'userTowerScreen.dart';
import '../main.dart';

class UserBeatScreen extends StatefulWidget {
  final DocumentSnapshot docSnap;
  UserBeatScreen(this.docSnap);
  @override
  _UserBeatScreenState createState() => _UserBeatScreenState();
}

class _UserBeatScreenState extends State<UserBeatScreen> {
  @override
  Widget build(BuildContext context) {
    final langChange = Provider.of<TamilLangProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(61, 90, 241, 1),
        elevation: 0,
        title: FittedBox(
          child: Text(
            langChange.tamilLang ? widget.docSnap['tname'] : widget.docSnap['name'],
            style: TextStyle(
              color: Color.fromRGBO(240, 240, 240, 1),
              fontFamily: 'Poppins',
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w900,
              fontSize: 22.0,
              letterSpacing: 1
            ),
          ),
        )
      ),
      body: Container(
        child: FutureBuilder(
          future: widget.docSnap.reference.collection("Beat").getDocuments(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(snapshot.hasData){
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
                  break;
                default:
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index){
                      return GestureDetector(
                        onTap: (){
                          Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) => UserTowerScreen(snapshot.data.documents[index])));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                          elevation: 0,
                          color: Color.fromRGBO(240, 243, 246, 1),
                          margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(5.0),
                                      child: langChange.tamilLang ? Text(
                                        snapshot.data.documents[index]['tname'],
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 18.0,
                                          color: Color.fromRGBO(73, 100, 252, 1)
                                        ),
                                      ) : Text(
                                        snapshot.data.documents[index]['name'],
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 18.0,
                                          color: Color.fromRGBO(73, 100, 252, 1)
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Color.fromRGBO(73, 100, 252, 1),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                    }
                  );
              }
            }
            else if(snapshot.hasError){
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
            }
            else{
              return Container(
                height: 0,
                width: 0
              );
            }
          }
        )
      )
    );
  }
}