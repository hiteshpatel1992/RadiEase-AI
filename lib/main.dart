import 'package:fitway_report/main_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide MenuItemButton;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  Gemini.init(
    apiKey: "AIzaSyB6eg6_OoD4Y8_x84VIGeNbmdU__Tap8_4",
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _FitwayApp();
}

class _FitwayApp extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      builder: EasyLoading.init(),
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 116, 185, 255)),
      ),
      home: const MainScreen(),
    );
  }
}
