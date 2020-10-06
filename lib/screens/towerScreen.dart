import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timeago/timeago.dart' as timeago;

class TowerScreen extends StatefulWidget {
  final DocumentSnapshot tower;
  TowerScreen(this.tower);

  @override
  _TowerScreenState createState() => _TowerScreenState();
}

class _TowerScreenState extends State<TowerScreen> {
  final myController = TextEditingController(text:"0");
  final reasonController = TextEditingController(text:"No");
  final dbRef = Firestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    myController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(254, 254, 254, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(61, 90, 241, 1),
          elevation: 0,
          title: FittedBox(
            child: Text(
              widget.tower['name'],
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
          child: getPlaces(),
        ),
      ),
    );
  }

  Widget getPlaces() {
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
                          Text(
                              'Try again later',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white
                              ),
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
                            children: <Widget>[
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
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
                                    child: Text(
                                      places[index]['count'] != null ? places[index]['count'].toString() +"  "+"Elephants!!!" : "0 Elephants!!!",
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 18.0,
                                          ),
                                    ),
                                  )
                                ],
                              )),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 5.0,left: 5, bottom: 5),
                                      child: IconButton(
                                        iconSize: 25,
                                        alignment: Alignment.topRight,
                                        color: Color.fromRGBO(73, 100, 252, 1),
                                        icon: Icon(
                                          Icons.edit,
                                        ),
                                        onPressed: (){
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Color.fromRGBO(240, 243, 246, 1),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
                                              titlePadding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0)
                                              ),
                                              title: new TextFormField(
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  height: 1.3
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly
                                                ],
                                                autofocus: true,
                                                keyboardType: TextInputType.number,
                                                controller: myController,
                                                decoration: InputDecoration(
                                                  labelText: 'Update Count',
                                                  labelStyle: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: 'Poppins',
                                                    color: Color.fromRGBO(73, 100, 252, 1)
                                                  )
                                                ),
                                              ),
                                              content: TextFormField(
                                                controller: reasonController,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  height: 1.3
                                                ),
                                                decoration: InputDecoration(
                                                  labelText: 'Remarks',
                                                  labelStyle: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: 'Poppins',
                                                    color: Color.fromRGBO(73, 100, 252, 1)
                                                  )
                                                ),
                                              ),
                                              actions: <Widget>[
                                                new FlatButton(
                                                  onPressed: () {
                                                    myController.text = "0";
                                                    reasonController.text = "No";
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: new Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: Color.fromRGBO(
                                                            73, 100, 252, 1)),
                                                  ),
                                                ),
                                                new FlatButton(
                                                    onPressed: () async{
                                                      Navigator.of(context).pop();
                                                      if (myController.text != "" && reasonController.text != "") {
                                                        int finalCount;
                                                        try {
                                                          int tempCount = int.parse(myController.text);
                                                          finalCount = tempCount;
                                                        } on FormatException {
                                                          Fluttertoast.showToast(
                                                            msg: 'Enter a valid number',
                                                            toastLength: Toast.LENGTH_LONG,
                                                            timeInSecForIos: 2,
                                                            gravity: ToastGravity.BOTTOM
                                                          );
                                                          return;
                                                        }
                                                        try {
                                                          await places[index].reference.updateData({
                                                            'count' : finalCount,
                                                            'timestamp' : FieldValue.serverTimestamp()
                                                          }).then((summa) async{
                                                            var userUID = await _firebaseAuth.currentUser().then((value) => value.uid);
                                                            await dbRef.collection("count").add({
                                                              'dateTime' : FieldValue.serverTimestamp(),
                                                              'locationRef' : places[index].reference,
                                                              'remarks' : reasonController.text,
                                                              'userReference' : dbRef.collection("Users").document(userUID),
                                                              'count' : finalCount
                                                            });
                                                          });
                                                        } on PlatformException {
                                                          Fluttertoast.showToast(msg: "You don't have sufficient permission",toastLength: Toast.LENGTH_LONG,gravity: ToastGravity.BOTTOM,timeInSecForIos: 2,);
                                                        }
                                                        
                                                      }
                                                      myController.text = "0";
                                                      reasonController.text = "No";
                                                    },
                                                    child: Text(
                                                      'Update',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: Color.fromRGBO(73, 100, 252, 1)
                                                      ),
                                                    )
                                                  )
                                                ],
                                              )
                                            );
                                        },
                                      ),
                                    ),
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
