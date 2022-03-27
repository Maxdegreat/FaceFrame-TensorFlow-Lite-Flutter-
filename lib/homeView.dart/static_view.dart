// static view allows for you to upload an image and we will test if
// that image has any detectable objects

// step1: load model and make init state

// step2: pick image and make predictions

// step3: predictions should call modelExpressions

import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
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
  String output = "null";
  // ignore: unused_field
  double _imageHeight = 0, _imageWidth = 0;
  String? thumbsup, thumbsdown;
  // audio player
  AudioPlayer? audioPlayer;
  late AudioCache audioCache;

  
  
  @override
  void initState() {
    // There are several things that need to be initalized. one of them being loadModel() and The second one being signToSound.init()
    super.initState();
    loadModel();
    // for The sound must init the player and cache, use fixed player for this case. you can look through the class to see what other properties that the player has
    setState(() {
        audioPlayer = AudioPlayer();
        audioCache = AudioCache(fixedPlayer: audioPlayer!);
      });
  }

  @override
  void dispose() {
    super.dispose();
    // should dispose the playerr
    audioPlayer!.dispose();
  }

   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // if the state pauses then we sould pause the song 
      
    }
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text("$message")));
  }

  void playSound(String soundPath) {
    // depending on what the output from our tflite model is we will pass a string as soundPath
    // if soundPath matches anything then we will play sound with matched path else we will just do nothing. trying to get a snackbar to show
    String? assetPath;
    if (soundPath == "thumbs_up")
      assetPath = 'thumbsupmp3.mp3';
    else if (soundPath == "thumbs_down")
      assetPath = 'thumbsdownmp3.mp3';
    else 
      assetPath = "null";
    log("assetPath: $assetPath");
    log("stingPath:$soundPath");
    audioPlayer!.stop(); // ---- this is in the case the user presses th btn twice, it is just an edgd case
    if (assetPath == "null")
      showInSnackBar("click \"Thumbs!\" first");
    else 
      audioCache.play(assetPath); // --------------------> just the file name we do not need to add the assets path too
  }

  // we do not need a puse sound, however most apps do. to do this just use audioPlayer.pause();



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
    print("==================$recoginitions===================");
    if (recoginitions != null) {
      setState(() {
        print("We are in the if condition");
        _regoginizitions = recoginitions;
        _regoginizitions.forEach((label) {
          setState(() { output = label["label"]; });
          output = output.substring(1);
          output = output.trim();
          log("output: $output");

          print("---------------------------------");
          print("|                                |");
          print("|    $output                    |");
          print("|                                |");
          print("---------------------------------");
        });
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
          thumbsBtn(),
          playSoundBtn(),
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
      child: Text(
      output, 
      style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.w900)),
    ) :
    Text("");
}

thumbsBtn() {
  return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.deepPurple[400]),
        onPressed: () async {
          await pickImage();
          print("have we finished the pick image ++++++++++++++++++");
        },
        child: Text("Thumbs!"),
      ),
    );
}

playSoundBtn() {
  return Container(
    child: ElevatedButton(
      child: Text('Text To Sound'),
      onPressed: ()=> playSound(output),
      style: ElevatedButton.styleFrom(primary: Colors.deepPurple[400]),
    ),
  );
}



}