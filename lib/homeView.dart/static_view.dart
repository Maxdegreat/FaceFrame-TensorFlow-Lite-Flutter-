// static view allows for you to upload an image and we will test if
// that image has any detectable objects

// step1: load model and make init state

// step2: pick image and make predictions

// step3: predictions should call modelExpressions

import 'dart:io';

import 'package:faceframe/tflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class StaticView extends StatefulWidget {
  const StaticView({ Key? key }) : super(key: key);

  @override
  _StaticViewState createState() => _StaticViewState();
}

class _StaticViewState extends State<StaticView> {
  File? _image;
  List _regoginizitions = [];
  double _imageHeight = 0, _imageWidth = 0;
  String? thumbsup, thumbsdown;
  
  
  @override
  void initState() {
    super.initState();
    loadModel();
  }


  Future<void> loadModel() async {
    Tflite.close();
    try {
      await Tflite.loadModel(
        model: "assets/thumbs.tflite",
        labels: "assets/thumbs.txt",
      );
    }

    on PlatformException {
      print("failed to load model");
    }
  }

  Future<void> pickImage() async { 
    final ImagePicker pickedImg = ImagePicker();
    var image = await pickedImg.pickImage(source: ImageSource.camera);
    if (image == null)
      print("err in pickImage(): image: null");
    setState(() {
      _image = File(image!.path);
      print("_image is ...");
      print(_image);
    });
    if (_image != null)
      await predictions(_image!);
    else print("could not move from pickImage() -> predictions()");
  }

  Future<void> predictions(File image) async {
    await modelExpression(image);
    FileImage(image)
    .resolve(ImageConfiguration())
    .addListener((ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    })));
  }

  Future<void> modelExpression(File image) async {
    var recoginitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,  // defaults to 1.0
      numResults: 2,    // defaults to 5
      threshold: 0.2,   // defaults to 0.1
      asynch: true      // defaults to true
    );

    if (recoginitions != null) {
      setState(() {
        _regoginizitions = recoginitions;
        thumbsup = "HI";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ViewImg(context),
          imgTitle(),
          thumbsBtn()
        ],
      ),
    );
  }

 ViewImg(BuildContext ctx) {
  Size size = MediaQuery.of(ctx).size;
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Container(
        height: size.height / 2,
        width: double.infinity,
        child: _image != null? null : Icon(Icons.image_sharp, color: Colors.white, size: 50,),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17.0),
          color: Colors.black,
          image: _image != null ? 
            DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) :
            null
        ),
      ),
    );
}

imgTitle() {
  return _image != null ?
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Text("${_regoginizitions.map((e) => e["label"])}", 
      style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.w900)),
    ) :
    Text("");
}

thumbsBtn() {
  return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.deepPurple[400]),
        onPressed: () async => pickImage(), 
        child: Text("Thumbs!"),
      ),
    );
}
}