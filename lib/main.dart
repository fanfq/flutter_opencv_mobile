import 'dart:async';
import 'dart:io';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';


//ffi.Pointer<ffi.Int8>
//"Your message".toNativeUtf8().cast<Int8>()


// FFI signature of the hello_world C function
//typedef HelloWorldFunc = ffi.Void Function();
// Dart type definition for calling the C foreign function
//typedef HelloWorld = ffi.SignedChar Function();

//late final String Function() hello;
//函数声明
late final int Function(int x, int y) funcAdd;
late final Pointer<Int8> Function() opencvVersion;
// late final Pointer<Int8> Function(int pixels,int w,int h) bitmap2Gray;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late DynamicLibrary _nativeAddLib;

  String? _opencvVersion;

  final _picker = ImagePicker();
  late Image _srcImg;
  late Image _dstImg;

  initData() async {
    // Uint8List _byte = await Cv2.threshold(
    //   pathFrom: CVPathFrom.ASSETS,
    //   pathString: 'assets/imgs/1.jpg',
    //   thresholdValue: 150,
    //   maxThresholdValue: 200,
    //   thresholdType: Cv2.THRESH_BINARY,
    // );
    //
    // _dstImg = Image.memory(_byte);
    // setState(() {
    //
    // });
  }

  @override
  void initState() {
    super.initState();

    //加载 C 符号
    _nativeAddLib = Platform.isAndroid
        ? DynamicLibrary.open("libandroid_opencv_mobile.so")
        : DynamicLibrary.process();

    funcAdd = _nativeAddLib.lookup<NativeFunction<Int32 Function(Int32, Int32)>>('native_add').asFunction();
    opencvVersion= _nativeAddLib.lookup<NativeFunction<Pointer<Int8> Function()>>('opencv_version').asFunction();


    /// get opencv version
    //Pointer<Int8> to String
    //https://blog.csdn.net/eieihihi/article/details/119152003
    Pointer<Int8> _ver = opencvVersion();
    _opencvVersion =  _ver.cast<Utf8>().toDartString();
    print("open ver:$_opencvVersion");


    _srcImg = Image.asset("assets/imgs/1.jpg");
    _dstImg = Image.asset("assets/imgs/1.jpg");


    initData();


  }


  void _incrementCounter() {

    // //查找"native_add"符号，并转为 Dart 函数
    // final HelloWorld hello = _nativeAddLib
    //     .lookup<NativeFunction<HelloWorldFunc>>("hello_world")
    //     .asFunction();
    //
    // hello();


    _counter++;

    int n = funcAdd(_counter, _counter);
    print('funcAdd($_counter, $_counter) = $n');

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("opencv ${_opencvVersion!}"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            Container(
              child: Row(
                children: [
                  ElevatedButton(onPressed: (){
                    print("二值化");
                  }, child: Text("二值化")),
                  ElevatedButton(onPressed: (){}, child: Text("灰度化")),
                  ElevatedButton(onPressed: (){}, child: Text("高斯模糊")),
                ],
              ),
            ),
            
            Container(
              //height: 250,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      print("12");
                      await _pickImageFromGallery();
                    },
                    child: _srcImg,
                  ),

                  SizedBox(height: 20,),

                  _dstImg,
                ],
              )
            ),



          ],
        ),
      ),
    );
  }




  ///
  /// 从相册选择图片
  ///
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      //setState(() => this._imageFile = File(pickedFile.path));
      File _file = File(pickedFile.path);
      _srcImg = Image.file(_file!);
      _dstImg = Image.file(_file!);

      setState(() {});
    }
  }
}
