import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wiz/profile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: App(),
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

bool render = false;
final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class _AppState extends State<App> {
  Future<FirebaseUser> signIn() async {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn().catchError((onError){
      throw onError;
    });
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

  final FirebaseUser user = (await firebaseAuth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  Future<FirebaseUser> loginIn() async {
    if(await googleSignIn.isSignedIn()){
    }
    return firebaseAuth.currentUser();
  }

  Future<void> saveInst() async {
    await SharedPreferences.getInstance().then((inst) {
      inst.setBool('render', true);
    });
  }

  Future<void> getInst() async {
    await SharedPreferences.getInstance().then((inst) {
      setState(() {
        render = inst.getBool('render');
      });
      if (render == null) {
        render = false;
      }
      if (render == true) {
        loginIn().then((onValue){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> Profile(user: onValue)));
        });
      }
    });
  }

  @override
  void initState() {
    getInst();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    return Scaffold(
      body: Stack(alignment: Alignment.center, children: <Widget>[
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/theme_back.jpg'),
                  fit: BoxFit.cover)),
        ),
        SizedBox(
          width: _width * 0.9,
          height: _height * 0.8,
          child: Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 72, 87, 0.4),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Color.fromRGBO(0, 72, 87, 0.6), blurRadius: 5)
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(40))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  WelcomeTile(width: _width),
                  SizedBox(height: _height * 0.1),
                  render
                      ? Load()
                      : RawMaterialButton(
                          shape: StadiumBorder(),
                          fillColor: Colors.white,
                          splashColor: Color.fromRGBO(0, 72, 87, 0.2),
                          onPressed: () {
                            signIn().then((onValue) {
                              showDialog(
                                  context: context,
                                  child: AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    title: Text(
                                      "Login successfull..",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      onValue.email,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.grey[900],
                                    actions: <Widget>[
                                      RawMaterialButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                        shape: StadiumBorder(),
                                        fillColor: Colors.blue,
                                        child: Text("Done", style: TextStyle(color: Colors.white),),
                                      )
                                    ],
                                  ));
                              saveInst().then((onValue){});
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Profile(user: onValue)));
                            }).catchError((onError) {
                              showDialog(
                                  context: context,
                                  child: AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    title: Text(
                                      "Hey there,",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      "It seems like somthing is wrong on your side..\n - Check network connection.\n - Make sure that you're signed in on your device   \nwith a active google account.\n - Still having problem, contact us.",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.grey[900],
                                  ));
                            });
                          },
                          constraints: BoxConstraints(
                              minWidth: 150,
                              minHeight: 50,
                              maxWidth: 150,
                              maxHeight: 50),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage('assets/gicon.png'),
                                          fit: BoxFit.fill))),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text("Sign in",
                                    style: TextStyle(
                                        color: Colors.grey[700], fontSize: 16)),
                              )
                            ],
                          ),
                        )
                ],
              )),
        )
      ]),
    );
  }
}

class Load extends StatelessWidget {
  const Load({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.amber),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text("Getting in..",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
        )
      ],
    );
  }
}

class WelcomeTile extends StatelessWidget {
  const WelcomeTile({
    Key key,
    @required double width,
  })  : _width = width,
        super(key: key);

  final double _width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: _width * 0.3,
            height: _width * 0.3,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(_width * 0.15)),
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.white, blurRadius: 20, spreadRadius: 5)
                ],
                image: DecorationImage(
                    image: AssetImage('assets/icon.jpg'), fit: BoxFit.cover)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Text("WiZ",
                style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "This is a simple application\nfor Women Safty",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
