import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<File>? imageFile;
  File? image;
  String result = '';
  ImagePicker? imagePicker;
  selectedPhotoFromGallery() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.gallery);
    image = File(pickedFile!.path);
    setState(() {
      image;
      doImageClassification();
    });
  }

  capturePhotoFromCamera() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.camera);
    image = File(pickedFile!.path);
    setState(() {
      image;
      doImageClassification();
    });
  }

  loadDataModelFiles() async {
    String? output = await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        labels: 'assets/labels.txt',
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
    print(output);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    loadDataModelFiles();
  }

  doImageClassification() async {
    var recognitions = await Tflite.runModelOnImage(
        path: image!.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 1,
        threshold: 0.1,
        asynch: true);
    print(recognitions!.length.toString());
    setState(() {
      result = '';
    });
    recognitions.forEach((element) {
      setState(() {
        print(element.toString());
        result += element['label'] + '\n\n';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.indigo[300],
        child: Column(
          children: [
            const SizedBox(
              width: 100,
            ),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: TextButton(
                        onPressed: selectedPhotoFromGallery,
                        onLongPress: capturePhotoFromCamera,
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 30.0,right: 35.0,left: 18.0),
                            child: image !=null? Image.file(image!,height: 500.0,width: 400.0,fit: BoxFit.cover,):
                            const SizedBox(height: 190.0,
                            width: 140.0,
                            child: Icon(Icons.camera_alt_sharp,color: Colors.black,),),
                          ),
                        )),
                  )
                ],
              ),
            ),
            const SizedBox(height: 100.0,),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Text(result,textAlign: TextAlign.center,style: const TextStyle(
                fontSize: 25.0,
                color: Colors.pinkAccent,backgroundColor: Colors.white60
              ),),

            )
          ],
        ),
      ),
    );
  }
}
