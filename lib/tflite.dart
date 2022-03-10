import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image;


const String modelExp = "ModelExp";

class TfliteHome extends StatefulWidget {
  const TfliteHome({ Key? key }) : super(key: key);

  @override
  _TfliteHomeState createState() => _TfliteHomeState();
}

class _TfliteHomeState extends State<TfliteHome> {
  
    String _model = modelExp;
    File? _image;

    double? _imageHeight;
    double? _imageWidth;

    bool _busy = false;

    List _recoginitions = [];

    @override
    void initState() {
      super.initState();
      _busy = true;
      loadModel().then((value) {
        setState(() {
          _busy = false;
        });
      });
    }

     Future<void> loadModel() async {
      Tflite.close();
      try {
        String? res = null;
        if (_model == modelExp) {
          res = await Tflite.loadModel(
            model: "assets/model_expression.tflite",
            labels: "assets/model_expression.txt"
          );
        }
      } on PlatformException {
        print("Faild to load the model");
      }
    }
    

  @override
  Widget build(BuildContext context) {



     Future<void> modelexpression(File image) async {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,   // required
        imageMean: 0.0,   // defaults to 117.0
        imageStd: 255.0,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
);

      if (recognitions != null) {
        setState(() {
        _recoginitions = recognitions;
        print("_recoginitions is $_recoginitions");
      });
      }
    }

    // ssdMobileNet(File image) async {
    //   var recognitions = await Tflite.detectObjectOnImage(
    //     path: image.path,
    //     numResultsPerClass: 1
    //   );

    //   if (recognitions != null) {
    //     setState(() {
    //     _recoginitions = recognitions;
    //   });
    //   }
    // }

    Future<void> prediction(File image) async {
      print(_model);
       if (_model == modelExp) {
         await modelexpression(image);
         FileImage(image).resolve(ImageConfiguration()).addListener((ImageStreamListener((ImageInfo info, bool _){
           setState(() {
             _imageWidth = info.image.width.toDouble();
             _imageHeight = info.image.height.toDouble();
           });
         })));

         setState(() {
           _image = image;
           _busy = false;
         });
       }
    }

    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      var image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        print("The image is == $image");
        return;
      }
      setState(() {
        _image = File(image.path);
        print("set state on image, image = $_image");
      });
      await prediction(File(image.path));
    }

    
    List<Widget> renderBoxs(Size screen) {
      if (_recoginitions.isEmpty) {
        print ("the regoginitions is empty");
        return [];
      };
      if (_imageWidth == null || _imageHeight == null) {
        print("The print image faltered");
        return [];
      };

      double factorX = screen.width;
      double factorY = _imageHeight! / _imageHeight! * screen.width;

      Color blue = Colors.blue;
      
      return _recoginitions.map((re) {
        return Positioned(
          left: re["rect"]["x"] * factorX,
          top: re["rect"]["y"] * factorY,
          width: re["rect"]["w"] * factorX,
          height: re["rect"]["h"] * factorY,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: blue,
                width: 3,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"]*100).toStringAsFixed(0)}",
              style: TextStyle(
                color: Colors.white,
                background: Paint()..color=blue,
                fontSize: 15,
              ),

            ),
          ),
        );
      }).toList();

    }
   
    var size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];
    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null ? Text("No Image Selected") : Image.file(_image!)
    ));

    //stackChildren.addAll(renderBoxs(size));
    

    if (_busy){
      stackChildren.add(Center(child: CircularProgressIndicator(),));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('TensorFlow Dart'),
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.image),
        onPressed: () => pickImage(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stack(
          //   children: stackChildren
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.blue,
                image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null
              ),
              child: _image == null ? Icon(Icons.upload) : null
            ),
          ),
          Text("This is a ${_recoginitions.map((sm) => sm.toString())}")
        ],
      ),
    );
  }
}