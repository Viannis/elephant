import 'package:flutter/material.dart';
 
class RoundedButton extends StatelessWidget {
  RoundedButton({this.title, this.colour, @required this.onPressed});
 
  final Color colour;
  final String title;
  final Function onPressed;
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 4.0,
        color: colour,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 1
            ),
          ),
        ),
      ),
    );
  }
}