import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './userBeatScreen.dart';
import 'package:provider/provider.dart';
import '../components/languageProvider.dart';

class PeopleScreen extends StatefulWidget {
  @override
  PeopleScreenState createState() => PeopleScreenState();
}

class PeopleScreenState extends State<PeopleScreen> {
  final dbRef = Firestore.instance;
  bool loading = true;

  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  @override
  void initState() {
    getMarkers().then((value){
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  Future<void> getMarkers() async{
    dbRef.collection("Range").getDocuments().then((QuerySnapshot snapshot){
      snapshot.documents.forEach((element) { 
        element.reference.collection("Beat").getDocuments().then((QuerySnapshot value){
          value.documents.forEach((beat) => initMarker(beat));
        });
      });      
    });
  }



  void initMarker(DocumentSnapshot beat) {
    print("Entered InitMarkers");
    final MarkerId markerId = MarkerId(beat.documentID);
    final Marker marker = Marker(
        markerId: markerId,
        position:
            LatLng(beat.data['location'].latitude, beat.data['location'].longitude),
        infoWindow: InfoWindow(title: beat.data['name']),
        icon: beat.data['range'] == 1
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : beat.data['range'] == 2
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueViolet)
                : beat.data['range'] == 3
                    ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure)
                    : beat.data['range'] == 4
                        ? BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueOrange)
                        : BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueMagenta)
        );
    setState(() {
      markers[markerId] = marker;
    });
  }

  double zoomVal = 5.0;
  static const IconData translateicon = IconData(0xe800, fontFamily: 'Translate');

  @override
  Widget build(BuildContext context) {
    final langChange = Provider.of<TamilLangProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(61, 90, 241, 1),
        title: Text(
          "Maps",
          style: TextStyle(
              color: Color.fromRGBO(240, 240, 240, 1),
              fontFamily: 'Poppins',
              letterSpacing: 1,
              fontStyle: FontStyle.normal,
              fontSize: 25.0,
              fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              translateicon,
              size: 22,
            ), 
            onPressed: (){
              bool temp = langChange.tamilLang;
              langChange.tamilLang = !temp;
            }
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: (){
              showAboutDialog(
                context: context,
                applicationName: 'Yaanai',
                applicationIcon: Container(
                  padding: EdgeInsets.only(left: 0, bottom: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'assets/logos/playstoreicon.png',
                      width: 50
                    ),
                  ),
                ),
                applicationVersion: '1.0.0',
                children: [
                  Text(
                    '\t\t\t\t It contains all third party API Licences used in this app.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5
                    ),
                    textAlign: TextAlign.justify,
                  )
                ]
              );
            },
          )
        ],
      ),
      body: loading ? Container(
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
      ) : Stack(
        children: <Widget>[
          _buildGoogleMap(context),
          _buildContainer(langChange),
        ],
      ),
    );
  }

  Widget _buildContainer(TamilLangProvider lang) {
    return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          margin: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 40.0),
          height: 100.0,
          child: getList(lang),
        ));
  }

  Widget getList(TamilLangProvider lang) {
    return StreamBuilder<QuerySnapshot>(
      stream: dbRef.collection('Range').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.8)
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.red,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Oops! Error occured',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontSize: 20
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    ),
                    color: Color.fromRGBO(61, 90, 241, 1),
                    onPressed: (){
                      Navigator.pop(context);
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
              return Container(height: 0, width: 0);
            default:
              var docRef = snapshot.data.documents;
              return Center(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: docRef.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _boxes(docRef[index],lang);
                      }));
          }
        }
      },
    );
  }

  Widget _boxes(DocumentSnapshot range,TamilLangProvider lang) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) => UserBeatScreen(range)));
      },
      child: Container(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Color.fromRGBO(240, 240, 240, 1)
          ),
          margin: new EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          child: Row(children: <Widget>[
            Container(
              width: 70,
              height: 70,
              padding: EdgeInsets.all(3.0),
              child: Card(
                elevation: 16.0,
                child: ClipRRect(
                  borderRadius: new BorderRadius.circular(5.0),
                  child: Container(
                    child: Image(
                      fit: BoxFit.fill,
                      image: NetworkImage(range['image']),
                    ),
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(color: Colors.grey, blurRadius: 1.0),
                      BoxShadow(color: Colors.grey, blurRadius: 2.0),
                      BoxShadow(color: Colors.grey, blurRadius: 1.0),
                      BoxShadow(color: Colors.grey, blurRadius: 2.0),
                    ]),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 10.0,left: 2),
              child: lang.tamilLang ? Text(
                range['tname'],
                style: TextStyle(
                  color: Color.fromRGBO(61, 90, 241, 1),
                  fontFamily: 'Poppins',
                  fontSize: 18.0,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold)
                ) : Text(
                range['name'],
                style: TextStyle(
                  color: Color.fromRGBO(61, 90, 241, 1),
                  fontFamily: 'Poppins',
                  fontSize: 18.0,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold)
                ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition:
            CameraPosition(target: LatLng(11.5030, 76.4917), zoom: 12),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(markers.values),
      ),
    );
  }
}
