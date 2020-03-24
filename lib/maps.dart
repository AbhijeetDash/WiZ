import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Map extends StatefulWidget {
  final LatLng center;
  final FirebaseUser user;
  Map({@required this.center, @required this.user});
  @override
  _MapState createState() => _MapState(center :center, user: user);
}

class _MapState extends State<Map> {
  
  final LatLng center;
  final FirebaseUser user;
  int counter = 0;
  GoogleMapController mapController;
  Set<Marker> _markers;
  var elements = [];
  BitmapDescriptor customIcon;
  Location location = Location();
  Firestore firestore = Firestore();
  Geoflutterfire geo = Geoflutterfire();
  bool builderMaps = false;

  _MapState({@required this.center, @required this.user});
  
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> createUsers(context) async {
    firestore.collection('User').getDocuments().then((onValue){
      onValue.documents.forEach((user){
        GeoPoint gp = user.data['position']['geopoint'];
        LatLng ugp = LatLng(gp.latitude,gp.longitude);
        Marker n = Marker(markerId: MarkerId(user.documentID), position: ugp, icon: customIcon, infoWindow: InfoWindow(
          title: user.documentID
        ));
        ImageConfiguration configuration = createLocalImageConfiguration(context, size: Size(1, 1));
        BitmapDescriptor.fromAssetImage(configuration, 'assets/user.png').then((icon){
          setState(() {
            customIcon = icon; 
            elements.add(n);
          });
        });
      });
    });
  }

  @override
  void initState() {
    _markers = Set.from(elements);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _markers = Set.from(elements);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    createUsers(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(0, 72, 87, 1),
        title: Text("Maps"),
      ),
      body: Container(
        width: width,
        height: height,
        child: Stack(
          children: <Widget>[
            GoogleMap(
              markers: _markers,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: center, zoom: 16),
              myLocationEnabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
