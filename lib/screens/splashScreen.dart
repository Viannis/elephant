import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(24, 52, 63, 1),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Stack(
                       alignment: Alignment.center,
                       children:[
                         Container(
                           width: MediaQuery.of(context).size.width * 0.6,
                           height: MediaQuery.of(context).size.width * 0.6,
                           decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(150),
                           color: Color(0XFF07893E).withOpacity(.6),
                           ),
                         ),
                         Container(
                           width: MediaQuery.of(context).size.width * 0.4,
                           height: MediaQuery.of(context).size.width * 0.4,
                           decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(150),
                            color: Color(0XFF07893E).withOpacity(.6),
                           ),
                         ),
                         Container(
                           width: MediaQuery.of(context).size.width * 0.25,
                           height: MediaQuery.of(context).size.width * 0.25,
                           decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(150),
                           color: Color(0XFF07893E),
                           image: const DecorationImage(
                             image: AssetImage('assets/logos/playstoreicon.png'
                             ),
                           ),
                           )
                        ),
                       ],
                     ),
                     SizedBox(
                       height: 20,
                     ),
                     Text(
                        "Yaanai App",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          fontFamily: "Poppins",
                          letterSpacing: 0.5,
                          color: Color(0xFF00D858),
                        ),
                     ),
                    ],
                  ),
                )
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF07893E)
                        ),
                        ),
                      ),
                    SizedBox(width: 20),
                    Text(
                      "Loading...",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        letterSpacing: 1
                      ),
                    )
                  ],
                )
              )
            ],
          )
        ],
      )
    );
  }
}