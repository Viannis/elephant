import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
 
class ChatImageScreen extends StatelessWidget {
  final url;
  final String name;
  ChatImageScreen({this.url,this.name});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(61, 90, 241, 1),
        title: Text(
          name,
          style: TextStyle(
              color: Color.fromRGBO(240, 240, 240, 1),
              fontFamily: 'Poppins',
              letterSpacing: .8,
              fontStyle: FontStyle.normal,
              fontSize: 18.0,
              fontWeight: FontWeight.w600
            ),
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                 child: CachedNetworkImage(
                   imageUrl: url,
                   placeholder: (context, url) => CircularProgressIndicator(
                     valueColor: AlwaysStoppedAnimation<Color>(
                         Colors.blueAccent),
                   ),
                   errorWidget: (context, url, error) => Material(
                     borderRadius:
                     BorderRadius.all(Radius.circular(8.0)),
                     child: Image.asset('images/notavailable.png'),
                     clipBehavior: Clip.hardEdge,
                   ),
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}