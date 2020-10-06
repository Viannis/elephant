import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gudalur/screens/googlemaps.dart';
import 'package:gudalur/utilities/constants1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
 
class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
 
class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool isWrong = false;
  bool isNotVisible = true;
  final myController = TextEditingController();
  final myController1 = TextEditingController();

  @override 
  void dispose()
  {
    myController.dispose();
    myController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: MediaQuery.of(context).size.width,
                    child: Image.asset('assets/logos/imglog.png'),
                  ),
                ),
              ),
              TextField(
                controller: myController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                  border: new OutlineInputBorder(borderRadius: const BorderRadius.all(const Radius.circular(5.0),
                    ),
                     borderSide: new BorderSide(
                       color: Colors.blue,
                       width: 3.0,
                     ),
                    ),
                  prefixIcon: Icon(Icons.supervised_user_circle),
                  suffixIcon: Container(height: 0, width: 10)
                  ),
                  style: TextStyle(fontSize: 20.0),
                ),
              SizedBox(
                height: 20.0,
              ),
              TextField(
                controller: myController1,
                obscureText: isNotVisible,
                onChanged: (value) {
                  password = value;
                },
                decoration: isWrong?
                InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                  border:  OutlineInputBorder(borderRadius: const BorderRadius.all(const Radius.circular(5.0),
                  ),
                    borderSide: new BorderSide(
                      color: Colors.red,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
                  ),
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: GestureDetector(
                      child: Icon(isNotVisible? Icons.visibility:Icons.visibility_off),
                      onTap: (){
                        setState(() {
                          isNotVisible = !isNotVisible;
                        });
                      },
                    ),
                ):
                InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                    border: new OutlineInputBorder(borderRadius: const BorderRadius.all(const Radius.circular(5.0),
                    ),
                    borderSide: new BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    ),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: GestureDetector(
                      child: Icon(isNotVisible? Icons.visibility:Icons.visibility_off),
                      onTap: (){
                        setState(() {
                          isNotVisible = !isNotVisible;
                        });
                      },
                    ),
                    ),
                    style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Login',
                colour: Colors.black,
                onPressed: () async {
                  if((email == null)||(password == null)){
                    Fluttertoast.showToast(msg: "Enter an Email Id/Password",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 2,
                      backgroundColor: Colors.red,
                    );
                  }
                  else{
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    await _auth.signInWithEmailAndPassword(
                        email: email, password: password).then((ref) =>{
                          print("This is reference" + ref.user.uid.toString() + ref.user.email.toString()),
                          if (ref != null) {
                                myController.clear(),
                                myController1.clear(),
                                Navigator.pushReplacement(context, CupertinoPageRoute(
                                  builder: (context) => MapScreen(),
                              ))
                          }
                          else{
                        setState(() {
                            showSpinner = false;
                            }),
                          }
                        });
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    setState(() {
                      isWrong = true;
                      showSpinner = false;
                    });
                  Fluttertoast.showToast(msg: "Incorrect E-mail/Password",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIos: 2,
                    backgroundColor: Colors.red,
                  );
                  }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
