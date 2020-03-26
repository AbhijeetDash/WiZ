import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiz/maps.dart'; 


class Profile extends StatefulWidget {
  FirebaseUser user;
  Profile({this.user});
  @override
  _ProfileState createState() => _ProfileState(user: user);
}

class _ProfileState extends State<Profile> {
  
  FirebaseUser user;
  String res = "Y";
  Geoflutterfire geo = Geoflutterfire();
  Firestore _firestore = Firestore();
  Alignment align = Alignment.centerRight;
  SharedPreferences sharedPreferences;
  bool choice = true;
  LatLng useCenter;
  Position position;
  FlutterBluetoothSerial fbs;
  IconData bticon = Icons.bluetooth_disabled;
  String btText = "Starting Bluetooth";

  _ProfileState({@required this.user});

  Future<Position> getLocation() async {
    position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    return position;
  }

  Future<void> burnUser() async {
    bool a = true;
    GeoFirePoint point =
        geo.point(latitude: position.latitude, longitude: position.longitude);
    _firestore.collection('User').getDocuments().then((onValue) {
      onValue.documents.forEach((f) {
        if (f.documentID == user.email) {
          a = false;
          _firestore.collection('User').document(user.email).updateData({
            "user_name": user.email,
            "position": point.data,
          });
        }
      });
      if (a) {
        _firestore.collection('User').document(user.email).setData({
          "user_name": user.email,
          "position": point.data,
        });
      }
    });
  }

  Future<bool> turnBtOn() async {
    return await fbs.isEnabled;  
  }

  @override
  void initState() {
    //Location Related things
    SharedPreferences.getInstance().then((onValue) {
      setState(() {
        if (onValue.getBool('choice') != null) {
          choice = onValue.getBool('choice');
        }
        sharedPreferences = onValue;
      });
      setState(() {
        if (choice) {
          align = Alignment.centerRight;
          res = "Y";
        } else {
          align = Alignment.centerLeft;
          res = "N";
        }
      });
    });
    getLocation().then((position) {
      setState(() {
        useCenter = LatLng(position.latitude, position.longitude);
      });
      burnUser().catchError((onError) {
        throw onError;
      });
    }).catchError((onError) {
      throw onError;
    });

    //bluetooth related things
    fbs = FlutterBluetoothSerial.instance;
    turnBtOn().then((isOn){
      if(!isOn){
        fbs.requestEnable().then((done){
          setState(() {
            bticon = Icons.bluetooth_searching;
            btText = "Searching Devices";
          });
          fbs.startDiscovery().listen((data){
            if(data.device.name == "HC-05"){
              fbs.bondDeviceAtAddress(data.device.address).then((onValue){
                if(onValue){
                  setState(() {
                    bticon = Icons.bluetooth_connected;
                    btText = "Connected";
                  });
                }
              });
            }
          });
        });
      }
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
        decoration: BoxDecoration(color: Color.fromRGBO(0, 72, 87, 0.4)),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            SizedBox(height: height * 0.05),
            Center(
              child: SizedBox(
                width: width * 0.2,
                height: width * 0.2,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.3),
                      image: DecorationImage(
                          image: NetworkImage(user.photoUrl),
                          fit: BoxFit.fill)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Text(
                  user.displayName.replaceAll("@gmail.com", ""),
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: "Lato"),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("A proud helper",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: "Lato")),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: width *0.8,
                height: height * 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 204, 204, 0.7),
                    borderRadius: BorderRadius.circular(30)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(bticon, size: 40),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(btText, style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontFamily: "Lato",
                          fontSize: 16
                        )),
                      )
                    ],                    
                  ),
                ),                
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: SizedBox(
                  width: width * 0.8,
                  height: height * 0.3,
                  child: Container(
                    padding: EdgeInsets.only(top: height * 0.02),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color.fromRGBO(0, 204, 204, 0.7)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Will you help?",
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                fontSize: 25,
                                color: Colors.white,
                                fontFamily: "Lato"),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 125,
                          height: 60,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.fastOutSlowIn,
                            alignment: align,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 102, 102, 1),
                                borderRadius: BorderRadius.circular(50)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                alignment: Alignment.center,
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 204, 204, 1),
                                    borderRadius: BorderRadius.circular(50)),
                                child: RawMaterialButton(
                                    child: Text(
                                      res,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 30),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (align == Alignment.centerLeft) {
                                          align = Alignment.centerRight;
                                          res = "Y";
                                          sharedPreferences
                                              .setBool("choice", true)
                                              .then((val) {
                                            print("done");
                                          });
                                        } else {
                                          align = Alignment.centerLeft;
                                          res = "N";
                                          sharedPreferences
                                              .setBool("choice", false)
                                              .then((val) {
                                            print("un-done");
                                          });
                                        }
                                      });
                                    }),
                              ),
                            ),
                          ),
                        ),
                        res == "N"
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 14.0, bottom: 10),
                                child: Container(
                                  child: Text(
                                    "Are you sure?\nHelping is a good thing.",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        decoration: TextDecoration.none,
                                        fontFamily: "Lato"),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    top: 14.0, bottom: 10),
                                child: Container(
                                  child: Text(
                                    "Thanks!\nfor your help.",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        decoration: TextDecoration.none,
                                        fontFamily: "Lato"),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
                child: SizedBox(
              width: width * 0.8,
              height: height * 0.3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                      image: AssetImage('assets/map.png'), fit: BoxFit.cover),
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.7),
                      borderRadius: BorderRadius.circular(30)),
                  child: RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Map(
                                center: useCenter,
                                user: user,
                              )));
                    },
                    splashColor: Color.fromRGBO(0, 0, 0, 0.7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      alignment: Alignment.bottomRight,
                      child: Hero(
                        key: Key("Maps"),
                        child: Icon(Icons.my_location,
                            size: 30, color: Colors.white),
                        tag: "Maps",
                      ),
                    ),
                  ),
                ),
              ),
            )),
            SizedBox(height: 100),
          ],
        ));
  }
}
