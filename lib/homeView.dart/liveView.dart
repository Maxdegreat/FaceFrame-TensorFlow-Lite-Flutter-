import 'package:camera/camera.dart';
import 'package:faceframe/signToSpeach/sign_to_speach_repository.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

// in main add widgetsFlutterBindingEnsureInit and await camera 
// import camera
// make the contorller
// use controller for image stream
// run model using the imagestream
// make predictions in "runModel()"

class LiveView extends StatefulWidget {
  @override
  State<LiveView> createState() => _LiveViewState();
}

class _LiveViewState extends State<LiveView> {
  // camera controller which is null at first
  CameraController? controller;
  // list of cameras, ya dig
  List<CameraDescription>? cameras;
  // cameraImage used to get frames in this use case
  CameraImage? cameraImage;
  // a empty list of what will be regoginitions
  List regoginitions = [];
  // string output will be used to tell if it is a thumbs up or down
  String output = "";
  // controller used for sign to sound
  SignToSound signToSound = SignToSound();
  // a functin that handels the initilization of the cameras
  loadCameras() async {
    print("in the loadCameras fnction");
    var cameras_ = await availableCameras();
    var controller_ = CameraController(cameras_[0], ResolutionPreset.medium); // -----------> quality
    controller_.initialize().then((_) {
      if (!mounted) {
        return - 1;
      } else {
        setState(() {
            controller_.startImageStream((imageStream) {
            cameraImage = imageStream;
            runModel();
          });
        });
      }
      //print("done and the camera is ${cameras} and the controller is ${controller}");
      setState(() {cameras = cameras_; controller = controller_;});
    return cameras;
    });
  }

  runModel() async {
    if (cameraImage != null) {
      var temp_recognitions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {return plane.bytes;}).toList(),// required
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,   // defaults to 127.5
        imageStd: 127.5,    // defaults to 127.5
        rotation: 90,       // defaults to 90, Android only
        numResults: 2,      // defaults to 5
        threshold: 0.1,     // defaults to 0.1
        asynch: true        // defaults to true
      );
      
      setState(() {
        regoginitions = temp_recognitions!;
      });

      regoginitions.forEach((element) {
        setState(() { output = element['label'];
        output = output.substring(2);
        

      });

    });
    } else {
      print("The camera image is NULL");
      return ;
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }



   @override
     initState()  {
     super.initState();
     loadCameras();
     //signToSound.init();
    
     setState(() {});
   }

   @override
  void dispose() {
    controller?.dispose();
    super.dispose();
    //signToSound.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (controller != null) {
      if (!controller!.value.isInitialized) {
        return contorllerNullAlert();
      }  
    }
    return Scaffold(
      body: Stack(
        
        children: [
          Container(
            color: Colors.green,
            height: size.height,
            width: size.width,
          child: CameraPreview(controller!),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            child: buildTextBackground(context),
          ),
          Positioned(
            bottom: 50,
            right: 50,
            child: ToSpeachBtn(),
          )
        ],
      ),
    );
  }

  Container ToSpeachBtn() {
    return Container(
      child: ElevatedButton(
        onPressed: () async { 
          var x;
          try {
            //x = await signToSound.playAudio(toPlay: output);            
          
          } catch (e) {
            ScaffoldMessenger(child: x);
          } 

        },
        child: Text("To Speach"),
      )
    );
  }

  Widget buildTextBackground(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
      ),
      child: Center(child: Text(output, style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),)),
      height: 50,
      width: size.width,
    );
  }
}                                                                                             

class contorllerNullAlert extends StatelessWidget {
  const contorllerNullAlert({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 150,
      child: Center(child: Text("controller is null max... or None in python lol idccccccccc")),
    );
  }
}