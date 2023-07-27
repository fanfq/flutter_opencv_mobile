import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:flutter/material.dart';

//import 'dart:ffi' as ffi;
import 'dart:io' show Platform, Directory;

import 'package:path/path.dart' as path;


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

  @override
  void initState() {
    super.initState();

    //加载 C 符号
    _nativeAddLib = Platform.isAndroid
        ? DynamicLibrary.open("libandroid_opencv_mobile.so")
        : DynamicLibrary.process();

    funcAdd = _nativeAddLib.lookup<NativeFunction<Int32 Function(Int32, Int32)>>('native_add').asFunction();
    opencvVersion= _nativeAddLib.lookup<NativeFunction<Pointer<Int8> Function()>>('opencv_version').asFunction();


    ///
    //Pointer<Int8> to String
    //https://blog.csdn.net/eieihihi/article/details/119152003
    Pointer<Int8> _ver = opencvVersion();
    _opencvVersion =  _ver.cast<Utf8>().toDartString();
    print("open ver:$_opencvVersion");
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
        title: Text("flutter opencv mobile demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'opencv ver:${_opencvVersion}',
            ),
            
            Container(
              height: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset("assets/imgs/1.jpg"),

                  Image.asset("assets/imgs/1.jpg"),
                ],
              )
            ),

            Container(
              child: Column(
                children: [
                  ElevatedButton(onPressed: (){}, child: Text("二值化")),
                  ElevatedButton(onPressed: (){}, child: Text("灰度化")),
                  ElevatedButton(onPressed: (){}, child: Text("高斯模糊")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
