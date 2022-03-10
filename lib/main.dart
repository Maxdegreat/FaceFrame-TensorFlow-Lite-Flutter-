import 'package:camera/camera.dart';
import 'package:faceframe/homeView.dart/home_view.dart';

import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  runApp(myApp());
}
// strings as model strings



class myApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    );
  }
}
